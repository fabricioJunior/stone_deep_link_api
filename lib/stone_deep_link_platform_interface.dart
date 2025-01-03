import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:stone_deep_link/stone_deep_link.dart';

import 'stone_deep_link_method_channel.dart';

abstract class StoneDeepLinkPlatform extends PlatformInterface {
  /// Constructs a StoneDeepLinkPlatform.
  StoneDeepLinkPlatform() : super(token: _token);

  static final Object _token = Object();

  static StoneDeepLinkPlatform _instance = MethodChannelStoneDeepLink();

  /// The default instance of [StoneDeepLinkPlatform] to use.
  ///
  /// Defaults to [MethodChannelStoneDeepLink].
  static StoneDeepLinkPlatform get instance => _instance;

  Stream<String> get onPagamentoFinalizado;

  Future<void> imprimirArquivo();

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StoneDeepLinkPlatform] when
  /// they register themselves.
  static set instance(StoneDeepLinkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();

  Future<String> getSerial();

  Future<void> fazerPagamento(
    String formaDePagamento,
    int parcelas,
    int valor,
    String deepLinkReturnSchema,
    FormaDeCobrancaDeJuros formaDeCobrancaDeJuros,
  );

  Future<void> fazerEstorno(
    int valor,
    int atk,
    bool permiteEditarValor,
  );
}
