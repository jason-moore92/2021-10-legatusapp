import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/ApiDataProviders/index.dart';
import 'package:legutus/Helpers/custom_url_lancher.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/index.dart';
import 'package:legutus/Pages/Components/custom_text_button.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:json_diff/json_diff.dart';

class PlanningView extends StatefulWidget {
  final PlanningReportModel? planningReportModel;

  PlanningView({Key? key, this.planningReportModel}) : super(key: key);

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

  void _goToLocalReportPage() async {
    LocalReportModel? localReportModel = await LocalReportApiProvider.getLocalReportModelByReportId(
      reportId: widget.planningReportModel!.reportId,
    );

    if (localReportModel == null) {
      LocalReportModel localReportModel = LocalReportModel();
      localReportModel.reportId = widget.planningReportModel!.reportId;
      localReportModel.name = widget.planningReportModel!.name;
      localReportModel.date = widget.planningReportModel!.date;
      localReportModel.time = widget.planningReportModel!.time;
      localReportModel.zip = widget.planningReportModel!.zipCity!.split(" ").first;
      localReportModel.city = widget.planningReportModel!.zipCity!.split(" ").length == 2 ? widget.planningReportModel!.zipCity!.split(" ").last : "";
      localReportModel.createdAt = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: "Y-m-d H:i:s");

      var progressState = await LocalReportProvider.of(context).createLocalReport(localReportModel: localReportModel);
      if (progressState == 2) {
        LocalReportListProvider.of(context).setLocalReportListState(
          LocalReportListState.init().copyWith(
            localReportModel: localReportModel,
          ),
          isNotifiable: false,
        );
      }
    } else {
      LocalReportListProvider.of(context).setLocalReportListState(
        LocalReportListProvider.of(context).localReportListState.update(
              localReportModel: localReportModel,
            ),
        isNotifiable: false,
      );
    }

