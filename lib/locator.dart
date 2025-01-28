import 'package:get_it/get_it.dart';
import 'package:omni_front/ws_impl.dart';
import 'config.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final config = AppConfig(
    ssl: false,
    baseUrl: const String.fromEnvironment('url', defaultValue: 'localhost:8080'),
  );

  locator.registerSingleton<AppConfig>(config);

  var ws = WebSocket();
  locator.registerSingleton<WebSocket>(ws);
}
