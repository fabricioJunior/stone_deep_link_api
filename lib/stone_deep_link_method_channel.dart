import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stone_deep_link/stone_deep_link.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'stone_deep_link_platform_interface.dart';

/// An implementation of [StoneDeepLinkPlatform] that uses method channels.
class MethodChannelStoneDeepLink extends StoneDeepLinkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('stone_deep_link');

  final StreamController<String> _onPagamentoFinalizadoStreamController =
      StreamController.broadcast();

  final StreamController<String> _onEstornoFinalizadoStreamController =
      StreamController.broadcast();

  @override
  Stream<String> get onPagamentoFinalizado =>
      _onPagamentoFinalizadoStreamController.stream;

  Stream<String> get onEstornoFinalizado =>
      _onEstornoFinalizadoStreamController.stream;

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
    FormaDeCobrancaDeJuros formaDeCobrancaDeJuros,
  ) async {
    Map<String, String?> args = {
      "amount": valor.toString(),
      "editableAmount": false.toString(),
      "transactionType": formaDePagamento,
    };
    args.addAll({
      'installmentType': formaDeCobrancaDeJuros.toStoneFormart(),
    });

    if (parcelas >= 2) {
      args.addAll({"installmentCount": parcelas.toString()});
    }

    await methodChannel.invokeMethod<bool>('fazerPagamento', args);
  }

  Future _onMensagemRecebida(MethodCall call) async {
    if (call.method == 'pagamentoFinalizado') {
      _onPagamentoFinalizado(
        call.arguments.toString(),
      );
      _onEstornoFinalizado(
        call.arguments.toString(),
      );
    }
    if (call.method == 'estornoFinalizado') {}
  }

  @override
  Future<void> fazerEstorno(int valor, int atk, bool permiteEditarValor) async {
    Map<String, String?> args = {
      "amount": valor.toString(),
      "editableAmount": false.toString(),
      "atk": atk.toString(),
    };
    await methodChannel.invokeMethod<bool>('fazerEstorno', args);
  }

  void _onPagamentoFinalizado(String resposta) {
    _onPagamentoFinalizadoStreamController.add(resposta);
  }

  void _onEstornoFinalizado(String resposta) {
    _onEstornoFinalizadoStreamController.add(resposta);
  }

  @override
  Future<String> getSerial() async {
    var response = await methodChannel.invokeMethod<String?>('serial');
    return response ?? '';
  }

  @override
  Future<void> imprimirArquivo() async {
    var cacheDirectoy = Directory('/storage/emulated/0/download');

    File file = File('${cacheDirectoy.path}/comprovante2.jpg');
    var image = file.readAsBytesSync();
    var json = jsonEncode([
      Line(
        type: 'image',
        content: base64Encode(image),
      ),
    ]);

    var uri = Uri(scheme: 'printer-app', host: 'print', queryParameters: {
      'SHOW_FEEDBACK_SCREEN': 'true',
      'SCHEME_RETURN': 'test',
      'PRINTABLE_CONTENT': json,
    });

    await launchUrlString(
      uri.toString(),
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }
}

extension ToStoneFormart on FormaDeCobrancaDeJuros {
  String toStoneFormart() {
    if (this == FormaDeCobrancaDeJuros.jurosCobradoDoCliente) {
      return 'MERCHANT';
    }
    if (this == FormaDeCobrancaDeJuros.jurosCobradoDoVendedor) {
      return 'ISSUER';
    }
    return 'NONE';
  }
}

class Line {
  final String type;
  final String content;

  Line({required this.type, required this.content});

  Map<String, dynamic> toJson() => {
        'type': type,
        'imagePath': content,
      };
}
