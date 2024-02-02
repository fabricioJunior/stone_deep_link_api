import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

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
  final _appLinks = AppLinks();

  Future<void> _sendDeeplink() async {
    StoneDeepLink().fazerPagamento(
      FormaDePagamento.credito,
      2,
      5000,
    );

// Subscribe to all events when app is started.
// (Use allStringLinkStream to get it as [String])
    _appLinks.allUriLinkStream.listen((uri) {
      print('retorno');
      print(uri ?? 'veio null');
    });
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
