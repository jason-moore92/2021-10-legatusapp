import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'Config/config.dart';
import 'Pages/App/Styles/index.dart';
import 'Pages/App/app.dart';

void main() async {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    // await SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primayColor,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark, //status bar brigtness
    ));
  }

  await EasyLocalization.ensureInitialized();

  runZonedGuarded(() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = AppConfig.dsn;
      },
    );
    runApp(
      EasyLocalization(
        useOnlyLangCode: true,
        useFallbackTranslations: true,
        supportedLocales: [
          Locale('en', 'US'),
          Locale('fr', 'FR'),
        ],
        path: 'lib/Assets/Langs',
        startLocale: Locale('fr', 'FR'),
        fallbackLocale: Locale('en', 'US'),
        child: App(),
      ),
    );
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
