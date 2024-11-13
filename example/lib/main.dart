import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(MyApp());
}
//adb shell am start -W -a android.intent.action.VIEW -d "deepstone://pay-response?code=0\&amount=100\&cardholder_name=JOAO%2FSILVA\&itk=PB0419AL60480-1.17.7-2278-0003\&atk=37820073187607\&authorization_date_time=05%2F10%2F2022%2002%3A36%3A17\&brand=MASTERCARD\&authorization_code=187607&installment_count=0\&pan=627303****2166\&type=D%C3%A9bito\&entry_mode=ICC"

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
      home: const MyHomePage(title: 'DeepLink Demo'),
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
    var cacheDirectoy = Directory('/storage/emulated/0/download');

    File file = File('${cacheDirectoy.path}/comprovante2.jpg');
    final bytes = File(file.path).readAsBytesSync();

    String img64 = base64Encode(bytes);

    var json = """
[
  {
    "type": "text",
    "content": "texto centro grande",
    "align": "center",
    "size": "big"
  },
  {
    "type": "text",
    "content": "texto direita médio",
    "align": "right",
    "size": "medium"
  },
  {
    "type": "text",
    "content": "texto esquerda pequeno",
    "align": "left",
    "size": "small"
  },
  {
    "type": "line",
    "content": "texto sem customização"
  },
]
""";
    launchUrlString(
      'printer-app://print?SHOW_FEEDBACK_SCREEN=true&SCHEME_RETURN=deepstone&PRINTABLE_CONTENT=${json}',
    );
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
