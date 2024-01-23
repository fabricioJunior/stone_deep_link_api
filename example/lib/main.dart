import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title = 'teste'}) : super();

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platformMethodChannel =
      const MethodChannel("mainDeeplinkChannel");
  String deeplinkResult = "";
  late StreamSubscription _sub;

  Future<Null> _sendDeeplink() async {
    String _message = "";
    try {
      int amount = 100;
      bool editableAmount = false; //true, false
      int installmentCount = 2; //número de 2 a 18
      String transactionType = "CREDIT"; //DEBIT, CREDIT, VOUCHER
      String returnScheme = "exstone://stone.com";

      await platformMethodChannel.invokeMethod('sendDeeplink', {
        "amount": amount,
        "editable_amount": editableAmount,
        "installment_count": installmentCount,
        "transaction_type": transactionType,
        "return_scheme": returnScheme
      });
      Uri url = Uri(
        scheme: 'payment-app',
        host: 'pay',
        queryParameters: <String, String>{}..addAll({
            "amount": amount.toString(),
            "editable_amount": editableAmount.toString(),
            "installment_count": installmentCount.toString(),
            "transaction_type": transactionType,
            "return_scheme": returnScheme
          }),
      );
      await launchUrl(url);
    } on PlatformException catch (e) {
      _message = "Erro ao enviar deeplink: ${e.message}.";
    }
    setState(() {
      deeplinkResult = _message;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var init = await getInitialLink();
      print(init);
    });
    _sub = uriLinkStream.listen((Uri? uri) {
      log('escuta do deepLink:');
      print(uri);
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
    super.initState();
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
                onPressed: () {
                  _sendDeeplink();
                },
                child: const Text('Enviar deeplink',
                    style: TextStyle(fontSize: 20)),
              ),
              Text(deeplinkResult),
            ],
          ),
        ));
  }
}
