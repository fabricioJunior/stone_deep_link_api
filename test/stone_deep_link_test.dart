import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stone_deep_link/stone_deep_link.dart';
import 'package:stone_deep_link/stone_deep_link_platform_interface.dart';
import 'package:stone_deep_link/stone_deep_link_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStoneDeepLinkPlatform
    with MockPlatformInterfaceMixin
    implements StoneDeepLinkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> fazerPagamento(
    String formaDePagamento,
    int parcelas,
    int valor,
    String deepLinkReturnSchema,
  ) async {
    return;
  }

  @override
  Stream<String> get onPagamentoFinalizado => throw UnimplementedError();

  @override
  Future<void> fazerEstorno(int valor, int atk, bool permiteEditarValor) async {
    return;
  }
}

void main() {
  final StoneDeepLinkPlatform initialPlatform = StoneDeepLinkPlatform.instance;

  test('$MethodChannelStoneDeepLink is the default instance', () {
    WidgetsFlutterBinding.ensureInitialized();
    expect(initialPlatform, isInstanceOf<MethodChannelStoneDeepLink>());
  });

  test('getPlatformVersion', () async {
    StoneDeepLink stoneDeepLinkPlugin = StoneDeepLink();
    MockStoneDeepLinkPlatform fakePlatform = MockStoneDeepLinkPlatform();
    StoneDeepLinkPlatform.instance = fakePlatform;

    expect(await stoneDeepLinkPlugin.getPlatformVersion(), '42');
  });
}
