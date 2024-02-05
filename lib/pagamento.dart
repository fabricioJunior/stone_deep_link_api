import 'package:flutter/widgets.dart';
import 'package:stone_deep_link/presentaion/pagamento_modal.dart';

import 'stone_deep_link.dart';

class Pagamento extends PagamentoContract {
  @override
  Future<Map<String, String>> fazerPagamento(
    FormaDePagamento formaDePagamento,
    int parcelas,
    int valor,
    BuildContext context,
  ) async {
    var pagamentoResult = await showPagamentoModal(
      context,
      formaDePagamento: formaDePagamento,
      valor: valor,
      parcelas: parcelas,
    );

    if (pagamentoResult == null) {
      return {'result': 'errp'};
    }

    Map<String, String> result = {};
    for (var key in pagamentoResult.keys) {
      result.addAll({key: pagamentoResult[key].toString()});
    }

    return result;
  }

  @override
  Future<void> imprimirArquivo({required String filePath}) {
    throw UnimplementedError();
  }

  @override
  Future<void> realizarEstorno({
    String? transactionCode,
    String? transactionId,
  }) {
    throw UnimplementedError();
  }
}
