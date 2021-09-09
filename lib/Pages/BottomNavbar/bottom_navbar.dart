import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/ConfigurationPage/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Pages/PlanningListPage/index.dart';
import 'package:legatus/Pages/ReportListPage/report_list_page.dart';
import 'package:legatus/Pages/ReportPage/index.dart';
import 'package:legatus/Providers/index.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class BottomNavbar extends StatefulWidget {
  final int? currentTab;

  BottomNavbar({Key? key, this.currentTab}) : super(key: key);

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar>
    with SingleTickerProviderStateMixin {
  /// Responsive design variables
  double? deviceWidth;
  double? deviceHeight;
  double? statusbarHeight;
  double? bottomBarHeight;
  double? appbarHeight;
  double? widthDp;
  double? heightDp;
  double? fontSp;

  String responsiveStyle = "";
  double iconSize = 0;
  double iconPadding = 0;
  TextStyle? textStyle;
  double navBarHeight = 0;
  ///////////////////////////////

  PersistentTabController? _controller;

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

    _controller = PersistentTabController(initialIndex: 0);

    AppDataProvider.of(context).setAppDataState(
      AppDataProvider.of(context).appDataState.update(
            bottomTabController: _controller,
          ),
      isNotifiable: false,
    );

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      try {
        bool camera = await Permission.camera.isGranted;
        if (!camera) await Permission.camera.request();
        bool microphone = await Permission.microphone.isGranted;
        if (!microphone) await Permission.microphone.request();
        bool storage = await Permission.storage.isGranted;
        if (!storage) await Permission.storage.request();
        LocationPermission locationPermission =
            await Geolocator.checkPermission();
        if (locationPermission == LocationPermission.denied ||
            locationPermission == LocationPermission.deniedForever) {
          await Geolocator.requestPermission();
        }
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size? designSize;
    if (MediaQuery.of(context).size.width >=
        ResponsiveDesignSettings.tableteMaxWidth) {
      designSize = Size(ResponsiveDesignSettings.desktopDesignWidth,
          ResponsiveDesignSettings.desktopDesignHeight);
    } else if (MediaQuery.of(context).size.width >=
            ResponsiveDesignSettings.mobileMaxWidth &&
        MediaQuery.of(context).size.width <
            ResponsiveDesignSettings.tableteMaxWidth) {
      designSize = Size(ResponsiveDesignSettings.tabletDesignWidth,
          ResponsiveDesignSettings.tabletDesignHeight);
    } else if (MediaQuery.of(context).size.width <
        ResponsiveDesignSettings.mobileMaxWidth) {
      designSize = Size(ResponsiveDesignSettings.mobileDesignWidth,
          ResponsiveDesignSettings.mobileDesignHeight);
    }

    ScreenUtil.init(
      BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height),
      designSize: designSize!,
      orientation: Orientation.portrait,
    );

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

    if (MediaQuery.of(context).size.width >=
        ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "desktop";
    } else if (MediaQuery.of(context).size.width >=
            ResponsiveDesignSettings.mobileMaxWidth &&
        MediaQuery.of(context).size.width <
            ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "tablet";
    } else if (MediaQuery.of(context).size.width <
        ResponsiveDesignSettings.mobileMaxWidth) {
      responsiveStyle = "mobile";
    }

    iconSize = heightDp! * 20;
    iconPadding = widthDp! * 10;
    textStyle = Theme.of(context).textTheme.overline;
    navBarHeight = kBottomNavigationBarHeight;

    if (responsiveStyle != "mobile") {
      navBarHeight = heightDp! * 80;
      iconSize = heightDp! * 35;
      iconPadding = widthDp! * 20;
      textStyle =
          Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
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
      child: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        navBarHeight: navBarHeight,
        backgroundColor: AppColors.primayColor,
        handleAndroidBackButtonPress: false, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: false, // Default is true.
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.zero,
          colorBehindNavBar: Colors.white,
        ),
        padding: NavBarPadding.symmetric(vertical: heightDp! * 5),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style8, // Choose the nav bar style with this property.
        onItemSelected: (int index) {
          LocalReportListProvider.of(context).setLocalReportListState(
            LocalReportListProvider.of(context).localReportListState.update(
                  localReportModel: LocalReportModel(),
                ),
            isNotifiable: false,
          );
        },
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      PlanningListPage(),
      ReportListPage(),
      ConfigurationPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      // PersistentBottomNavBarItem(
      //   icon: Material(
      //     color: Colors.transparent,
      //     child: Column(
      //       children: [
      //         Icon(Icons.event, size: heightDp! * 10, color: Colors.white),
      //         Text(
      //           LocaleKeys.BottomNavBarString_planning.tr(),
      //           style: TextStyle(fontSize: fontSp! * 10, color: Colors.white),
      //         ),
      //       ],
      //     ),
      //   ),
      //   inactiveIcon: Material(
      //     color: Colors.transparent,
      //     child: Column(
      //       children: [
      //         Icon(Icons.event_outlined, size: heightDp! * 10, color: Colors.white),
      //         Text(
      //           LocaleKeys.BottomNavBarString_planning.tr(),
      //           style: TextStyle(fontSize: fontSp! * 10, color: Colors.white),
      //         ),
      //       ],
      //     ),
      //   ),
      //   // inactiveIcon: Icon(Icons.event_outlined),
      //   // title: LocaleKeys.BottomNavBarString_planning.tr(),
      //   activeColorPrimary: Colors.white,
      //   inactiveColorPrimary: Colors.white.withOpacity(0.6),
      //   contentPadding: heightDp! * 0,
      //   // iconSize: heightDp! * 25,
      //   // textStyle: TextStyle(fontSize: fontSp! * 10, color: Colors.white),
      // ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.event),
        inactiveIcon: Icon(Icons.event_outlined),
        title: LocaleKeys.BottomNavBarString_planning.tr(),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white.withOpacity(0.6),
        contentPadding: heightDp! * 5,
        iconSize: iconSize,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.perm_media),
        inactiveIcon: Icon(Icons.perm_media_outlined),
        title: LocaleKeys.BottomNavBarString_reports.tr(),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white.withOpacity(0.6),
        contentPadding: heightDp! * 5,
        iconSize: iconSize,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.app_settings_alt),
        inactiveIcon: Icon(Icons.app_settings_alt_outlined),
        title: LocaleKeys.BottomNavBarString_configration.tr(),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white.withOpacity(0.6),
        contentPadding: heightDp! * 5,
        iconSize: iconSize,
        textStyle: textStyle,
      ),
    ];
  }
}
