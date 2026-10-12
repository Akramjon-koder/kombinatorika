import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/helpers/shared_service.dart';
import 'web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean path-based URLs (`/city`, `/problem/3`) — no `/#/` hash prefix.
  usePathUrlStrategy();

  final pref = await SharedPrefService.initialize();

  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
    supportedLocales: const [Locale('uz')],
    path: 'assets/translations',
    fallbackLocale: const Locale('uz'),
    startLocale: const Locale('uz'),
    child: WebApp(pref: pref),
  ));
}
