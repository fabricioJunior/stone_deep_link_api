import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'stone_deep_link_platform_interface.dart';

/// An implementation of [StoneDeepLinkPlatform] that uses method channels.
class MethodChannelStoneDeepLink extends StoneDeepLinkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('stone_deep_link');

  final StreamController<String> _onPagamentoFinalizadoStreamController =
      StreamController.broadcast();

  Stream<String> get onPagamentoFinalizado =>
      _onPagamentoFinalizadoStreamController.stream;

  MethodChannelStoneDeepLink() {
    methodChannel.setMethodCallHandler(_onMensagemRecebida);
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> fazerPagamento(
    String formaDePagamento,
    int parcelas,
    int valor,
  ) async {
    Map<String, dynamic> args = {
      "amount": valor,
      "editableAmount": false,
      "transactionType": formaDePagamento,
    };
    if (parcelas >= 2) {
      args.addAll({"installmentCount": parcelas});
    }

    methodChannel.invokeListMethod('fazerPagamento', args);
  }

  Future _onMensagemRecebida(MethodCall call) async {
    if (call.method == 'pagamentoFinalizado') {
      _onPagamentoFinalizado(call.arguments.toString());
    }
  }

  void _onPagamentoFinalizado(String resposta) {
    _onPagamentoFinalizadoStreamController.add(resposta);
  }
}
