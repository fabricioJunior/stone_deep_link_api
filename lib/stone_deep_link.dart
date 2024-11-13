import 'dart:convert';
import 'dart:io';

import 'package:smart_pag_contract/smart_pag_contract.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'stone_deep_link_platform_interface.dart';

export 'package:smart_pag_contract/interfaces/pagamento.dart';

class StoneDeepLink {
  Stream<String> get onPagamentoFinalizado =>
      StoneDeepLinkPlatform.instance.onPagamentoFinalizado;
  Future<String?> getPlatformVersion() {
    return StoneDeepLinkPlatform.instance.getPlatformVersion();
  }

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
      'SCHEME_RETURN': 'deepstone',
      'PRINTABLE_CONTENT': json,
    });

    launchUrlString(
      uri.toString(),
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }

  Future<void> fazerPagamento(
    FormaDePagamento formaDePagamento,
    int parcelas,
    int valor,
    String deepLinkReturnSchema,
  ) async {
    await StoneDeepLinkPlatform.instance.fazerPagamento(
        formaDePagamento.toFormaDePagamentoStone(),
        parcelas,
        valor,
        deepLinkReturnSchema);
  }

  Future<void> fazerEstorno(
    int valor,
    int atk,
    bool permiteEditarValor,
  ) async {
    await StoneDeepLinkPlatform.instance.fazerEstorno(
      valor,
      atk,
      permiteEditarValor,
    );
  }
}

extension FormaDePagamentoToStone on FormaDePagamento {
  String toFormaDePagamentoStone() {
    switch (this) {
      case FormaDePagamento.credito:
        return 'CREDIT';
      case FormaDePagamento.debito:
        return 'DEBIT';
      case FormaDePagamento.pix:
        return 'PIX';
      case FormaDePagamento.vale:
        return 'VOUCHER';
      default:
        throw UnimplementedError('forma de pagamento não implementada');
    }
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
