import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stone_deep_link/presentaion/pagamento_bloc/pagamento_event.dart';
import 'package:stone_deep_link/presentaion/pagamento_bloc/pagamento_state.dart';
import 'package:stone_deep_link/stone_deep_link.dart';

class PagamentoBloc extends Bloc<PagamentoEvent, PagamentoState> {
  final StoneDeepLink stoneDeepLink;
  late StreamSubscription<String> _streamSubscription;
  PagamentoBloc(this.stoneDeepLink) : super(PagamentoNaoIniciado()) {
    on<PagamentoIniciou>(_onPagamentoIniciou);
    on<PagamentoFinalizou>(_onPagamentoFinalizou);

    _streamSubscription = stoneDeepLink.onPagamentoFinalizado.listen((event) {
      add(PagamentoFinalizou(result: event));
    });
  }

  FutureOr<void> _onPagamentoIniciou(
    PagamentoIniciou event,
    Emitter<PagamentoState> emit,
  ) {
    try {
      emit(PagamentoEmProgresso());
      stoneDeepLink.fazerPagamento(
        event.formaDePagamento,
        event.parcelas,
        event.valor,
        event.deepLinkReturnSchema,
        event.formaDeCobrancaDeJuros,
      );
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onPagamentoFinalizou(
    PagamentoFinalizou event,
    Emitter<PagamentoState> emit,
  ) {
    try {
      var uri = Uri.parse(event.result);
      log('emitiu pagamento finalizado');
      emit(PagamentoSucesso(resultado: uri.queryParameters));
    } catch (e, s) {
      addError(e, s);
    }
  }

  @override
  Future<void> close() async {
    await _streamSubscription.cancel();
    super.close();
  }
}
