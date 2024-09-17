import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stone_deep_link/presentaion/impressora_bloc/impressora_state.dart';
import 'package:stone_deep_link/stone_deep_link.dart';

import 'impressora_event.dart';

class ImpressoraBloc extends Bloc<ImpressoraEvent, ImpressoraState> {
  late StreamSubscription<String> onMessageSubscription;

  final StoneDeepLink stoneDeepLink;
  ImpressoraBloc(this.stoneDeepLink) : super(ImpressoraInicial()) {
    on<ImpressaIniciou>(_impressoraIniciou);
    on<ImpressoraFinalizou>(_onImpressoraFinalizou);
    onMessageSubscription = stoneDeepLink.onPagamentoFinalizado.listen((event) {
      add(ImpressoraFinalizou(result: event));
    });
  }

  FutureOr<void> _impressoraIniciou(
    ImpressaIniciou event,
    Emitter<ImpressoraState> emit,
  ) {
    stoneDeepLink.imprimirArquivo();
    emit(ImpressoraImprimirEmProgresso());
  }

  FutureOr<void> _onImpressoraFinalizou(
    ImpressoraFinalizou event,
    Emitter<ImpressoraState> emit,
  ) {
    emit(ImpressoraImprimirSucesso());
  }

  @override
  Future<void> close() {
    onMessageSubscription.cancel();
    return super.close();
  }
}
