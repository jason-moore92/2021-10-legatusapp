import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/ApiDataProviders/index.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/index.dart';
import 'package:legutus/Pages/Components/custom_text_button.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class PlanningView extends StatefulWidget {
  final PlanningReportModel? planningReportModel;
  final PersistentTabController? bottomTabController;

  PlanningView({Key? key, this.planningReportModel, this.bottomTabController}) : super(key: key);

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

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _goToLocalReportPage() async {
    LocalReportModel localReportModel = await LocalReportsDataProvider.getLocalReportModelByReportId(
      reportId: widget.planningReportModel!.reportId,
    );

    if (localReportModel.reportId != -1) {
      ///
    } else {
      LocalReportModel localReportModel = LocalReportModel();
      localReportModel.reportId = widget.planningReportModel!.reportId;
      localReportModel.name = widget.planningReportModel!.name;
      localReportModel.date = widget.planningReportModel!.date;
      localReportModel.time = widget.planningReportModel!.time;
      localReportModel.zip = widget.planningReportModel!.zipCity!.split(" ").first;
      localReportModel.city = widget.planningReportModel!.zipCity!.split(" ").length == 2 ? widget.planningReportModel!.zipCity!.split(" ").last : "";
      localReportModel.createdAt = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: "Y-m-d H:i:s");

      var progressState = await _localReportListProvider!.createLocalReport(localReportModel: localReportModel);
      if (progressState == 2) {
        _localReportListProvider!.setLocalReportListState(
          _localReportListProvider!.localReportListState.update(progressState: 0),
        );
      }
    }

    widget.bottomTabController!.jumpToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.planningReportModel!.name!,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.yello,
        child: Icon(Icons.add, size: heightDp! * 25, color: Colors.white),
        onPressed: _goToLocalReportPage,
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowGlow();
          return true;
        },
        child: SingleChildScrollView(
          child: Container(
            width: deviceWidth,
            padding: EdgeInsets.symmetric(horizontal: widthDp! * 20, vertical: heightDp! * 20),
            child: Column(
              children: [
                /// Date Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_date.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${widget.planningReportModel!.date!} ${widget.planningReportModel!.time!}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                ),

                /// State
                SizedBox(height: heightDp! * 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_state.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${widget.planningReportModel!.state!}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                ),

                /// Type
                SizedBox(height: heightDp! * 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_type.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${widget.planningReportModel!.type!}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                ),

                /// Accounts
                SizedBox(height: heightDp! * 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_accounts.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: widget.planningReportModel!.accounts!.isEmpty
                          ? Text(
                              "No Accounts",
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(widget.planningReportModel!.accounts!.length, (index) {
                                return Column(
                                  children: [
                                    Text(
                                      "${widget.planningReportModel!.accounts![index]["name"]}",
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                    index < widget.planningReportModel!.accounts!.length - 1 ? SizedBox(height: heightDp! * 3) : SizedBox(),
                                  ],
                                );
                              }),
                            ),
                    ),
                  ],
                ),

                /// Price
                SizedBox(height: heightDp! * 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_price.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${widget.planningReportModel!.price!}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                ),

                /// References
                SizedBox(height: heightDp! * 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_references.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: widget.planningReportModel!.references!.isEmpty
                          ? Text(
                              "No References",
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(widget.planningReportModel!.references!.length, (index) {
                                return Column(
                                  children: [
                                    Text(
                                      "${widget.planningReportModel!.references![index].toString().split(":").last.trim()}",
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                    index < widget.planningReportModel!.references!.length - 1 ? SizedBox(height: heightDp! * 3) : SizedBox(),
                                  ],
                                );
                              }),
                            ),
                    ),
                  ],
                ),

                /// Address
                SizedBox(height: heightDp! * 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_address.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: widget.planningReportModel!.references!.isEmpty
                          ? Text(
                              "No Address Data",
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.planningReportModel!.addressModel!.street! != ""
                                            ? "${widget.planningReportModel!.addressModel!.street!}"
                                            : "No street",
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      SizedBox(height: heightDp! * 2),
                                      Text(
                                        widget.planningReportModel!.addressModel!.complement! != ""
                                            ? "${widget.planningReportModel!.addressModel!.complement!}"
                                            : "No complement",
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      SizedBox(height: heightDp! * 2),
                                      Row(
                                        children: [
                                          Text(
                                            widget.planningReportModel!.addressModel!.zip! != ""
                                                ? "${widget.planningReportModel!.addressModel!.zip!}"
                                                : "No zip",
                                            style: Theme.of(context).textTheme.subtitle1,
                                          ),
                                          SizedBox(width: widthDp! * 10),
                                          Text(
                                            widget.planningReportModel!.addressModel!.city! != ""
                                                ? "${widget.planningReportModel!.addressModel!.city!}"
                                                : "No city",
                                            style: Theme.of(context).textTheme.subtitle1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                CustomTextButton(
                                  text: "GPS",
                                  textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                                  bordercolor: AppColors.yello,
                                  borderRadius: heightDp! * 6,
                                  elevation: 0,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                    ),
                  ],
                ),

                /// Folder Name
                SizedBox(height: heightDp! * 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_foldName.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${widget.planningReportModel!.folderName!}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                ),

                /// Descripton
                SizedBox(height: heightDp! * 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        LocaleKeys.PlanningPageString_description.tr(),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${widget.planningReportModel!.description!}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                ),

                /// Customers
                if (widget.planningReportModel!.customers!.isNotEmpty)
                  Column(
                    children: List.generate(widget.planningReportModel!.customers!.length, (index) {
                      CustomerModel customerModel = widget.planningReportModel!.customers![index];

                      return Column(
                        children: [
                          ///
                          SizedBox(height: heightDp! * 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  LocaleKeys.PlanningPageString_customerInfo.tr(),
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${customerModel.name}",
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                    ),
                                    Text(
                                      "${customerModel.type}",
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          /// Address
                          SizedBox(height: heightDp! * 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  LocaleKeys.PlanningPageString_address.tr(),
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customerModel.addressModel!.street != "" ? "${customerModel.addressModel!.street!}" : "No street",
                                            style: Theme.of(context).textTheme.subtitle1,
                                          ),
                                          SizedBox(height: heightDp! * 2),
                                          Row(
                                            children: [
                                              Text(
                                                customerModel.addressModel!.zip != "" ? "${customerModel.addressModel!.zip}" : "No zip",
                                                style: Theme.of(context).textTheme.subtitle1,
                                              ),
                                              SizedBox(width: widthDp! * 10),
                                              Text(
                                                customerModel.addressModel!.city != "" ? "${customerModel.addressModel!.city}" : "No city",
                                                style: Theme.of(context).textTheme.subtitle1,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    CustomTextButton(
                                      text: "GPS",
                                      textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                                      bordercolor: AppColors.yello,
                                      borderRadius: heightDp! * 6,
                                      elevation: 0,
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          /// Siren
                          SizedBox(height: heightDp! * 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  LocaleKeys.PlanningPageString_crope.tr(),
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  customerModel.corpNumber != "" ? "${customerModel.corpNumber}" : "No crop number",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ],
                          ),

                          /// email
                          SizedBox(height: heightDp! * 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  LocaleKeys.PlanningPageString_email.tr(),
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "There is field name in api",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ],
                          ),

                          /// phone
                          SizedBox(height: heightDp! * 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  LocaleKeys.PlanningPageString_phoneNumber.tr(),
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: GestureDetector(
                                  onTap: () {
                                    if (customerModel.phone == "") return;
                                  },
                                  child: Text(
                                    customerModel.phone != "" ? "${customerModel.phone}" : "No phonenumber",
                                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                          color: customerModel.phone != "" ? AppColors.yello : Colors.black,
                                          decoration: customerModel.phone != "" ? TextDecoration.underline : TextDecoration.none,
                                          decorationColor: AppColors.yello,
                                          decorationThickness: 2,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          /// Representation
                          SizedBox(height: heightDp! * 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  LocaleKeys.PlanningPageString_representations.tr(),
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: customerModel.representation!.isEmpty
                                    ? Text(
                                        "No Representation",
                                        style: Theme.of(context).textTheme.subtitle1,
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(customerModel.representation!.length, (index) {
                                          return Column(
                                            children: [
                                              Text(
                                                "${customerModel.representation![index]}",
                                                style: Theme.of(context).textTheme.subtitle1,
                                              ),
                                              index < customerModel.representation!.length - 1 ? SizedBox(height: heightDp! * 3) : SizedBox(),
                                            ],
                                          );
                                        }),
                                      ),
                              ),
                            ],
                          ),

                          /// Recipients
                          SizedBox(height: heightDp! * 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  LocaleKeys.PlanningPageString_recipients.tr(),
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: customerModel.recipients!.isEmpty
                                    ? Text(
                                        "No Representation",
                                        style: Theme.of(context).textTheme.subtitle1,
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(customerModel.recipients!.length, (index) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${customerModel.recipients![index].name} - ${customerModel.recipients![index].position != '' ? customerModel.recipients![index].position : 'No Position'}",
                                                    style: Theme.of(context).textTheme.subtitle1,
                                                  ),
                                                  SizedBox(height: heightDp! * 3),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (customerModel.recipients![index].mobilePhone == "") return;
                                                    },
                                                    child: Text(
                                                      customerModel.recipients![index].mobilePhone != ""
                                                          ? "${customerModel.recipients![index].mobilePhone}"
                                                          : "No phonenumber",
                                                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                            color:
                                                                customerModel.recipients![index].mobilePhone != "" ? AppColors.yello : Colors.black,
                                                            decoration: customerModel.recipients![index].mobilePhone != ""
                                                                ? TextDecoration.underline
                                                                : TextDecoration.none,
                                                            decorationColor: AppColors.yello,
                                                            decorationThickness: 2,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(height: heightDp! * 3),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (customerModel.recipients![index].email == "") return;
                                                    },
                                                    child: Text(
                                                      customerModel.recipients![index].email != ""
                                                          ? "${customerModel.recipients![index].email}"
                                                          : "No email",
                                                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                            color: customerModel.recipients![index].email != "" ? AppColors.yello : Colors.black,
                                                            decoration: customerModel.recipients![index].email != ""
                                                                ? TextDecoration.underline
                                                                : TextDecoration.none,
                                                            decorationColor: AppColors.yello,
                                                            decorationThickness: 2,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              index < customerModel.recipients!.length - 1 ? SizedBox(height: heightDp! * 5) : SizedBox(),
                                            ],
                                          );
                                        }),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
