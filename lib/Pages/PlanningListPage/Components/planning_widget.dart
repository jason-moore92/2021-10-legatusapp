import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/Styles/index.dart';

class PlanningWidget extends StatelessWidget {
  final Map<String, dynamic>? data;
  final Function(PlanningReportModel)? onDetailHandler;

  PlanningWidget(
      {Key? key, @required this.data, @required this.onDetailHandler})
      : super(key: key);

  double? deviceWidth;
  double? widthDp;
  double? heightDp;
  double? fontSp;

  @override
  Widget build(BuildContext context) {
    deviceWidth = 1.sw;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

    return Container(
      width: deviceWidth,
      child: Column(
        children: [
          Container(
            color: Color(0xFFF4F4F4),
            padding: EdgeInsets.symmetric(
                horizontal: widthDp! * 15, vertical: heightDp! * 10),
            child: Row(
              children: [
                Text(
                  data!["literal_date"],
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
          Column(
            children: List.generate(data!["reports"].length, (index) {
              PlanningReportModel planningReportModel =
                  PlanningReportModel.fromJson(data!["reports"][index]);

              return Column(
                children: [
                  _reportPanel(context, planningReportModel),
                  Divider(height: 1, thickness: 1, color: Color(0xFFE4E4E4)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _reportPanel(
      BuildContext context, PlanningReportModel? planningReportModel) {
    List<dynamic> timeList = planningReportModel!.time!.split(":");
    String time = timeList[0] + ":" + timeList[1];

    return GestureDetector(
      onTap: () {
        onDetailHandler!(planningReportModel);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: widthDp! * 15, vertical: heightDp! * 5),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    planningReportModel.name!,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                SizedBox(width: widthDp! * 5),
                Text(
                  time,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: AppColors.yello),
                ),
              ],
            ),

            ///
            SizedBox(height: heightDp! * 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.folder_outlined,
                    size: heightDp! * 22, color: Colors.black),
                SizedBox(width: widthDp! * 5),
                Expanded(
                  child: Text(
                    planningReportModel.folderName!,
                    style: Theme.of(context).textTheme.bodyText1!,
                  ),
                ),
              ],
            ),

            ///
            if (planningReportModel.zipCity != "")
              Column(
                children: [
                  SizedBox(height: heightDp! * 0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: heightDp! * 22, color: Colors.black),
                      SizedBox(width: widthDp! * 5),
                      Expanded(
                        child: Text(
                          planningReportModel.zipCity!,
                          style: Theme.of(context).textTheme.bodyText1!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ///
            if (planningReportModel.customers!.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: heightDp! * 0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.business,
                          size: heightDp! * 22, color: Colors.black),
                      SizedBox(width: widthDp! * 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              planningReportModel.customers!.length, (index) {
                            return Container(
                              child: Text(
                                planningReportModel.customers![index].name!,
                                style: Theme.of(context).textTheme.bodyText1!,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ///
            if (planningReportModel.accounts!.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: heightDp! * 0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_police_outlined,
                          size: heightDp! * 22, color: Colors.black),
                      SizedBox(width: widthDp! * 5),
                      Expanded(
                        child: planningReportModel.accounts!.isEmpty
                            ? Container(
                                height: heightDp! * 25,
                                alignment: Alignment.center,
                                child: Text(
                                  "No Accounts",
                                  style: Theme.of(context).textTheme.bodyText1!,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                    planningReportModel.accounts!.length,
                                    (index) {
                                  return Container(
                                    child: Text(
                                      planningReportModel.accounts![index]
                                          ["name"],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!,
                                    ),
                                  );
                                }),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
