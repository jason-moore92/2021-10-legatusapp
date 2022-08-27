// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:legatus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legatus/ApiDataProviders/index.dart';
import 'package:legatus/Config/config.dart';
import 'package:legatus/Helpers/custom_url_lancher.dart';
import 'package:legatus/Helpers/file_helpers.dart';
import 'package:legatus/Helpers/index.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Providers/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class ConfigurationView extends StatefulWidget {
  const ConfigurationView({Key? key}) : super(key: key);

  @override
  ConfigurationViewState createState() => ConfigurationViewState();
}

class ConfigurationViewState extends State<ConfigurationView> with SingleTickerProviderStateMixin {
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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _developModeController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _developModeFocusNode = FocusNode();

  final GlobalKey<FormState> _formkey1 = GlobalKey<FormState>();

  AuthProvider? _authProvider;
  AppDataProvider? _appDataProvider;
  KeicyProgressDialog? _keicyProgressDialog;

  String? _email;
  String? _password;

  int _totalKBSize = 0;

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

    _keicyProgressDialog = KeicyProgressDialog.of(
      context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      layout: Layout.column,
      padding: EdgeInsets.zero,
      width: heightDp! * 120,
      height: heightDp! * 120,
      progressWidget: Container(
        width: heightDp! * 120,
        height: heightDp! * 120,
        padding: EdgeInsets.all(heightDp! * 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(heightDp! * 10),
        ),
        child: SpinKitFadingCircle(
          color: AppColors.primayColor,
          size: heightDp! * 80,
        ),
      ),
      message: "",
    );

    _authProvider = AuthProvider.of(context);
    _appDataProvider = AppDataProvider.of(context);

    _appDataProvider!.setAppDataState(
      _appDataProvider!.appDataState.update(contextName: "ConfigurationPage"),
      isNotifiable: false,
    );

