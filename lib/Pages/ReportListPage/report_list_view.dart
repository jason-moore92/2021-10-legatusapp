import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Components/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:legutus/Pages/ReportNewPage/new_report_page.dart';
import 'package:legutus/Pages/ReportPage/report_page.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';

class ReportListView extends StatefulWidget {
  ReportListView({Key? key}) : super(key: key);

  @override
  _ReportListViewState createState() => _ReportListViewState();
}

class _ReportListViewState extends State<ReportListView> with SingleTickerProviderStateMixin {
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

  RefreshController _refreshController = RefreshController(initialRefresh: false);

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

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      _localReportListProvider!.addListener(_localReportListProviderListener);

      if (_localReportListProvider!.localReportListState.progressState != 2) {
        _localReportListProvider!.setLocalReportListState(
          _localReportListProvider!.localReportListState.update(progressState: 1),
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
    List<dynamic> localReportListData = _localReportListProvider!.localReportListState.localReportListData!;
    Map<String, dynamic> localReportMetaData = _localReportListProvider!.localReportListState.localReportMetaData!;

    localReportListData = [];
    localReportMetaData = Map<String, dynamic>();
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
    _localReportListProvider!.setLocalReportListState(
      _localReportListProvider!.localReportListState.update(progressState: 1),
    );
    _localReportListProvider!.getLocalReportList();
  }

  void _deleteLocalReportHandler(LocalReportModel localReportModel) async {
    var progressState = await _localReportListProvider!.deleteLocalReport(localReportModel: localReportModel);
    if (progressState == 2) {
      SuccessDialog.show(
        context,
        callBack: () {
          _onRefresh();
        },
      );
    } else {
      FailedDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.ReportPageListString_appbarTitle.tr(),
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Consumer<LocalReportListProvider>(builder: (context, localReportListProvider, _) {
        if (localReportListProvider.localReportListState.progressState == 0) {
          return Center(child: CupertinoActivityIndicator());
        }
        return Container(
          width: deviceWidth,
          height: deviceHeight,
          child: _localReportsListPanel(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.yello,
        child: Icon(Icons.add, size: heightDp! * 25, color: Colors.white),
        onPressed: () async {
          var result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => NewReportPage()),
          );

          if (result != null && result.isNotEmpty) {
            _onRefresh();
          }
        },
      ),
    );
  }

  Widget _localReportsListPanel() {
    List<dynamic> localReportsList = [];
    Map<String, dynamic> localReportsMetaData = Map<String, dynamic>();

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
              localReports.disallowGlow();
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
                header: WaterDropHeader(),
                footer: ClassicFooter(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.separated(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    LocalReportModel localReportsModel = (index >= localReportsList.length) ? LocalReportModel(reportId: 0) : localReportsList[index];
                    return Slidable(
                      enabled: true,
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.2,
                      secondaryActions: [
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () {
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
                        ),
                      ],
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
                          isLoading: localReportsModel.reportId == 0,
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
