import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stone_deep_link/presentaion/estorno_bloc/estorno_bloc.dart';
import 'package:stone_deep_link/stone_deep_link.dart';

Future<Map<String, dynamic>?> showEstornoModal(
  BuildContext context, {
  required int valor,
  required int atk,
  required bool permiteEditarValor,
  required String deepLinkReturnSchema,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    useSafeArea: true,
    builder: (_) {
      return EstornoModal(
        valor: valor,
        atk: atk,
        permiteEditarValor: permiteEditarValor,
        deepLinkReturnSchema: deepLinkReturnSchema,
      );
    },
  );
}

class EstornoModal extends StatelessWidget {
  final int valor;
  final int atk;
  final bool permiteEditarValor;
  final String deepLinkReturnSchema;

  const EstornoModal({
    required this.atk,
    required this.valor,
    required this.permiteEditarValor,
    required this.deepLinkReturnSchema,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EstornoBloc(
        StoneDeepLink(),
      )..add(
          EstornoIniciou(valor, atk, permiteEditarValor),
        ),
      child: BlocListener<EstornoBloc, EstornoState>(
        listener: (context, state) {
          if (state is EstornoSucesso) {
            Navigator.of(context).pop(state.resultado);
          }
          if (state is EstornoFalha) {
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
