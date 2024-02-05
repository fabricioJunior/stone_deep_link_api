import 'package:stone_deep_link/stone_deep_link.dart';

abstract class PagamentoEvent {}

class PagamentoIniciou extends PagamentoEvent {
  final FormaDePagamento formaDePagamento;
  final int valor;
  final int parcelas;

  PagamentoIniciou({
    required this.formaDePagamento,
    required this.valor,
    required this.parcelas,
  });
}

class PagamentoFinalizou extends PagamentoEvent {
  final String result;

  PagamentoFinalizou({required this.result});
}
