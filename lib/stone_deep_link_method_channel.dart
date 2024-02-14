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

  @override
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
    String deepLinkReturnSchema,
  ) async {
    Map<String, String> args = {
      "amount": valor.toString(),
      "editableAmount": false.toString(),
      "transactionType": formaDePagamento,
      'installmentType': 'MERCHANT'
    };
    if (parcelas >= 2) {
      args.addAll({"installmentCount": parcelas.toString()});
    }

    await methodChannel.invokeMethod<bool>('fazerPagamento', args);
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
