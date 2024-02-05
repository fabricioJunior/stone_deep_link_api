abstract class PagamentoState {}

class PagamentoNaoIniciado extends PagamentoState {}

class PagamentoEmProgresso extends PagamentoState {}

class PagamentoSucesso extends PagamentoState {
  final Map<String, dynamic> resultado;

  PagamentoSucesso({required this.resultado});
}

class PagamentoFalha extends PagamentoState {}
