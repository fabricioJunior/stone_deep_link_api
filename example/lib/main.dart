import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:millimeters/millimeters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_pag_contract/smart_pag_handler.dart';
import 'package:stone_deep_link/stone_deep_link.dart';
import 'package:stone_deep_link/stone_deep_link_platform_interface.dart';

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
      children: [
        Text('teste', style: Theme.of(context).textTheme.displayLarge),
      ],
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MySecodPage(),
      ),
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
                child: const Text('Acessar segunda pagina',
                    style: TextStyle(fontSize: 20)),
              ),
              WidgetSize(
                child: comprovante(
                    viaDoEstabelecimento: false,
                    dataPagamento: '14/12/2024',
                    valor: '10,00',
                    cliente: 'Sem cadastro',
                    origemDaAutorizacao: 'mastercard',
                    empresa: 'use por onde flor',
                    endereco: 'rua samuel santos, 1933, loja 03, pindorama',
                    cnpj: '1234124/0001-12',
                    codigoDaVenda: '2024',
                    codigoDaTransacao: '4202',
                    nsu: '431231231',
                    origem: 'Parnaíba',
                    formaPagamento: 'PIXÃO'),
              )
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
        'imagePath': content,
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

Future<void> imprimirNfc(
  BuildContext context,
  String empresa,
  String endereco,
  String fone,
  String cnpj,
  String inscricaoEstadual,
  String inscricaoMunicipal,
  String email,
  String quantidadeTotalDeItens,
  String valorTotal,
  String valorPagar,
  String tributos,
  String numeroDaNota,
  String numeroSerie,
  String dataEmissao,
  String urlConsulta,
  String numeroNota,
  String protocoloDeAutorizacao,
  String dataEHoraAutorizacao,
  String? informacaoConsumidor,
  String qrCode,
  String urlLogo,
  String obs,
  String desconto,
) =>
    imprimirNfcWithNameParameters(
      context: context,
      empresa: empresa,
      endereco: endereco,
      fone: fone,
      cnpj: cnpj,
      inscricaoEstadual: inscricaoEstadual,
      inscricaoMunicipal: inscricaoMunicipal,
      email: email,
      quantidadeTotalDeItens: quantidadeTotalDeItens,
      valorTotal: valorTotal,
      valorPagar: valorPagar,
      tributos: tributos,
      numeroDaNota: numeroDaNota,
      numeroSerie: numeroSerie,
      dataEmissao: dataEmissao,
      urlConsulta: urlConsulta,
      numeroNota: numeroNota,
      protocoloDeAutorizacao: protocoloDeAutorizacao,
      dataEHoraAutorizacao: dataEHoraAutorizacao,
      informacaoConsumidor: informacaoConsumidor,
      qrCode: qrCode,
      urlLogo: urlLogo,
      obs: obs,
      desconto: desconto,
    );

Future<void> imprimirNfcWithNameParameters({
  required BuildContext context,
  required String empresa,
  required String endereco,
  required String fone,
  required String cnpj,
  required String inscricaoEstadual,
  required String inscricaoMunicipal,
  required String email,
  required String quantidadeTotalDeItens,
  required String valorTotal,
  required String valorPagar,
  required String tributos,
  required String numeroDaNota,
  required String numeroSerie,
  required String dataEmissao,
  required String urlConsulta,
  required String numeroNota,
  required String protocoloDeAutorizacao,
  required String dataEHoraAutorizacao,
  required String? informacaoConsumidor,
  required String qrCode,
  required String urlLogo,
  required String obs,
  required String desconto,
}) async {
  await imprimirFromWidget(
    context,
    NfcWidget(
      empresa: empresa,
      endereco: endereco,
      fone: fone,
      cnpj: cnpj,
      inscricaoEstadual: inscricaoEstadual,
      inscricaoMunicipal: inscricaoMunicipal,
      email: email,
      quantidadeTotalDeItens: quantidadeTotalDeItens,
      valorTotal: valorTotal,
      valorPagar: valorPagar,
      tributos: tributos,
      numeroDaNota: numeroDaNota,
      numeroSerie: numeroSerie,
      dataEmissao: dataEmissao,
      urlConsulta: urlConsulta,
      numeroNota: numeroNota,
      protocoloDeAutorizacao: protocoloDeAutorizacao,
      dataEHoraAutorizacao: dataEHoraAutorizacao,
      qrCode: qrCode,
      desconto: desconto,
      obs: obs,
      informacaoConsumidor: informacaoConsumidor,
    ),
  );
}

class NfcWidget extends StatelessWidget {
  final String empresa;
  final String endereco;
  final String fone;
  final String cnpj;
  final String inscricaoEstadual;
  final String inscricaoMunicipal;
  final String email;
  final String quantidadeTotalDeItens;

  final String valorTotal;
  final String valorPagar;

