part of 'estorno_bloc.dart';

abstract class EstornoEvent {}

class EstornoIniciou extends EstornoEvent {
  final int valor;

  final int atk;

  final bool permiteEditarValor;

  EstornoIniciou(this.valor, this.atk, this.permiteEditarValor);
}

class EstornoFinalizou extends EstornoEvent {
  final String result;

  EstornoFinalizou(this.result);
}
