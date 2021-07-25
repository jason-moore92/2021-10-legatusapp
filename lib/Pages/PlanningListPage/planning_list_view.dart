import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Components/index.dart';
import 'package:legutus/Pages/ErrorPage/error_page.dart';
import 'package:legutus/Pages/PlanningListPage/Components/index.dart';
import 'package:legutus/Pages/PlanningPage/index.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PlanningListView extends StatefulWidget {
  final PersistentTabController? bottomTabController;

  PlanningListView({Key? key, this.bottomTabController}) : super(key: key);

  @override
  _PlanningListViewState createState() => _PlanningListViewState();
}

class _PlanningListViewState extends State<PlanningListView> with SingleTickerProviderStateMixin {
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

  String? startDate;

  PlanningProvider? _planningProvider;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

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

    _planningProvider = PlanningProvider.of(context);

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getPlanningListHandler() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _planningProvider!.setPlanningState(
        _planningProvider!.planningState.update(progressState: 1),
      );

      _planningProvider!.getLocalReportList(startDate: startDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (startDate == null) startDate = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now());
    return Consumer<AuthProvider>(builder: (context, authProvider, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.PlanningListPageString_appbarTitle.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
          actions: [
            if (authProvider.authState.loginState == LoginState.IsLogin)
              IconButton(
                onPressed: () async {
                  DateTime? dateTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 100),
                  );

                  if (dateTime != null) {
                    startDate = KeicyDateTime.convertDateTimeToDateString(dateTime: dateTime);
                    _getPlanningListHandler();
                  }
                },
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
              LocaleKeys.PlanningListPageString_login_description.tr(),
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: heightDp! * 20),
            CustomTextButton(
              text: LocaleKeys.PlanningListPageString_login_button.tr().toUpperCase(),
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
      child: Consumer<PlanningProvider>(
        builder: (context, planningProvider, _) {
          if (planningProvider.planningState.progressState == 0) {
            if (planningProvider.planningState.planningData![startDate] == null) {
              _getPlanningListHandler();
            }
            return SizedBox();
          }

          if (planningProvider.planningState.progressState == 1) return Center(child: CupertinoActivityIndicator());

          if (planningProvider.planningState.progressState == -1) {
            return ErrorPage(
              message: planningProvider.planningState.message,
              callback: _getPlanningListHandler,
            );
          }

          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            header: WaterDropHeader(),
            footer: ClassicFooter(),
            controller: _refreshController,
            onRefresh: _getPlanningListHandler,
            onLoading: null,
            child: planningProvider.planningState.planningData![startDate].length == 0
                ? Center(
                    child: Text(
                      "No Planning Data",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  )
                : ListView.builder(
                    itemCount: planningProvider.planningState.planningData![startDate].length,
                    itemBuilder: (context, index) {
                      print(index);
                      return PlanningWidget(
                        data: planningProvider.planningState.planningData![startDate][index],
                        onDetailHandler: (PlanningReportModel planningReportModel) async {
                          var result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => PlanningPage(
                                planningReportModel: planningReportModel,
                                bottomTabController: widget.bottomTabController,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