  final String tributos;
  final String numeroDaNota;
  final String numeroSerie;
  final String dataEmissao;
  final String urlConsulta;
  final String numeroNota;
  final String protocoloDeAutorizacao;
  final String dataEHoraAutorizacao;
  final String? informacaoConsumidor;
  final String qrCode;
  final Uint8List? logo;
  final String obs;
  final String desconto;

  const NfcWidget({
    super.key,
    required this.empresa,
    required this.endereco,
    required this.fone,
    required this.cnpj,
    required this.inscricaoEstadual,
    required this.inscricaoMunicipal,
    required this.email,
    required this.quantidadeTotalDeItens,
    required this.valorTotal,
    required this.valorPagar,
    required this.tributos,
    required this.numeroDaNota,
    required this.numeroSerie,
    required this.dataEmissao,
    required this.urlConsulta,
    required this.numeroNota,
    required this.protocoloDeAutorizacao,
    required this.dataEHoraAutorizacao,
    this.informacaoConsumidor,
    required this.qrCode,
    required this.obs,
    required this.desconto,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (logo != null)
          SizedBox(width: 100, height: 100, child: Image.memory(logo!)),
        const SizedBox(
          height: 2,
        ),
        _empresaInfos(
          empresa: empresa,
          endereco: endereco,
          fone: fone,
          cnpj: cnpj,
          inscricaoEstadual: inscricaoEstadual,
          inscricaoMunicipal: inscricaoMunicipal,
          email: email,
        ),
        const MySeparator(
          height: 2,
        ),
        Text(
          'Documento Auxiliar da Nota Fiscal de Consumidor Eletrônica',
          textAlign: TextAlign.center,
          style: MyTextStyle(),
        ),
        const MySeparator(
          height: 2,
        ),
        const MySeparator(
          height: 2,
        ),
        _totais(
          valorTotal: valorTotal,
          valorPagar: valorPagar,
          desconto: desconto,
          quantidadeTotalDeItens: quantidadeTotalDeItens,
        ),
        const MySeparator(
          height: 2,
        ),
        const MySeparator(
          height: 2,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 8,
              children: [
                Text(
                  'Número ${numeroDaNota}',
                  style: MyTextStyle(),
                ),
                Text(
                  'Série ${numeroSerie}',
                  style: MyTextStyle(),
                ),
              ],
            ),
            Text(
              'Emissão',
              style: MyTextStyle(
                size: 24,
              ),
            ),
            Text(
              '${dataEmissao}',
              style: MyTextStyle(
                size: 24,
              ),
            ),
            Text(
              'Consulte pela Chave de Acesso em',
              textAlign: TextAlign.center,
              style: MyTextStyle(),
            ),
            Text(
              urlConsulta,
              textAlign: TextAlign.center,
              style: MyTextStyle(),
            ),
            Text(
              numeroNota,
              textAlign: TextAlign.center,
              style: MyTextStyle(),
            ),
            Text(
              'Protocolo de Autorização: ${protocoloDeAutorizacao}',
              textAlign: TextAlign.center,
              style: MyTextStyle(),
            ),
            Text(
              dataEHoraAutorizacao,
              textAlign: TextAlign.center,
              style: MyTextStyle(),
            ),
          ],
        ),
        const MySeparator(
          height: 2,
        ),
        if (informacaoConsumidor == null)
          Text(
            'CONSUMIDOR NÃO IDENTIFICADO',
            textAlign: TextAlign.center,
            style: MyTextStyle(),
          ),
        if (informacaoConsumidor != null)
          Text(
            informacaoConsumidor!,
            textAlign: TextAlign.center,
            style: MyTextStyle(),
          ),
        const MySeparator(
          height: 2,
        ),
        Text(
          tributos,
          style: MyTextStyle(),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          obs,
          style: MyTextStyle(
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _empresaInfos({
    required String empresa,
    required String endereco,
    required String fone,
    required String cnpj,
    required String inscricaoEstadual,
    required String inscricaoMunicipal,
    required String email,
  }) =>
      Column(
        children: [
          Text(
            empresa,
            style: MyTextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            endereco,
            textAlign: TextAlign.center,
            style: MyTextStyle(),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            fone,
            textAlign: TextAlign.center,
            style: MyTextStyle(),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'CNPJ: ${cnpj}',
            textAlign: TextAlign.center,
            style: MyTextStyle(),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Inscrição Estadual: ${inscricaoEstadual}',
            textAlign: TextAlign.center,
            style: MyTextStyle(),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Inscrição Municipal: ${inscricaoMunicipal}',
            textAlign: TextAlign.center,
            style: MyTextStyle(),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            email,
            textAlign: TextAlign.center,
            style: MyTextStyle(),
          ),
        ],
      );

  Widget _totais({
    required String valorTotal,
    required String valorPagar,
    required String desconto,
    required String quantidadeTotalDeItens,
  }) =>
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qtd. total de itens',
                style: MyTextStyle(),
              ),
              Text(quantidadeTotalDeItens, style: MyTextStyle()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valor total',
                style: MyTextStyle(),
              ),
              Text(
                valorTotal,
                style: MyTextStyle(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Desconto',
                style: MyTextStyle(),
              ),
              Text(
                desconto,
                style: MyTextStyle(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valor a pagar',
                style: MyTextStyle(
                  fontWeight: FontWeight.bold,
                  size: 20,
                ),
              ),
              Text(
                valorPagar,
                style: MyTextStyle(
                  fontWeight: FontWeight.bold,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      );
}

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

class MySecodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segunda pagina'),
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('esta é a segunda pagina'),
          ElevatedButton(
            onPressed: () async {
              await imprimirNfc(
                context,
                'empresa',
                'endereco',
                'fone',
                'cnpj',
                'inscricao',
                'municiapl',
                'email',
                '231',
                '100',
                '1231',
                '1231',
                '',
                '',
                'dataEmissao',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
              );
              await StoneDeepLinkPlatform.instance.imprimirArquivo();
            },
            child: Text('chamar impressora'),
          )
        ],
      )),
    );
  }
}

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

  imprimirFromWidget(
    context,
    comprovante(
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
    ),
  );
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
                    Text('SmartPDV',
                        style: MyTextStyle(
                          size: 32,
                        )),
                    Text(
                      origem,
                      style: MyTextStyle(
                        size: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  viaDoEstabelecimento ? 'VIA ESTABELECIMENTO' : 'VIA CLIENTE',
                  style: MyTextStyle(
                    size: 16,
                  ),
                ),
              ],
            ),
            Divider(
              height: 8,
              thickness: 10,
              color: Colors.black,
            ),
            SizedBox(height: 08),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formaPagamento,
                  style: MyTextStyle(
                    size: 24,
                  ),
                ),
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
                        Text(
                          dataPagamento,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          cliente,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('R\$ ',
                        style: MyTextStyle(
                          size: 16,
                        )),
                    Text(valor,
                        style: MyTextStyle(
                          size: 40,
                        )),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Text(origemDaAutorizacao,
                style: MyTextStyle(
                  size: 16,
                )),
            Divider(
              height: 8,
              thickness: 10,
              color: Colors.black,
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
            Text(empresa,
                style: MyTextStyle(
                  size: 16,
                )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cnpj,
                style: MyTextStyle(
                  size: 16,
                )),
            Text('NSU:  ${nsu}',
                style: MyTextStyle(
                  size: 16,
                ))
          ],
        ),
        Text('CV: ${codigoDaVenda}',
            style: MyTextStyle(
              size: 16,
            )),
        Text('CT: ${codigoDaTransacao}',
            style: MyTextStyle(
              size: 16,
            )),
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
        Text(endereco,
            style: MyTextStyle(
              size: 16,
            )),
        Text(empresa,
            style: MyTextStyle(
              size: 16,
            )),
        Text(cnpj,
            style: MyTextStyle(
              size: 16,
            )),
        Text('NSU: ${nsu}',
            style: MyTextStyle(
              size: 16,
            )),
        Text('CV: ${codigoDaVenda}',
            style: MyTextStyle(
              size: 16,
            )),
        Text('CT: ${codigoDaTransacao}',
            style: MyTextStyle(
              size: 16,
            )),
      ],
    );

