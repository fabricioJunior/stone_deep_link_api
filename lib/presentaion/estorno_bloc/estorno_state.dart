part of 'estorno_bloc.dart';

abstract class EstornoState {}

class EstornoNaoInicilizado extends EstornoState {}

class EstornoEmProgresso extends EstornoState {}

class EstornoSucesso extends EstornoState {
  final Map<String, dynamic> resultado;

  EstornoSucesso(this.resultado);
}

class EstornoFalha extends EstornoState {}
