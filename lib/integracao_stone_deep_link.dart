import 'package:flutter/material.dart';
import 'package:smart_pag_contract/interfaces/pagamento.dart';

class IntegracaoStoneDeepLinkStone extends PagamentoContract {
  @override
  Future<Map<String, String>> fazerPagamento(
    FormaDePagamento formaDePagamento,
    int parcelas,
    int valor,
    BuildContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> imprimirArquivo({required String filePath}) {
    // TODO: implement imprimirArquivo
    throw UnimplementedError();
  }

  @override
  Future<void> realizarEstorno(
      {String? transactionCode, String? transactionId}) {
    // TODO: implement realizarEstorno
    throw UnimplementedError();
  }
}
