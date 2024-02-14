import 'package:smart_pag_contract/injections/injections.dart';
import 'package:stone_deep_link/stone_deep_link.dart';

import 'pagamento.dart';

void resolveDependenciasStoneDeepLink() {
  sl.registerFactory<PagamentoContract>(() => Pagamento());
  pagamentoIsImplements = true;
  pagamentoContractInject = true;
}