class WidgetSize extends StatelessWidget {
  final Widget? child;

  const WidgetSize({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return SizeWidget(
      child: child ?? const SizedBox(),
    );
  }
}

class SizeWidget extends StatefulWidget {
  final Widget child;

  const SizeWidget({super.key, required this.child});
  @override
  // ignore: library_private_types_in_public_api
  _SizeWidgetState createState() => _SizeWidgetState();
}

class _SizeWidgetState extends State<SizeWidget> {
  final GlobalKey _textKey = GlobalKey();
  Size? textSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
  }

  void getSizeAndPosition() {
    var d = _textKey.currentContext!.size;

    setState(() {
      textSize = d;
    });
  }

  @override
  Widget build(BuildContext context) {
    MillimetersData data = getMillimetersData(context);
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            getSizeAndPosition();
          },
          child: const Text('verificar tamanho'),
        ),
        Text(
          '${data.pixelToMM(textSize?.width)}, ${data.pixelToMM(textSize?.height)}',
        ),
        Container(
          key: _textKey,
          child: widget.child,
        ),
      ],
    );
  }

  MillimetersData getMillimetersData(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var resolution = Size(width, height);

    var physical = Size(43, height);
    var data = MillimetersData(physical: physical, resolution: resolution);
    return data;
  }
}

extension PixelToMm on MillimetersData {
  double? pixelToMM(double? pixel) =>
      pixel == null ? null : (pixel * devicePixelRatio) / mmPerPixel;
}
