import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:smart_pag_contract/interfaces/log.dart';
import 'package:stone_deep_link/presentaion/pagamento_modal.dart';

import 'presentaion/estorno_modal.dart';
import 'stone_deep_link.dart';
import 'stone_deep_link_platform_interface.dart';

class Pagamento extends PagamentoContract {
  @override
  Future<PagamentoResult> fazerPagamento(
    FormaDePagamento formaDePagamento,
    int parcelas,
    int valor,
    BuildContext context, {
    String? deepLinkReturnSchema,
    FormaDeCobrancaDeJuros? formaDeCobranca,
    bool? imprimirComprovanteAutomaticamente,
  }) async {
    var pagamentoResult = await showPagamentoModal(
      context,
      formaDePagamento: formaDePagamento,
      valor: valor,
      parcelas: parcelas,
      deepLinkReturnSchema: deepLinkReturnSchema ?? 'deepstone',
      formaDeCobranca:
          formaDeCobranca ?? FormaDeCobrancaDeJuros.jurosCobradoDoVendedor,
    );

    if (pagamentoResult == null) {
      return PagamentoResult.erro(erro: 'Falha no pagamento');
    }
    var cardBrand = pagamentoResult["brand"];
    var cardBin = '';
    var nsu = pagamentoResult['nsu'];
    var date = pagamentoResult['authorization_date_time'];
    var transactionCode = pagamentoResult['authorization_code'];
    var transactionID = pagamentoResult['atk'];
    var hostNSU = pagamentoResult['account_id'];
    return PagamentoResult(
      cardBrand: cardBrand,
      cardBin: cardBin,
      nsu: nsu ?? '',
      date: DateFormat('dd/MM/yyyy hh:mm:ss')
          .parse(date)
          .toString(), //trata forma data
      time: DateFormat('dd/MM/yyyy hh:mm:ss').parse(date).toString(),
      hostNSU: hostNSU ?? '',
      transactionID: transactionID,
      transactionCode: transactionCode ?? '',
    );
  }

  @override
  Future<void> imprimirArquivo({
    required BuildContext context,
    required String filePath,
  }) async {
    StoneDeepLinkPlatform.instance.imprimirArquivo();
  }

  @override
  String get tipoDaMaquina => 'stone';

  @override
  Future<String> serialDaMaquina() {
    return StoneDeepLinkPlatform.instance.getSerial();
  }

  @override
  Future<void> realizarEstorno({
    required BuildContext context,
    int? valor,
    bool? permiteEditarValor,
    String? transactionCode,
    String? transactionId,
  }) async {
    await showEstornoModal(
      context,
      valor: valor ?? 0,
      atk: int.parse(transactionId!),
      permiteEditarValor: false,
      deepLinkReturnSchema: '',
    );
  }

  @override
  Future<List<Log>> recuperarLogsUltimaTransacao() async {
    return [];
  }

  @override
  Future<void> salvarLog(Log log) async {}
}