    AppDataProvider.of(context).appDataState.bottomTabController!.jumpToTab(1);
  }

  void _openGoogleMap(AddressModel addressModel) {
    String url = "https://www.google.com/maps/search/?api=1";
    if (addressModel.latitude != "" && addressModel.longitude != "") {
      url += "&query=${addressModel.latitude}%2C${addressModel.longitude}";
    } else {
      url += "&query=${addressModel.city}"
          ",${addressModel.complement}"
          ",${addressModel.street}"
          ",${addressModel.zip}";
      url = url.replaceAll("from", "+");
    }

    CustomUrlLauncher.launchWebUrl(url);
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
        child: Icon(Icons.add_a_photo_outlined, size: heightDp! * 25, color: Colors.white),
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
                        KeicyDateTime.convertDateTimeToDateString(
                          dateTime: KeicyDateTime.convertDateStringToDateTime(
                            dateString: "${widget.planningReportModel!.date!} ${widget.planningReportModel!.time!}",
                          ),
                          formats: "d/m/Y H:i",
                        ),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ],
                ),

                /// State
                if (widget.planningReportModel!.state != "")
                  Column(
                    children: [
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
                    ],
                  ),

                /// Type
                if (widget.planningReportModel!.type != "")
                  Column(
                    children: [
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
                    ],
                  ),

                /// Accounts
                if (widget.planningReportModel!.accounts!.isNotEmpty)
                  Column(
                    children: [
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
                            child: Column(
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
                    ],
                  ),

                /// Price
                if (widget.planningReportModel!.price != "")
                  Column(
                    children: [
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
                    ],
                  ),

                /// References
                if (widget.planningReportModel!.references!.isNotEmpty)
                  Column(
                    children: [
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
                            child: Column(
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
                    ],
                  ),

                /// Address
                if (!JsonDiffer.fromJson(widget.planningReportModel!.addressModel!.toJson(), AddressModel().toJson()).diff().hasNothing)
                  Column(
                    children: [
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
                                      if (widget.planningReportModel!.addressModel!.street! != "")
                                        Text(
                                          "${widget.planningReportModel!.addressModel!.street!}",
                                          style: Theme.of(context).textTheme.subtitle1,
                                        ),
                                      if (widget.planningReportModel!.addressModel!.complement! != "")
                                        Column(
                                          children: [
                                            SizedBox(height: heightDp! * 2),
                                            Text(
                                              "${widget.planningReportModel!.addressModel!.complement!}",
                                              style: Theme.of(context).textTheme.subtitle1,
                                            ),
                                          ],
                                        ),
                                      SizedBox(height: heightDp! * 2),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              if (widget.planningReportModel!.addressModel!.zip! != "")
                                                Text(
                                                  "${widget.planningReportModel!.addressModel!.zip!}",
                                                  style: Theme.of(context).textTheme.subtitle1,
                                                ),
                                              SizedBox(width: widthDp! * 10),
                                              if (widget.planningReportModel!.addressModel!.city! != "")
                                                Text(
                                                  "${widget.planningReportModel!.addressModel!.city!}",
                                                  style: Theme.of(context).textTheme.subtitle1,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                CustomTextButton(
                                  text: "Maps",
                                  textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                                  bordercolor: AppColors.yello,
                                  borderRadius: heightDp! * 6,
                                  elevation: 0,
                                  onPressed: () {
                                    _openGoogleMap(widget.planningReportModel!.addressModel!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                /// Folder Name
                if (widget.planningReportModel!.folderName != "")
                  Column(
                    children: [
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
                    ],
                  ),

                /// Descripton
                if (widget.planningReportModel!.description != "")
                  Column(
                    children: [
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
                    ],
                  ),

                /// Customers
                if (widget.planningReportModel!.customers!.isNotEmpty)
                  Column(
                    children: List.generate(widget.planningReportModel!.customers!.length, (index) {
                      CustomerModel customerModel = widget.planningReportModel!.customers![index];
                      if (JsonDiffer.fromJson(customerModel.toJson(), CustomerModel().toJson()).diff().hasNothing) return SizedBox();

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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          if (!JsonDiffer.fromJson(customerModel.addressModel!.toJson(), AddressModel().toJson()).diff().hasNothing)
                            Column(
                              children: [
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
                                                if (customerModel.addressModel!.street != "")
                                                  Text(
                                                    "${customerModel.addressModel!.street!}",
                                                    style: Theme.of(context).textTheme.subtitle1,
                                                  ),
                                                if (customerModel.addressModel!.zip != "" || customerModel.addressModel!.city != "")
                                                  Column(
                                                    children: [
                                                      SizedBox(height: heightDp! * 2),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "${customerModel.addressModel!.zip}",
                                                            style: Theme.of(context).textTheme.subtitle1,
                                                          ),
                                                          SizedBox(width: widthDp! * 10),
                                                          Text(
                                                            "${customerModel.addressModel!.city}",
                                                            style: Theme.of(context).textTheme.subtitle1,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                          CustomTextButton(
                                            text: "Maps",
                                            textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                                            bordercolor: AppColors.yello,
                                            borderRadius: heightDp! * 6,
                                            elevation: 0,
                                            onPressed: () {
                                              _openGoogleMap(customerModel.addressModel!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          /// Siren
                          if (customerModel.corpNumber != "")
                            Column(
                              children: [
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
                                        "${customerModel.corpNumber}",
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          /// email
                          if (customerModel.email != "")
                            Column(
                              children: [
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
                                        "customerModel.email",
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          /// phone
                          if (customerModel.phone != "")
                            Column(
                              children: [
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
                                          CustomUrlLauncher.makePhoneCall(customerModel.phone!);
                                        },
                                        child: Text(
                                          "${customerModel.phone}",
                                          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                color: AppColors.yello,
                                                decoration: TextDecoration.underline,
                                                decorationColor: AppColors.yello,
                                                decorationThickness: 2,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          /// Representation
                          if (customerModel.representation!.isNotEmpty)
                            Column(
                              children: [
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
                                      child: Column(
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
                              ],
                            ),

                          /// Recipients
                          if (customerModel.recipients!.isNotEmpty)
                            Column(
                              children: [
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(customerModel.recipients!.length, (index) {
                                          if (JsonDiffer.fromJson(customerModel.recipients![index].toJson(), RecipientModel().toJson())
                                              .diff()
                                              .hasNothing) return SizedBox();
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (customerModel.recipients![index].name != "" || customerModel.recipients![index].position != "")
                                                    Text(
                                                      "${customerModel.recipients![index].name} - ${customerModel.recipients![index].position}",
                                                      style: Theme.of(context).textTheme.subtitle1,
                                                    ),
                                                  if (customerModel.recipients![index].mobilePhone != "")
                                                    Column(
                                                      children: [
                                                        SizedBox(height: heightDp! * 3),
                                                        GestureDetector(
                                                          onTap: () {
                                                            CustomUrlLauncher.makePhoneCall(customerModel.recipients![index].mobilePhone!);
                                                          },
                                                          child: Text(
                                                            "${customerModel.recipients![index].mobilePhone}",
                                                            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                                  color: AppColors.yello,
                                                                  decoration: TextDecoration.underline,
                                                                  decorationColor: AppColors.yello,
                                                                  decorationThickness: 2,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (customerModel.recipients![index].email != "")
                                                    Column(
                                                      children: [
                                                        SizedBox(height: heightDp! * 3),
                                                        GestureDetector(
                                                          onTap: () {
                                                            CustomUrlLauncher.sendEmail(email: customerModel.recipients![index].email!);
                                                          },
                                                          child: Text(
                                                            "${customerModel.recipients![index].email}",
                                                            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                                  color: AppColors.yello,
                                                                  decoration: TextDecoration.underline,
                                                                  decorationColor: AppColors.yello,
                                                                  decorationThickness: 2,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
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
