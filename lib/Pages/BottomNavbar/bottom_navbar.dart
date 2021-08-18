import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/ConfigurationPage/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:legutus/Pages/PlanningListPage/index.dart';
import 'package:legutus/Pages/ReportListPage/report_list_page.dart';
import 'package:legutus/Providers/index.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomNavbar extends StatefulWidget {
  final int? currentTab;

  BottomNavbar({Key? key, this.currentTab}) : super(key: key);

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> with SingleTickerProviderStateMixin {
  /// Responsive design variables
  double? deviceWidth;
  double? deviceHeight;
  double? statusbarHeight;
  double? bottomBarHeight;
  double? appbarHeight;
  double? widthDp;
  double? heightDp;
  double? fontSp;
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
      // Map<Permission, PermissionStatus> statuses = await [
      //   Permission.camera,
      //   Permission.microphone,
      //   Permission.location,
      //   Permission.storage,
      // ].request();
      bool camera = await Permission.camera.isGranted;
      if (!camera) await Permission.camera.request();
      bool microphone = await Permission.microphone.isGranted;
      if (!microphone) await Permission.microphone.request();
      bool storage = await Permission.storage.isGranted;
      if (!storage) await Permission.storage.request();
      LocationPermission locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied || locationPermission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppColors.primayColor,
        handleAndroidBackButtonPress: false, // Default is true.
        resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: false, // Default is true.
        hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
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
        navBarStyle: NavBarStyle.style8, // Choose the nav bar style with this property.
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
      PersistentBottomNavBarItem(
        icon: Icon(Icons.event),
        inactiveIcon: Icon(Icons.event_outlined),
        title: LocaleKeys.BottomNavBarString_planning.tr(),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.perm_media),
        inactiveIcon: Icon(Icons.perm_media_outlined),
        title: LocaleKeys.BottomNavBarString_reports.tr(),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.app_settings_alt),
        inactiveIcon: Icon(Icons.app_settings_alt_outlined),
        title: LocaleKeys.BottomNavBarString_configration.tr(),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white.withOpacity(0.6),
      ),
    ];
  }
}
