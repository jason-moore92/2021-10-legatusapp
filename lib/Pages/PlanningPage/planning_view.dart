import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Components/index.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class PlanningView extends StatefulWidget {
  final PersistentTabController? bottomTabController;

  PlanningView({Key? key, this.bottomTabController}) : super(key: key);

  @override
  _PlanningViewState createState() => _PlanningViewState();
}

class _PlanningViewState extends State<PlanningView> with SingleTickerProviderStateMixin {
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

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, authProvider, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.PlanningPageString_appbarTitle.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
          actions: [
            if (authProvider.authState.loginState == LoginState.IsLogin)
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.history, size: heightDp! * 25, color: Colors.white),
              ),
          ],
        ),
        body: (authProvider.authState.loginState == LoginState.IsNotLogin) ? _logoutPanel() : _loginPanel(),
      );
    });
  }

  Widget _logoutPanel() {
    return Center(
      child: Container(
        width: heightDp! * 180,
        height: deviceHeight,
        padding: EdgeInsets.symmetric(horizontal: widthDp! * 20, vertical: heightDp! * 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAsssets.logoGreyImage, width: heightDp! * 130, height: heightDp! * 180, fit: BoxFit.cover),
            SizedBox(height: heightDp! * 20),
            Text(
              LocaleKeys.PlanningPageString_login_description.tr(),
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: heightDp! * 20),
            CustomTextButton(
              text: LocaleKeys.PlanningPageString_login_button.tr().toUpperCase(),
              textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
              width: widthDp! * 150,
              bordercolor: AppColors.yello,
              borderRadius: heightDp! * 6,
              elevation: 0,
              onPressed: () {
                widget.bottomTabController!.jumpToTab(2);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginPanel() {
    return Container(
      width: deviceWidth,
      height: deviceHeight,
    );
  }
}
