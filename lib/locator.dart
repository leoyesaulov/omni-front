import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'config.dart';
// import 'package:maap/src/analitics/appsflyer_service.dart';
// import 'package:maap/src/deeplink/deeplink.dart';
// import 'package:maap/src/features/meet/create/meet_repository.dart';
// import 'package:maap/pkg/dialogs/dialogs.dart';
// import 'package:maap/pkg/services/push_notify.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:maap/pkg/auth/svc/repo.dart';
// import 'package:maap/pkg/config/config.dart';
// import 'package:maap/pkg/services/device.dart';
// import 'package:maap/pkg/websocket/websocket.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final config = AppConfig(
    ssl: false,
    baseUrl: const String.fromEnvironment('url', defaultValue: 'localhost:8080'),
  );

  var sharedPrefs = await SharedPreferences.getInstance();
  var ws = WebsocketImpl();
  var navkey = GlobalKey<NavigatorState>();
  var dg = Dialogs(navkey);

  locator.registerSingleton(navkey);
  locator.registerSingleton<MeetRepository>(MeetRepository());
  locator.registerSingleton<AppConfig>(config);
  locator.registerSingleton<Websocket>(ws);
  var authRepo = AuthRepoImpl(sharedPrefs);
  locator.registerSingleton<AuthRepo>(authRepo);
  locator.registerSingleton(WebsocketConnector(
    authRepo,
    ws,
    Device(),
    PushNotifications(),
    config.ws,
  ));
  locator.registerLazySingleton<DynamicLinkService>(
          () => DynamicLinkService(ws, dg));
  locator.registerSingleton(AppsFlyerService());
}
