// Automatic FlutterFlow imports
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:millimeters/millimeters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_pag_contract/smart_pag_handler.dart';
import "dart:ui" as ui;

const double inch = 72.0;
final double cm = inch / 2.54;

Future<void> imprimirComprovantePIX(
  BuildContext context,
  bool viaDoEstabelecimento,
  String dataPagamento,
  String valor,
  String cliente,
  String origemDaAutorizacao,
  String empresa,
  String endereco,
  String cnpj,
  String codigoDaVenda,
  String codigoDaTransacao,
  String nsu,
  String origem,
  String formaPagamento,
) async {
  await Permission.manageExternalStorage.request();
  await Permission.storage.request();

  final widget = await comprovante(
    viaDoEstabelecimento: viaDoEstabelecimento,
    dataPagamento: dataPagamento,
    valor: valor,
    cliente: cliente,
    origemDaAutorizacao: origemDaAutorizacao,
    empresa: empresa,
    endereco: endereco,
    cnpj: cnpj,
    codigoDaVenda: codigoDaVenda,
    codigoDaTransacao: codigoDaTransacao,
    nsu: nsu,
    origem: origem,
    formaPagamento: formaPagamento,
  );

  await imprimirFromWidget(context, widget);
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

  await SmartPagHandler.imprimirArquivo(file.path, context);
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

Widget comprovante({
  required bool viaDoEstabelecimento,
  required String dataPagamento,
  required String valor,
  required String cliente,
  required String origemDaAutorizacao,
  required String empresa,
  required String endereco,
  required String cnpj,
  required String codigoDaVenda,
  required String codigoDaTransacao,
  required String nsu,
  required String origem,
  required String formaPagamento,
}) =>
    Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SmartPDV', style: MyTextStyle(size: 32)),
                    Text(origem, style: MyTextStyle(size: 32)),
                  ],
                ),
                Text(
                    viaDoEstabelecimento
                        ? 'VIA ESTABELECIMENTO'
                        : 'VIA CLIENTE',
                    style: MyTextStyle(size: 32)),
              ],
            ),
            Divider(
              height: 8,
              thickness: 10,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(formaPagamento, style: MyTextStyle(size: 32)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(dataPagamento, style: MyTextStyle(size: 32)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(cliente, style: MyTextStyle(size: 32)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('R\$ ', style: MyTextStyle(size: 32)),
                    Text(valor, style: MyTextStyle(size: 32)),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Text(origemDaAutorizacao, style: MyTextStyle(size: 32)),
            Divider(
              height: 8,
              thickness: 10,
            ),
            viaDoEstabelecimento
                ? _viaEstabelecimento(
                    empresa: empresa,
                    cnpj: cnpj,
                    codigoDaTransacao: codigoDaTransacao,
                    codigoDaVenda: codigoDaVenda,
                    nsu: nsu,
                  )
                : _viaCliente(
                    empresa: empresa,
                    cnpj: cnpj,
                    codigoDaTransacao: codigoDaTransacao,
                    codigoDaVenda: codigoDaVenda,
                    nsu: nsu,
                    endereco: endereco,
                  ),
          ],
        ));

Widget _viaEstabelecimento({
  required String empresa,
  required String cnpj,
  required String codigoDaVenda,
  required String codigoDaTransacao,
  required String nsu,
}) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(empresa, style: MyTextStyle(size: 32)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cnpj, style: MyTextStyle(size: 32)),
            Text('NSU:  ${nsu}', style: MyTextStyle(size: 32))
          ],
        ),
        Text('CV: ${codigoDaVenda}', style: MyTextStyle(size: 32)),
        Text('CT: ${codigoDaTransacao}', style: MyTextStyle(size: 32)),
      ],
    );
Widget _viaCliente({
  required String empresa,
  required String cnpj,
  required String codigoDaVenda,
  required String codigoDaTransacao,
  required String nsu,
  required String endereco,
}) =>
    Wrap(
      spacing: 16,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(endereco, style: MyTextStyle(size: 32)),
        Text(empresa, style: MyTextStyle(size: 32)),
        Text(cnpj, style: MyTextStyle(size: 32)),
        Text('NSU: ${nsu}', style: MyTextStyle(size: 32)),
        Text('CV: ${codigoDaVenda}', style: MyTextStyle(size: 32)),
        Text('CT: ${codigoDaTransacao}', style: MyTextStyle(size: 32)),
      ],
    );

class MyTextStyle extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final double size;
  final String fontFamily;

  MyTextStyle({
    this.color = Colors.black,
    this.fontWeight = FontWeight.bold,
    this.size = 16,
    this.fontFamily = 'Roboto',
  }) : super(
          color: color,
          fontWeight: fontWeight,
          fontSize: size,
          fontFamily: fontFamily,
          wordSpacing: 0.000001,
          letterSpacing: 0.00001,
        );
}

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color = Colors.black})
      : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 10.0;
          final dashHeight = height;
          final dashCount = (460 / (2 * dashWidth)).floor();
          return Flex(
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
          );
        },
      ),
    );
  }
}
