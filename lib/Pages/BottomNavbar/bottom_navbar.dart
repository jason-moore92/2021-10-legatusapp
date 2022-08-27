import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/ConfigurationPage/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Pages/PlanningListPage/index.dart';
import 'package:legatus/Pages/ReportListPage/report_list_page.dart';
import 'package:legatus/Providers/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class BottomNavbar extends StatefulWidget {
  final int? currentTab;

  const BottomNavbar({Key? key, this.currentTab}) : super(key: key);

  @override
  BottomNavbarState createState() => BottomNavbarState();
}

class BottomNavbarState extends State<BottomNavbar> with SingleTickerProviderStateMixin {
  /// Responsive design variables
  double deviceWidth = 0;
  double deviceHeight = 0;
  double statusbarHeight = 0;
  double bottomBarHeight = 0;
  double appbarHeight = 0;
  double widthDp = 0;
  double heightDp = 0;
  double fontSp = 0;

  String responsiveStyle = "";
  double iconSize = 0;
  TextStyle? textStyle;
  double navBarHeight = 0;
  ///////////////////////////////

  @override
  void initState() {
    super.initState();

    /// Responsive design variables
    deviceWidth = 1.sw;
    deviceHeight = 1.sh;
    statusbarHeight = ScreenUtil().statusBarHeight;
    bottomBarHeight = ScreenUtil().bottomBarHeight;
    appbarHeight = AppBar().preferredSize.height;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size? designSize;
    if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.tableteMaxWidth) {
      designSize = Size(ResponsiveDesignSettings.desktopDesignWidth, ResponsiveDesignSettings.desktopDesignHeight);
    } else if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.mobileMaxWidth &&
        MediaQuery.of(context).size.width < ResponsiveDesignSettings.tableteMaxWidth) {
      designSize = Size(ResponsiveDesignSettings.tabletDesignWidth, ResponsiveDesignSettings.tabletDesignHeight);
    } else if (MediaQuery.of(context).size.width < ResponsiveDesignSettings.mobileMaxWidth) {
      designSize = Size(ResponsiveDesignSettings.mobileDesignWidth, ResponsiveDesignSettings.mobileDesignHeight);
    }

    ScreenUtil.init(
      context,
      designSize: designSize!,
    );
    // in flutter_screenutil: ^5.3.1
    // ScreenUtil.init(
    //   BoxConstraints(maxWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height),
    //   designSize: designSize!,
    //   orientation: Orientation.portrait,
    //   context: context,
    // );

    /// Responsive design variables
    deviceWidth = 1.sw;
    deviceHeight = 1.sh;
    statusbarHeight = ScreenUtil().statusBarHeight;
    bottomBarHeight = ScreenUtil().bottomBarHeight;
    appbarHeight = AppBar().preferredSize.height;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    // ScreenUtil.init(
    //   BoxConstraints(maxWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height),
    //   designSize: Size(ResponsiveDesignSettings.mobileDesignWidth, ResponsiveDesignSettings.mobileDesignHeight),
    //   orientation: Orientation.portrait,
    // );

    // /// Responsive design variables
    // deviceWidth = 1.sw;
    // deviceHeight = 1.sh;
    // statusbarHeight = ScreenUtil().statusBarHeight;
    // bottomBarHeight = ScreenUtil().bottomBarHeight;
    // appbarHeight = AppBar().preferredSize.height;
    // widthDp = ScreenUtil().setWidth(1);
    // heightDp = ScreenUtil().setWidth(1);
    // fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    // ///////////////////////////////

    if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "desktop";
    } else if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.mobileMaxWidth &&
        MediaQuery.of(context).size.width < ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "tablet";
    } else if (MediaQuery.of(context).size.width < ResponsiveDesignSettings.mobileMaxWidth) {
      responsiveStyle = "mobile";
    }

    iconSize = heightDp * 22;
    textStyle = Theme.of(context).textTheme.overline;
    navBarHeight = kBottomNavigationBarHeight;

    if (responsiveStyle != "mobile") {
      navBarHeight = heightDp * 80;
      iconSize = heightDp * 32;
      textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
    }

    return Consumer<AppDataProvider>(builder: (context, appDataProvider, _) {
      Widget body = const SizedBox();

      switch (appDataProvider.appDataState.bottomIndex) {
        case 0:
          body = const PlanningListPage();
          break;
        case 1:
          body = const ReportListPage();
          break;
        case 2:
          body = const ConfigurationPage();
          break;
        default:
      }
      return WillPopScope(
        onWillPop: () async {
          NormalAskDialog.show(
            context,
            content: "Voulez-vous quitter l'application ?",
            okButton: "Quitter",
            cancelButton: "Annuler",
            callback: () {
              SystemNavigator.pop();
            },
          );
          return false;
        },
        child: Scaffold(
          body: body,
          bottomNavigationBar: BottomNavigationBar(
            elevation: 1,
            onTap: (value) {
              if (value != appDataProvider.appDataState.bottomIndex) {
                appDataProvider.setAppDataState(
                  appDataProvider.appDataState.update(bottomIndex: value),
                );
                if (value == 0) {
                  // if (PlanningProvider.of(context).planningState.progressState == 0 &&
                  //     AuthProvider.of(context).authState.loginState == LoginState.isLogin) {
                  // if (AuthProvider.of(context).authState.loginState == LoginState.isLogin) {
                  //   PlanningProvider.of(context).setPlanningState(
                  //     PlanningProvider.of(context).planningState.update(
                  //           progressState: 1,
                  //         ),
                  //   );
                  //   PlanningProvider.of(context).getPlanningList();
                  // }
                }
              }
            },
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            currentIndex: appDataProvider.appDataState.bottomIndex!,
            showSelectedLabels: true,
            selectedLabelStyle: textStyle,
            unselectedLabelStyle: textStyle,
            iconSize: iconSize,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.primayColor,
            items: [
              BottomNavigationBarItem(
                label: LocaleKeys.BottomNavBarString_planning.tr(),
                icon: Padding(
                  padding: EdgeInsets.all(heightDp * 5.0),
                  child: const Icon(Icons.event_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.all(heightDp * 5.0),
                  child: const Icon(Icons.event),
                ),
              ),
              BottomNavigationBarItem(
                label: LocaleKeys.BottomNavBarString_reports.tr(),
                icon: Padding(
                  padding: EdgeInsets.all(heightDp * 5.0),
                  child: const Icon(Icons.perm_media_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.all(heightDp * 5.0),
                  child: const Icon(Icons.perm_media),
                ),
              ),
              BottomNavigationBarItem(
                label: LocaleKeys.BottomNavBarString_configration.tr(),
                icon: Padding(
                  padding: EdgeInsets.all(heightDp * 5.0),
                  child: const Icon(Icons.app_settings_alt_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.all(heightDp * 5.0),
                  child: const Icon(Icons.app_settings_alt),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
