import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:stone_deep_link/presentaion/pagamento_modal.dart';

import 'package:stone_deep_link/stone_deep_link.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'DeepLink Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String deeplinkResult = "";
  Future<void> _sendDeeplink() async {
    var result = await showPagamentoModal(
      context,
      formaDePagamento: FormaDePagamento.credito,
      valor: 5000,
      parcelas: 2,
    );
    log(result?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _sendDeeplink,
                child: const Text('Enviar deeplink',
                    style: TextStyle(fontSize: 20)),
              ),
              Text(deeplinkResult),
            ],
          ),
        ));
  }
}
