import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:legatus/Models/LocalReportModel.dart';
import 'package:legatus/Models/MediaModel.dart';
import 'package:legatus/Models/SettingsModel.dart';
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
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light, //status bar brigtness
    ));
  }

  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(LocalReportModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());
  Hive.registerAdapter(MediaModelAdapter());

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
}
