import 'package:smart_pag_contract/smart_pag_contract.dart';

import 'stone_deep_link_platform_interface.dart';

export 'package:smart_pag_contract/interfaces/pagamento.dart';

class StoneDeepLink {
  Future<String?> getPlatformVersion() {
    return StoneDeepLinkPlatform.instance.getPlatformVersion();
  }

  Future<void> fazerPagamento(
    FormaDePagamento formaDePagamento,
    int parcelas,
    int valor,
  ) async {
    await StoneDeepLinkPlatform.instance.fazerPagamento(
      formaDePagamento.toFormaDePagamentoStone(),
      parcelas,
      valor,
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
      default:
        throw UnimplementedError('forma de pagamento não implementada');
    }
  }
}