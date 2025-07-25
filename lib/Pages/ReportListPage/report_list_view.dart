// ignore_for_file: use_build_context_synchronously

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Config/config.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Pages/ReportNewPage/new_report_page.dart';
import 'package:legatus/Pages/ReportPage/report_page.dart';
import 'package:legatus/Providers/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ReportListView extends StatefulWidget {
  const ReportListView({Key? key}) : super(key: key);

  @override
  ReportListViewState createState() => ReportListViewState();
}

class ReportListViewState extends State<ReportListView> with SingleTickerProviderStateMixin {
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

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  LocalReportListProvider? _localReportListProvider;

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

    _localReportListProvider = LocalReportListProvider.of(context);
    _localReportListProvider!.setLocalReportListState(
      _localReportListProvider!.localReportListState.update(contextName: "PlanningPage"),
      isNotifiable: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _localReportListProvider!.addListener(_localReportListProviderListener);

      if (_localReportListProvider!.localReportListState.localReportModel!.reportId != 0) {
        LocalReportModel localReportModel = _localReportListProvider!.localReportListState.localReportModel!;

        var result = await pushNewScreen(
          context,
          screen: ReportPage(localReportModel: localReportModel),
          pageTransitionAnimation: PageTransitionAnimation.fade,
        );

        _localReportListProvider!.setLocalReportListState(
          _localReportListProvider!.localReportListState.update(localReportModel: LocalReportModel()),
          isNotifiable: false,
        );

        if (result != null && result.isNotEmpty) {
          _onRefresh();
        } else {
          setState(() {});
        }
      } else if (_localReportListProvider!.localReportListState.isNew!) {
        var result = await pushNewScreen(
          context,
          screen: const NewReportPage(),
          pageTransitionAnimation: PageTransitionAnimation.fade,
        );

        _localReportListProvider!.setLocalReportListState(
          _localReportListProvider!.localReportListState.update(isNew: false),
          isNotifiable: false,
        );

        if (result != null && result.isNotEmpty) {
          _onRefresh();
        } else {
          setState(() {});
        }
      }

      if (_localReportListProvider!.localReportListState.progressState != 2) {
        _localReportListProvider!.setLocalReportListState(
          _localReportListProvider!.localReportListState.update(
            localReportListData: [],
            localReportMetaData: <String, dynamic>{},
            progressState: 1,
          ),
        );

        _localReportListProvider!.getLocalReportList();
      }
    });
  }

  @override
  void dispose() {
    _localReportListProvider!.removeListener(_localReportListProviderListener);
    super.dispose();
  }

  void _localReportListProviderListener() async {
    if (_localReportListProvider!.localReportListState.refreshList!) {
      _localReportListProvider!.setLocalReportListState(
        _localReportListProvider!.localReportListState.update(refreshList: false),
        isNotifiable: false,
      );
      _onRefresh();
    }
    if (_localReportListProvider!.localReportListState.contextName != "PlanningPage") return;

    if (_localReportListProvider!.localReportListState.progressState == -1) {
      if (_localReportListProvider!.localReportListState.isRefresh!) {
        _localReportListProvider!.setLocalReportListState(
          _localReportListProvider!.localReportListState.update(isRefresh: false),
          isNotifiable: false,
        );
        _refreshController.refreshFailed();
      } else {
        _refreshController.loadFailed();
      }
    } else if (_localReportListProvider!.localReportListState.progressState == 2) {
      if (_localReportListProvider!.localReportListState.isRefresh!) {
        _localReportListProvider!.setLocalReportListState(
          _localReportListProvider!.localReportListState.update(isRefresh: false),
          isNotifiable: false,
        );
        _refreshController.refreshCompleted();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  void _onRefresh() async {
    if (_localReportListProvider!.localReportListState.progressState == 1) return;

    List<dynamic> localReportListData = _localReportListProvider!.localReportListState.localReportListData!;
    Map<String, dynamic> localReportMetaData = _localReportListProvider!.localReportListState.localReportMetaData!;

    localReportListData = [];
    localReportMetaData = <String, dynamic>{};
    _localReportListProvider!.setLocalReportListState(
      _localReportListProvider!.localReportListState.update(
        progressState: 1,
        localReportListData: localReportListData,
        localReportMetaData: localReportMetaData,
        isRefresh: true,
      ),
    );

    _localReportListProvider!.getLocalReportList();
  }

  void _onLoading() async {
    if (_localReportListProvider!.localReportListState.progressState == 1) return;

    _localReportListProvider!.setLocalReportListState(
      _localReportListProvider!.localReportListState.update(progressState: 1),
    );
    _localReportListProvider!.getLocalReportList();
  }

  void _deleteLocalReportHandler(LocalReportModel localReportModel) async {
    var progressState = await LocalReportProvider.of(context).deleteLocalReport(localReportModel: localReportModel);
    if (progressState == 2) {
      Flushbar(
        message: "Constat supprimé de cet appareil avec succès.",
        duration: const Duration(seconds: 3),
        flushbarStyle: FlushbarStyle.FLOATING,
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        borderRadius: BorderRadius.circular(6),
      ).show(context);
      // Fluttertoast.showToast(
      //   msg: "Constat supprimé de cet appareil avec succès.",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.TOP,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.black,
      //   textColor: Colors.greenAccent,
      //   fontSize: 16.0,
      // );
      // SuccessDialog.show(
      //   context,
      //   text: "Constat supprimé de cet appareil avec succès.",
      //   callBack: () {},
      // );
      _onRefresh();
    } else {
      FailedDialog.show(context);
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalReportListProvider>(builder: (context, localReportListProvider, _) {
      if (localReportListProvider.localReportListState.localReportModel!.reportId != 0) {
        // return ReportPage(localReportModel: localReportListProvider.localReportListState.localReportModel);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primayColor,
            title: Text(
              "",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          body: const SizedBox(),
        );
      }

      if (_localReportListProvider!.localReportListState.isNew!) {
        // return NewReportPage();
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primayColor,
            title: Text(
              "",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          body: const SizedBox(),
        );
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primayColor,
          title: Text(
            LocaleKeys.ReportListPageString_appbarTitle.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: (localReportListProvider.localReportListState.progressState == 0)
            ? const Center(child: CupertinoActivityIndicator())
            : SizedBox(
                width: deviceWidth,
                height: deviceHeight,
                child: _localReportsListPanel(),
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.yello,
          child: Icon(Icons.add, size: heightDp! * 25, color: Colors.white),
          onPressed: () async {
            var result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => const NewReportPage()),
            );

            if (result != null && result.isNotEmpty) {
              _onRefresh();
            }
          },
        ),
      );
    });
  }

  Widget _localReportsListPanel() {
    List<dynamic> localReportsList = [];
    Map<String, dynamic> localReportsMetaData = <String, dynamic>{};

    if (_localReportListProvider!.localReportListState.localReportListData != null) {
      localReportsList = _localReportListProvider!.localReportListState.localReportListData!;
    }
    if (_localReportListProvider!.localReportListState.localReportMetaData != null) {
      localReportsMetaData = _localReportListProvider!.localReportListState.localReportMetaData!;
    }

    int itemCount = 0;

    if (_localReportListProvider!.localReportListState.localReportListData != null) {
      itemCount += _localReportListProvider!.localReportListState.localReportListData!.length;
    }

    if (_localReportListProvider!.localReportListState.progressState == 1) {
      itemCount += AppConfig.refreshListLimit;
    }

    return Column(
      children: [
        Expanded(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (localReports) {
              localReports.disallowIndicator();
              return true;
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.6))),
              ),
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: (localReportsMetaData["isEnd"] != null &&
                    !localReportsMetaData["isEnd"] &&
                    _localReportListProvider!.localReportListState.progressState != 1),
                header: const WaterDropHeader(),
                footer: const ClassicFooter(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.separated(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    LocalReportModel localReportsModel =
                        (index >= localReportsList.length) ? LocalReportModel(reportId: -1) : localReportsList[index];
                    return Slidable(
                      enabled: true,
                      // closeOnScroll: false,
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.3,
                        children: [
                          SlidableAction(
                            flex: 1,
                            autoClose: true,
                            // An action can be bigger than the others.
                            onPressed: (context) {
                              NormalAskDialog.show(
                                context,
                                title: LocaleKeys.DeleteReportDialogString_title.tr(),
                                content: LocaleKeys.DeleteReportDialogString_content.tr(),
                                okButton: LocaleKeys.DeleteReportDialogString_delete.tr(),
                                cancelButton: LocaleKeys.DeleteReportDialogString_cancel.tr(),
                                callback: () {
                                  _deleteLocalReportHandler(localReportsModel);
                                },
                              );
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: LocaleKeys.ReportListPageString_delete.tr(),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          var result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ReportPage(localReportModel: localReportsModel),
                            ),
                          );

                          if (result != null && result.isNotEmpty) {
                            _onRefresh();
                          }
                        },
                        child: LocalReportWidget(
                          isLoading: localReportsModel.reportId == -1,
                          localReportModel: localReportsModel,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.6));
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
