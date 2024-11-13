import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:millimeters/millimeters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';
import "dart:ui" as ui;

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

class WidgetTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text('teste')],
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
    await imprimirFromWidget(context, WidgetTest());
    var cacheDirectoy = Directory('/storage/emulated/0/download');

    File file = File('${cacheDirectoy.path}/comprovante2.jpg');
    var image = file.readAsBytesSync();
    var json = jsonEncode([
      Line(
        type: 'image',
        content: base64Encode(image),
      ),
    ]);

    var uri = Uri(scheme: 'printer-app', host: 'print', queryParameters: {
      'SHOW_FEEDBACK_SCREEN': 'true',
      'SCHEME_RETURN': 'test',
      'PRINTABLE_CONTENT': json,
    });

    launchUrlString(
      uri.toString(),
      mode: LaunchMode.externalNonBrowserApplication,
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

class Line {
  final String type;
  final String content;

  Line({required this.type, required this.content});

  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content,
      };
}

Future<void> imprimirFromWidget(
  BuildContext context,
  dynamic widget,
) async {
  ScreenshotController screenshotController = ScreenshotController();

  var millimetersData = getMillimetersData(context);
  Uint8List widgetImage = await screenshotController.captureFromLongWidget(
    FolhaDeImpressa(
      data: millimetersData,
      child: widget,
    ),
    delay: Duration.zero,
    constraints: BoxConstraints(
      maxWidth: millimetersData.mm(47),
      maxHeight: double.infinity,
    ),
  );

  await Permission.manageExternalStorage.request();
  await Permission.storage.request();
  final codec = await ui.instantiateImageCodec(widgetImage);
  final frame = await codec.getNextFrame();
  var image = frame.image;
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final jpg = JpegEncoder()
      .compress(data!.buffer.asUint8List(), image.width, image.height, 90);

  var cacheDirectoy = Directory('/storage/emulated/0/download');

  File file = File('${cacheDirectoy.path}/comprovante2.jpg');
  if (file.existsSync()) {
    await file.delete();
  }
  await file.writeAsBytes(jpg, mode: FileMode.write);
}

MillimetersData getMillimetersData(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  var resolution = Size(width, height);

  var physical = Size(43, height);
  var data = MillimetersData(physical: physical, resolution: resolution);
  return data;
}

class FolhaDeImpressa extends StatelessWidget {
  final Widget child;
  final MillimetersData data;

  const FolhaDeImpressa({
    super.key,
    required this.child,
    required this.data,
  });
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        width: data.mm(47),
        child: child,
      ),
    );
  }
}
