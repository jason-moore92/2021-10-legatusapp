import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:legatus/ApiDataProviders/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';

class AddEditionView extends StatefulWidget {
  final List<dynamic>? editions;

  const AddEditionView({Key? key, this.editions}) : super(key: key);

  @override
  AddEditionViewState createState() => AddEditionViewState();
}

class AddEditionViewState extends State<AddEditionView> with SingleTickerProviderStateMixin {
  /// Responsive design variables
  double deviceWidth = 0;
  double deviceHeight = 0;
  double statusbarHeight = 0;
  double appbarHeight = 0;
  double widthDp = 0;
  double heightDp = 0;
  double fontSp = 0;
  ///////////////////////////////

  KeicyProgressDialog? _keicyProgressDialog;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  String? jobId;

  @override
  void initState() {
    super.initState();

    /// Responsive design variables
    deviceWidth = 1.sw;
    deviceHeight = 1.sh;
    statusbarHeight = ScreenUtil().statusBarHeight;
    appbarHeight = AppBar().preferredSize.height;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    _keicyProgressDialog = KeicyProgressDialog.of(
      context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      layout: Layout.column,
      padding: EdgeInsets.zero,
      width: heightDp * 120,
      height: heightDp * 120,
      progressWidget: Container(
        width: heightDp * 120,
        height: heightDp * 120,
        padding: EdgeInsets.all(heightDp * 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(heightDp * 10),
        ),
        child: SpinKitFadingCircle(
          color: AppColors.primayColor,
          size: heightDp * 80,
        ),
      ),
      message: "",
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _assignEditionHandler() async {
    FocusScope.of(context).requestFocus(FocusNode());

    _keicyProgressDialog = KeicyProgressDialog.of(
      context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      layout: Layout.column,
      padding: EdgeInsets.zero,
      width: heightDp * 120,
      height: heightDp * 120,
      progressWidget: Container(
        width: heightDp * 120,
        height: heightDp * 120,
        padding: EdgeInsets.all(heightDp * 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(heightDp * 10),
        ),
        child: SpinKitFadingCircle(
          color: AppColors.primayColor,
          size: heightDp * 80,
        ),
      ),
      message: "",
    );

    await _keicyProgressDialog!.show();

    DateTime startDate = DateTime.now();

    var result = await EditionApiProvider.assignEditionJob(jobId: jobId, note: _noteController.text.trim());

    await _keicyProgressDialog!.hide();

    /// if timeout is more than 60s
    if (DateTime.now().difference(startDate).inSeconds > 60) {
      // ignore: use_build_context_synchronously
      FailedDialog.show(
        context,
        text: "La requête a dépassé la limite de 60 secondes. Vérifiez votre connexion ou réessayez plus tard",
      );
      return;
    }

    ///
    if (result["success"]) {
      // ignore: use_build_context_synchronously
      SuccessDialog.show(
        context,
        text: result["message"],
        callBack: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      // ignore: use_build_context_synchronously
      FailedDialog.show(
        context,
        text: result["message"],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu, size: heightDp * 25, color: Colors.white),
            SizedBox(width: heightDp * 10),
            Text(
              "Externaliser la frappe",
              style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: const [
          BackButton(color: Colors.transparent),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Container(
            width: deviceWidth,
            padding: EdgeInsets.symmetric(vertical: heightDp * 20),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widthDp * 20),
                  child: Text(
                    "Choisissez une option dans la liste ci-dessous.",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),

                ///
                SizedBox(height: heightDp * 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: widthDp * 20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.7), width: 1)),
                    ),
                    child: Column(
                      children: List.generate(widget.editions!.length, (index) {
                        Map<String, dynamic> editionData = widget.editions![index];

                        return GestureDetector(
                          onTap: () {
                            if (jobId != editionData["job_id"]) {
                              jobId = editionData["job_id"];
                              setState(() {});
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: heightDp * 7),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.7), width: 1)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  jobId == editionData["job_id"] ? Icons.radio_button_on : Icons.radio_button_off,
                                  size: heightDp * 25,
                                  color: jobId == editionData["job_id"] ? AppColors.yello : Colors.grey,
                                ),
                                SizedBox(width: widthDp * 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${editionData["title"]}",
                                        style: TextStyle(fontSize: fontSp * 16, color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: heightDp * 3),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(editionData["description"].length, (index) {
                                          return Column(
                                            children: [
                                              SizedBox(height: heightDp * 2),
                                              Text(
                                                "${editionData["description"][index]}",
                                                style: TextStyle(fontSize: fontSp * 14, color: Colors.black),
                                              ),
                                            ],
                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                ///
                SizedBox(height: heightDp * 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widthDp * 20),
                  child: CustomTextFormField(
                    controller: _noteController,
                    focusNode: _noteFocusNode,
                    hintText: "Note facultative pour le prestataire",
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp * 6),
                    ),
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    // validator: (input) => input.isEmpty ? LocaleKeys.ValidateErrorString_shouldBeErrorText.tr(args: ["note"]) : null,
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
                  ),
                ),

                ///
                SizedBox(height: heightDp * 10),
                CustomTextButton(
                  text: "ENVOYER",
                  width: widthDp * 100,
                  backColor: jobId != null ? AppColors.yello : Colors.grey.withOpacity(0.6),
                  textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                  onPressed: jobId != null
                      ? () {
                          if (!_formkey.currentState!.validate()) return;
                          _formkey.currentState!.save();

                          NormalAskDialog.show(
                            context,
                            content: "Veuillez confirmer que vous souhaitez externaliser la frappe de ce constat.",
                            okButton: "CONFIRMER",
                            cancelButton: "Annuler",
                            callback: () {
                              _assignEditionHandler();
                            },
                          );
                          return;
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
