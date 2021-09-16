import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Pages/Dialogs/normal_dialog.dart';
import 'package:legatus/Pages/SplashPage/splash_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:legatus/Providers/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import './index.dart';
import 'fallback_cupertino.dart';

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
        ChangeNotifierProvider(create: (_) => LocalReportListProvider()),
        ChangeNotifierProvider(create: (_) => LocalReportProvider()),
        ChangeNotifierProvider(create: (_) => PlanningProvider()),
        ChangeNotifierProvider(create: (_) => MediaPlayProvider()),
      ],
      child: ScreenUtilInit(
        designSize: Size(ResponsiveDesignSettings.mobileDesignWidth,
            ResponsiveDesignSettings.mobileDesignHeight),
        builder: () {
          return MaterialApp(
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              EasyLocalization.of(context)!.delegate,
              RefreshLocalizations.delegate,
              const FallbackCupertinoLocalisationsDelegate(),
            ],
            supportedLocales: EasyLocalization.of(context)!.supportedLocales,
            locale: EasyLocalization.of(context)!.locale,
            // localizationsDelegates: context.localizationDelegates,
            // supportedLocales: context.supportedLocales,
            // locale: context.locale,
            theme: buildLightTheme(context),
            // themeMode: ThemeMode.dark,
            home: SplashPage(),
            builder: (context, child) {
              return StreamBuilder<BridgeState>(
                stream: BridgeProvider().getStream(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    print(snapshot.data!.event);
                  }
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.event == "log_out") {
                    BridgeProvider().update(
                      BridgeState(
                        event: "init",
                        data: {
                          "message": "init",
                        },
                      ),
                    );

                    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                      AuthProvider.of(navigatorKey.currentContext!)
                          .logout(context)
                          .then((value) {
                        try {
                          FailedDialog.show(
                            navigatorKey.currentContext!,
                            text: snapshot.data!.data!["message"] ??
                                "Your account logout",
                          );
                        } catch (e) {
                          print(e);
                        }
                      });
                    });
                  }
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}
