import 'package:smart_pag_contract/injections/injections.dart';
import 'package:smart_pag_contract/interfaces/pagamento.dart';

import 'integracao_stone_deep_link.dart';

void resolverDependenciasDeepLinkStone() {
  sl.registerFactory<PagamentoContract>(() => IntegracaoStoneDeepLinkStone());

  pagamentoIsImplements = true;
}