    _authProvider!.setAuthState(
      _authProvider!.authState.update(contextName: "ConfigurationPage"),
      isNotifiable: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _authProvider!.addListener(_authProviderListener);
    });
  }

  @override
  void dispose() {
    _authProvider!.removeListener(_authProviderListener);
    super.dispose();
  }

  void _authProviderListener() async {
    if (_authProvider!.authState.contextName != "ConfigurationPage") return;

    if (_authProvider!.authState.progressState != 1 && _keicyProgressDialog!.isShowing()) {
      await _keicyProgressDialog!.hide();
    }

    if (_authProvider!.authState.progressState == 2) {
      _emailController.clear();
      _passwordController.clear();
      SuccessDialog.show(context, text: _authProvider!.authState.message!);
    } else if (_authProvider!.authState.progressState == -1) {
      FailedDialog.show(context, text: _authProvider!.authState.message!);
    }
  }

  void _loginHandler() async {
    if (!_formkey1.currentState!.validate()) return;
    _formkey1.currentState!.save();

    FocusScope.of(context).requestFocus(FocusNode());
    _authProvider!.setAuthState(_authProvider!.authState.update(progressState: 1));
    await _keicyProgressDialog!.show();

    _authProvider!.login(
      email: _email,
      password: _password,
      // email: "mobile@legatus.fr",
      // password: "QrgNZbUdmBi2",
    );
  }

  void _logoutHandler() async {
    _authProvider!.logout(context);
  }

  void _reportHandler() async {
    Map<String, dynamic>? result;
    await _keicyProgressDialog!.show();
    try {
      result = await LocalReportApiProvider.getALL();
      List<dynamic> localReports = [];

      if (result["success"]) {
        for (var i = 0; i < result["data"].length; i++) {
          localReports.add(result["data"][i].toJson());
        }
        result = null;
        String currentDate = PlanningProvider.of(context).planningState.currentDate!;
        List<dynamic> planningData = [];
        if (currentDate != "" && PlanningProvider.of(context).planningState.planningData!.isNotEmpty) {
          planningData = PlanningProvider.of(context).planningState.planningData![currentDate];
        }
        result = await DebugApiProvider.debugReport(
          planningData: planningData,
          localReports: localReports,
          userModel: AuthProvider.of(context).authState.userModel,
          settingsModel: AppDataProvider.of(context).appDataState.settingsModel,
        );
      }

      await _keicyProgressDialog!.hide();

      if (result["success"]) {
        SuccessDialog.show(
          context,
          text: result["data"] != null && result["data"]["message"] != null ? result["data"]["message"] : "Success",
        );
      } else {
        FailedDialog.show(
          context,
          text: result["data"] != null && result["data"]["message"] != null ? result["data"]["message"] : "Something was wrong",
        );
      }
    } catch (e) {
      await _keicyProgressDialog!.hide();
      FailedDialog.show(
        context,
        text: "Something was wrong",
      );
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppDataProvider>(builder: (context, authProvider, appDataProvider, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.ConfigurationPageString_appbarTitle.tr(),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: StreamBuilder<Map<String, int>>(
          stream: Stream.fromFuture(FileHelpers.dirStatSync()),
          builder: (context, snapshot) {
            // if (!snapshot.hasData) return Center(child: CupertinoActivityIndicator());

            if (snapshot.hasData && snapshot.data != null) {
              _totalKBSize = snapshot.data!["size"]!;
            }

            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    width: deviceWidth,
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: widthDp! * 15, vertical: heightDp! * 20),
                    child: Column(
                      children: [
                        if (authProvider.authState.loginState == LoginState.isLogin) _logInPanel() else _logoutPanel(),
                        SizedBox(height: heightDp! * 20),
/*                         _permissionPanel(),
                        SizedBox(height: heightDp! * 20), */
                        _storagePanel(),
                        SizedBox(height: heightDp! * 20),
                        _pictureResolutionPanel(),
                        SizedBox(height: heightDp! * 20),
                        _videoResolutionPanel(),
                        SizedBox(height: heightDp! * 20),
                        _infomationPanel(),
                        SizedBox(height: heightDp! * 20),
                        _analysePanel(),
                        SizedBox(height: heightDp! * 20),
                        _developModelPanel(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _logoutPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.login, size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_login.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Text(
          LocaleKeys.ConfigurationPageString_login_description.tr(),
          style: Theme.of(context).textTheme.bodyText1,
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Center(
          child: Form(
            key: _formkey1,
            child: Column(
              children: [
                Text(
                  LocaleKeys.ConfigurationPageString_emailLabel.tr(),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: heightDp! * 5),
                CustomTextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  width: widthDp! * 230,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(heightDp! * 6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
                  hintText: "monadresse@email.com",
                  hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black.withOpacity(0.4)),
                  errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onFieldSubmitted: (input) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  validator: (input) => !KeicyValidators.isValidEmail(input) ? LocaleKeys.ValidateErrorString_emailErrorText.tr() : null,
                  onSaved: (input) => _email = input,
                ),

                ///
                SizedBox(height: heightDp! * 10),
                Text(
                  LocaleKeys.ConfigurationPageString_passwordLabel.tr(),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: heightDp! * 5),
                CustomTextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  width: widthDp! * 180,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(heightDp! * 6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
                  hintText: "****************",
                  hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black.withOpacity(0.4)),
                  errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                  validator: (input) =>
                      input.length < 8 ? LocaleKeys.ValidateErrorString_textlengthErrorText.tr(namedArgs: {"length": "8"}) : null,
                  errorMaxLines: 3,
                  onSaved: (input) => _password = input,
                ),

                ///
                SizedBox(height: heightDp! * 10),
                CustomTextButton(
                  text: LocaleKeys.ConfigurationPageString_login.tr().toUpperCase(),
                  textStyle: Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
                  backColor: AppColors.yello,
                  borderRadius: heightDp! * 6,
                  elevation: 0,
                  onPressed: _loginHandler,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _logInPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.login, size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_login.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Icon(Icons.verified_user_outlined, size: heightDp! * 25, color: AppColors.green),
            SizedBox(width: widthDp! * 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _authProvider!.authState.userModel!.name!,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _authProvider!.authState.userModel!.organizationName!,
                    style: Theme.of(context).textTheme.subtitle1!,
                  ),
                  Text(
                    _authProvider!.authState.userModel!.email!,
                    style: Theme.of(context).textTheme.subtitle1!,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: heightDp! * 20),
        Center(
          child: CustomTextButton(
            text: LocaleKeys.ConfigurationPageString_logout.tr(),
            textStyle: Theme.of(context).textTheme.button!.copyWith(color: Colors.red),
            leftWidget: Padding(
              padding: EdgeInsets.only(right: widthDp! * 10),
              child: Icon(Icons.logout_rounded, size: heightDp! * 25, color: Colors.red),
            ),
            onPressed: () {
              NormalAskDialog.show(
                context,
                title: LocaleKeys.LogoutDialog_title.tr(),
                content: LocaleKeys.LogoutDialog_description.tr(),
                okButton: LocaleKeys.LogoutDialog_logout.tr(),
                cancelButton: LocaleKeys.LogoutDialog_cancel.tr(),
                callback: _logoutHandler,
              );
            },
          ),
        ),
      ],
    );
  }

/*   Widget _permissionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.toggle_on_outlined,
                size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_application_permission.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: LocaleKeys.ConfigurationPageString_obligatory
                                  .tr() +
                              " - ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: LocaleKeys
                              .ConfigurationPageString_camera_permission.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    LocaleKeys.ConfigurationPageString_camera_permission_desc
                        .tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            // Switch(
            //   activeColor: AppColors.yello,
            //   inactiveTrackColor: Colors.grey,
            //   value: _appDataProvider!.appDataState.settingsModel!.allowCamera!,
            //   onChanged: (value) {
            //     _appDataProvider!.settingsHandler(allowCamera: value);
            //   },
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: LocaleKeys.ConfigurationPageString_obligatory
                                  .tr() +
                              " - ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: LocaleKeys
                                  .ConfigurationPageString_microphone_permission
                              .tr(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    LocaleKeys
                            .ConfigurationPageString_microphone_permission_desc
                        .tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            // Switch(
            //   activeColor: AppColors.yello,
            //   inactiveTrackColor: Colors.grey,
            //   value: _appDataProvider!.appDataState.settingsModel!.allowMicrophone!,
            //   onChanged: (value) {
            //     _appDataProvider!.settingsHandler(allowMicrophone: value);
            //   },
            // ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              LocaleKeys.ConfigurationPageString_optional.tr() +
                                  " - ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: LocaleKeys
                              .ConfigurationPageString_location_permission.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    LocaleKeys.ConfigurationPageString_location_permission_desc
                        .tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            // Switch(
            //   activeColor: AppColors.yello,
            //   inactiveTrackColor: Colors.grey,
            //   value: _appDataProvider!.appDataState.settingsModel!.allowLocation!,
            //   onChanged: (value) {
            //     _appDataProvider!.settingsHandler(allowLocation: value);
            //   },
            // ),
          ],
        ),
      ],
    );
  } */

  Widget _storagePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.storage, size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_storage.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "${(_totalKBSize / 1024).toStringAsFixed(2)} Mo ",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      Text(
                        LocaleKeys.ConfigurationPageString_storage_condition2.tr(),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                  Text(
                    LocaleKeys.ConfigurationPageString_storage_condition_desc.tr(),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            // Switch(
            //   activeColor: AppColors.yello,
            //   inactiveTrackColor: Colors.grey,
            //   value: true,
            //   onChanged: (value) {},
            // ),
          ],
        ),
        // SizedBox(height: heightDp! * 10),
        // Row(
        //   children: [
        //     Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Text(
        //             LocaleKeys.ConfigurationPageString_image_size.tr(),
        //             style: Theme.of(context).textTheme.bodyText1,
        //           ),
        //           Text(
        //             LocaleKeys.ConfigurationPageString_image_size_desc.tr(),
        //             style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
        //           ),
        //         ],
        //       ),
        //     ),
        //     Switch(
        //       activeColor: AppColors.yello,
        //       inactiveTrackColor: Colors.grey,
        //       value: _appDataProvider!.appDataState.settingsModel!.withRestriction!,
        //       onChanged: (value) {
        //         _appDataProvider!.settingsHandler(withRestriction: value);
        //       },
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _pictureResolutionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_outlined, size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_photoResolutionTitle.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Text(
          LocaleKeys.ConfigurationPageString_photoResolutionDescription.tr(),
          style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            SizedBox(
              height: heightDp! * 25,
              child: Radio(
                value: 0,
                activeColor: AppColors.yello,
                groupValue: _appDataProvider!.appDataState.settingsModel!.photoResolution,
                onChanged: (int? value) {
                  _appDataProvider!.settingsHandler(photoResolution: value);
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _appDataProvider!.settingsHandler(photoResolution: 0);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.ConfigurationPageString_high.tr(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: heightDp! * 2),
                      Text(
                        "720p (1280x720)",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            SizedBox(
              height: heightDp! * 25,
              child: Radio(
                value: 1,
                activeColor: AppColors.yello,
                groupValue: _appDataProvider!.appDataState.settingsModel!.photoResolution,
                onChanged: (int? value) {
                  _appDataProvider!.settingsHandler(photoResolution: value);
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _appDataProvider!.settingsHandler(photoResolution: 1);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.ConfigurationPageString_veryHigh.tr(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: heightDp! * 2),
                      Text(
                        "1080p (1920x1080)",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            SizedBox(
              height: heightDp! * 25,
              child: Radio(
                value: 2,
                activeColor: AppColors.yello,
                groupValue: _appDataProvider!.appDataState.settingsModel!.photoResolution,
                onChanged: (int? value) {
                  _appDataProvider!.settingsHandler(photoResolution: value);
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _appDataProvider!.settingsHandler(photoResolution: 2);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            LocaleKeys.ConfigurationPageString_ultraHigh.tr(),
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "  -  Par défaut",
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: heightDp! * 2),
                      Text(
                        "2160p (3840x2160)",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            SizedBox(
              height: heightDp! * 25,
              child: Radio(
                value: 3,
                activeColor: AppColors.yello,
                groupValue: _appDataProvider!.appDataState.settingsModel!.photoResolution,
                onChanged: (int? value) {
                  _appDataProvider!.settingsHandler(photoResolution: value);
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _appDataProvider!.settingsHandler(photoResolution: 3);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.ConfigurationPageString_maximum.tr(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: heightDp! * 2),
                      Text(
                        LocaleKeys.ConfigurationPageString_maximumDesc.tr(),
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _videoResolutionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.videocam_outlined, size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_videoResolutionTitle.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Text(
          LocaleKeys.ConfigurationPageString_videoResolutionDescription.tr(),
          style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            SizedBox(
              height: heightDp! * 25,
              child: Radio(
                value: 0,
                activeColor: AppColors.yello,
                groupValue: _appDataProvider!.appDataState.settingsModel!.videoResolution,
                onChanged: (int? value) {
                  _appDataProvider!.settingsHandler(videoResolution: value);
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _appDataProvider!.settingsHandler(videoResolution: 0);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            LocaleKeys.ConfigurationPageString_high.tr(),
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            "  -  Par défaut",
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: heightDp! * 2),
                      Text(
                        "720p (1280x720)",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            SizedBox(
              height: heightDp! * 25,
              child: Radio(
                value: 1,
                activeColor: AppColors.yello,
                groupValue: _appDataProvider!.appDataState.settingsModel!.videoResolution,
                onChanged: (int? value) {
                  _appDataProvider!.settingsHandler(videoResolution: value);
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _appDataProvider!.settingsHandler(videoResolution: 1);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.ConfigurationPageString_veryHigh.tr(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: heightDp! * 2),
                      Text(
                        "1080p (1920x1080)",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            SizedBox(
              height: heightDp! * 25,
              child: Radio(
                value: 2,
                activeColor: AppColors.yello,
                groupValue: _appDataProvider!.appDataState.settingsModel!.videoResolution,
                onChanged: (int? value) {
                  _appDataProvider!.settingsHandler(videoResolution: value);
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _appDataProvider!.settingsHandler(videoResolution: 2);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.ConfigurationPageString_ultraHigh.tr(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: heightDp! * 2),
                      Text(
                        "2160p (3840x2160)",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            SizedBox(
              height: heightDp! * 25,
              child: Radio(
                value: 3,
                activeColor: AppColors.yello,
                groupValue: _appDataProvider!.appDataState.settingsModel!.videoResolution,
                onChanged: (int? value) {
                  _appDataProvider!.settingsHandler(videoResolution: value);
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _appDataProvider!.settingsHandler(videoResolution: 3);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.ConfigurationPageString_maximum.tr(),
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: heightDp! * 2),
                      Text(
                        LocaleKeys.ConfigurationPageString_maximumDesc.tr(),
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infomationPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_infomation.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        // Text(
        //   LocaleKeys.ConfigurationPageString_infomation_desc.tr(),
        //   style: Theme.of(context).textTheme.bodyText1,
        // ),
        // SizedBox(height: heightDp! * 5),
        Text(
          "Legatus est une application de HUISSIO, SAS au capital de 25 000 euros, immatriculée au RCS de LYON sous le numéro 814 062 579 dont le siège social est situé au :"
          "\n12 avenue Paul d'Aubarède"
          "\n69230 SAINT-GENIS-LAVAL"
          "\nFrance"
          "\nN° TVA intracommunautaire : FR 17 845062579"
          "\nTéléphone :  04 28 29 09 24"
          "\nTélecopie / email : contact@legatus.fr"
          "\nDirecteur de la publication : Monsieur Vladimir LORENTZ, Président.",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: heightDp! * 20),
        Center(
          child: CustomTextButton(
            leftWidget: Padding(
              padding: EdgeInsets.only(right: widthDp! * 5),
              child: Icon(Icons.call_outlined, size: heightDp! * 20, color: AppColors.yello),
            ),
            text: LocaleKeys.ConfigurationPageString_contactLegatus.tr(),
            textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
            bordercolor: AppColors.yello,
            onPressed: () {
              CustomUrlLauncher.makePhoneCall(AppConfig.contactPhoneNumber);
            },
          ),
        ),
      ],
    );
  }

  Widget _analysePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bug_report_outlined, size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_analyse.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        // Text(
        //   LocaleKeys.ConfigurationPageString_analyse_desc.tr(),
        //   style: Theme.of(context).textTheme.bodyText1,
        // ),
        // SizedBox(height: heightDp! * 5),
        Text(
          "En cliquant sur Envoyer le rapport, vous acceptez de transmettre à Legatus les données locales stockées dans votre appareil. Legatus s'engage à ne faire aucun usage commercial de ces données et à ne les transmettre à aucun tiers.",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: heightDp! * 20),
        Center(
          child: CustomTextButton(
            text: LocaleKeys.ConfigurationPageString_sendReport.tr(),
            textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
            bordercolor: AppColors.yello,
            onPressed: () {
              NormalAskDialog.show(
                context,
                title: LocaleKeys.ReportDialog_title.tr(),
                content: LocaleKeys.ReportDialog_description.tr(),
                okButton: LocaleKeys.ReportDialog_send.tr(),
                cancelButton: LocaleKeys.ReportDialog_cancel.tr(),
                callback: _reportHandler,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _developModelPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.developer_mode_outlined, size: heightDp! * 28, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_developMode.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Text(
          LocaleKeys.ConfigurationPageString_developMode_desc.tr(),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        if (_authProvider!.appSettingsBox!.get("develop_mode") == "40251764")
          Column(
            children: [
              SizedBox(height: heightDp! * 20),
              Center(
                child: Text(
                  "Serveur de tests",
                  style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        SizedBox(height: heightDp! * 20),
        Center(
          child: Text(
            "Code secret",
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        SizedBox(height: heightDp! * 5),
        Center(
          child: CustomTextFormField(
            controller: _developModeController,
            focusNode: _developModeFocusNode,
            width: widthDp! * 130,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(heightDp! * 6),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
            hintText: "8 chiffres",
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black.withOpacity(0.4)),
            errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
            onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
          ),
        ),
        SizedBox(height: heightDp! * 10),
        Center(
          child: CustomTextButton(
            text: "Appliquer",
            textStyle: Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
            backColor: AppColors.yello,
            borderRadius: heightDp! * 6,
            elevation: 0,
            onPressed: () async {
              await _authProvider!.appSettingsBox!.put("develop_mode", _developModeController.text);
              _developModeController.clear();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}
