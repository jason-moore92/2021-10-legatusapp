import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Pages/SplashPage/splash_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:legutus/Providers/index.dart';
import 'package:provider/provider.dart';

import './index.dart';
import 'fallback_cupertino.dart';

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
        ChangeNotifierProvider(create: (_) => LocalReportListProvider()),
        ChangeNotifierProvider(create: (_) => PlanningProvider()),
      ],
      child: ScreenUtilInit(
        designSize: Size(ResponsiveDesignSettings.mobileDesignWidth, ResponsiveDesignSettings.mobileDesignHeight),
        builder: () {
          return MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            // localizationsDelegates: [
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   EasyLocalization.of(context)!.delegate,
            //   const FallbackCupertinoLocalisationsDelegate(),
            // ],
            // supportedLocales: EasyLocalization.of(context).supportedLocales,
            // locale: EasyLocalization.of(context).locale,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: buildLightTheme(context),
            // themeMode: ThemeMode.dark,
            home: SplashPage(),
          );
        },
      ),
    );
  }
}
