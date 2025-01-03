import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stone_deep_link/presentaion/pagamento_bloc/pagamento_event.dart';
import 'package:stone_deep_link/presentaion/pagamento_bloc/pagamento_state.dart';
import 'package:stone_deep_link/stone_deep_link.dart';

import 'pagamento_bloc/pagamento_bloc.dart';

Future<Map<String, dynamic>?> showPagamentoModal(
  BuildContext context, {
  required FormaDePagamento formaDePagamento,
  required int valor,
  required int parcelas,
  required String deepLinkReturnSchema,
  required FormaDeCobrancaDeJuros formaDeCobranca,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    useSafeArea: true,
    builder: (_) {
      return PagamentoModal(
        formaDePagamento: formaDePagamento,
        valor: valor,
        parcelas: parcelas,
        deepLinkReturnSchema: deepLinkReturnSchema,
        formaDeCobrancaDeJuros: formaDeCobranca,
      );
    },
  );
}

class PagamentoModal extends StatelessWidget {
  final FormaDePagamento formaDePagamento;
  final int valor;
  final int parcelas;
  final String deepLinkReturnSchema;
  final FormaDeCobrancaDeJuros formaDeCobrancaDeJuros;

  const PagamentoModal({
    required this.formaDePagamento,
    required this.valor,
    required this.parcelas,
    required this.deepLinkReturnSchema,
    required this.formaDeCobrancaDeJuros,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PagamentoBloc(
        StoneDeepLink(),
      )..add(
          PagamentoIniciou(
            formaDePagamento: formaDePagamento,
            valor: valor,
            parcelas: parcelas,
            deepLinkReturnSchema: deepLinkReturnSchema,
            formaDeCobrancaDeJuros: formaDeCobrancaDeJuros,
          ),
        ),
      child: BlocListener<PagamentoBloc, PagamentoState>(
        listener: (context, state) {
          if (state is PagamentoSucesso) {
            Navigator.of(context).pop(state.resultado);
          }
          if (state is PagamentoFalha) {
            Navigator.of(context).pop(null);
          }
        },
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CloseButton(),
                ],
              ),
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar operação'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
