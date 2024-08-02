import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stone_deep_link/stone_deep_link.dart';

part 'estorno_event.dart';
part 'estorno_state.dart';

class EstornoBloc extends Bloc<EstornoEvent, EstornoState> {
  EstornoBloc(this.stoneDeepLink) : super(EstornoNaoInicilizado()) {
    on<EstornoIniciou>(_onEstornoIniciou);
    on<EstornoFinalizou>(_onEstornoFinalizou);
  }

  final StoneDeepLink stoneDeepLink;
  late StreamSubscription<String> _streamSubscription;

  FutureOr<void> _onEstornoIniciou(
    EstornoIniciou event,
    Emitter<EstornoState> emit,
  ) async {
    emit(EstornoEmProgresso());

    stoneDeepLink.fazerEstorno(
      event.valor,
      event.atk,
      event.permiteEditarValor,
    );
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  FutureOr<void> _onEstornoFinalizou(
    EstornoFinalizou event,
    Emitter<EstornoState> emit,
  ) async {
    try {
      var uri = Uri.parse(event.result);
      log('emitiu estorno finalizado');
      emit(EstornoSucesso(uri.queryParameters));
    } catch (e, s) {
      addError(e, s);
    }
  }
}
