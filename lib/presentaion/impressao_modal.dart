import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'impressora_bloc/impressora_bloc.dart';
import 'impressora_bloc/impressora_state.dart';

class ImpressaoModal extends StatelessWidget {
  final ImpressoraBloc impressoraBloc;

  const ImpressaoModal({
    super.key,
    required this.impressoraBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => impressoraBloc,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BackButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                )
              ],
            ),
            const Expanded(child: SizedBox()),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: BlocListener<ImpressoraBloc, ImpressoraState>(
                  listener: (context, state) async {
                    if (state is ImpressoraImprimirSucesso) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: BlocBuilder<ImpressoraBloc, ImpressoraState>(
                    builder: (context, state) {
                      if (state is ImpressoraImprimirEmProgresso) {
                        return _progress('Imprimindo....');
                      } else if (state is ImpressoraImprimirSucesso) {
                        return _progress('Impressão concluída!');
                      }
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.yellow,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _progress(String message) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      );
}
