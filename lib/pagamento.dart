import 'package:flutter/widgets.dart';
import 'package:stone_deep_link/presentaion/pagamento_modal.dart';

import 'stone_deep_link.dart';

class Pagamento extends PagamentoContract {
  @override
  Future<PagamentoResult> fazerPagamento(
    FormaDePagamento formaDePagamento,
    int parcelas,
    int valor,
    BuildContext context, {
    String? deepLinkReturnSchema,
  }) async {
    var pagamentoResult = await showPagamentoModal(
      context,
      formaDePagamento: formaDePagamento,
      valor: valor,
      parcelas: parcelas,
      deepLinkReturnSchema: deepLinkReturnSchema ?? 'deepstone',
    );

    if (pagamentoResult == null) {
      return PagamentoResult.erro(erro: 'Falha no pagamento');
    }
    var cardBrand = pagamentoResult['MASTERCARD'];
    var cardBin = '';
    var nsu = pagamentoResult['nsu'];
    var date = pagamentoResult['authorization_date_time'];
    var transactionCode = pagamentoResult['authorization_code'];
    var transactionID = pagamentoResult['atk'];
    var hostNSU = pagamentoResult['account_id'];
    return PagamentoResult(
      cardBrand: cardBrand,
      cardBin: cardBin,
      nsu: nsu,
      date: DateTime.parse(date),
      time: DateTime.parse(date),
      hostNSU: hostNSU,
      transactionID: transactionID,
      transactionCode: transactionCode,
    );
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
