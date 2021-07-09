import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keicy_progress_dialog/keicy_progress_dialog.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Models/user_model.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Components/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:legutus/Pages/Dialogs/normal_ask_dialog.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ConfigurationView extends StatefulWidget {
  ConfigurationView({Key? key}) : super(key: key);

  @override
  _ConfigurationViewState createState() => _ConfigurationViewState();
}

class _ConfigurationViewState extends State<ConfigurationView> with SingleTickerProviderStateMixin {
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

  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _smsController = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _smsFocusNode = FocusNode();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  AuthProvider? _authProvider;
  AppDataProvider? _appDataProvider;
  KeicyProgressDialog? _keicyProgressDialog;

  UserModel? _userModel;
  String? _email;
  String? _phoneNumber;
  String? _smsCode;

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

    _authProvider = AuthProvider.of(context);
    _appDataProvider = AppDataProvider.of(context);
    _keicyProgressDialog = KeicyProgressDialog.of(context);

    _authProvider!.setAuthState(_authProvider!.authState.update(contextName: "Configuration"), isNotifiable: false);

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      _authProvider!.addListener(_authProviderListener);
    });
  }

  @override
  void dispose() {
    _authProvider!.removeListener(_authProviderListener);
    super.dispose();
  }

  void _authProviderListener() async {
    if (_authProvider!.authState.contextName != "Configuration") return;
    if (_authProvider!.authState.progressState != 1 && _keicyProgressDialog!.isShowing()) {
      await _keicyProgressDialog!.hide();
    }

    if (_authProvider!.authState.progressState == 2) {
      SuccessDialog.show(context, text: _authProvider!.authState.message!);
    } else if (_authProvider!.authState.progressState == -1) {
      FailedDialog.show(context, text: _authProvider!.authState.message!);
    }
  }

  void _smsHandler() async {
    print(_formkey.currentState!.validate());
    if (!_formkey.currentState!.validate()) return;
    _formkey.currentState!.save();

    FocusScope.of(context).requestFocus(FocusNode());
    _authProvider!.setAuthState(_authProvider!.authState.update(progressState: 1));
    await _keicyProgressDialog!.show();

    // _authProvider!.getSMSCode(
    //   email: _email,
    //   phoneNumber: _phoneNumber,
    // );
    _authProvider!.getSMSCode(
      email: AppConfig.testEmail,
      phoneNumber: AppConfig.testPhoneNumber,
    );
  }

  void _loginHandler() async {
    print(_formkey.currentState!.validate());
    if (!_formkey.currentState!.validate()) return;
    _formkey.currentState!.save();

    FocusScope.of(context).requestFocus(FocusNode());
    _authProvider!.setAuthState(_authProvider!.authState.update(progressState: 1));
    await _keicyProgressDialog!.show();

    // _authProvider!.login(
    //   email: _email,
    //   phoneNumber: _phoneNumber,
    //   smsCode: _smsCode,
    // );
    _authProvider!.login(
      email: AppConfig.testEmail,
      phoneNumber: AppConfig.testPhoneNumber,
      smsCode: _smsCode,
    );
  }

  void _logoutHandler() async {}

  void _reportHandler() async {}

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
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowGlow();
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
                    if (authProvider.authState.loginState == LoginState.IsLogin) _logInPanel() else _logoutPanel(),
                    SizedBox(height: heightDp! * 20),
                    _permissionPanel(),
                    SizedBox(height: heightDp! * 20),
                    _storagePanel(),
                    SizedBox(height: heightDp! * 20),
                    _infomationPanel(),
                    SizedBox(height: heightDp! * 20),
                    _analysePanel(),
                    if (authProvider.authState.loginState == LoginState.IsLogin) SizedBox(height: heightDp! * 20),
                    if (authProvider.authState.loginState == LoginState.IsLogin)
                      CustomTextButton(
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
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _logoutPanel() {
    return Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.login, size: heightDp! * 25, color: Colors.black),
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
            child: Column(
              children: [
                Text(
                  "1. " + LocaleKeys.ConfigurationPageString_receiveSms.tr().toUpperCase(),
                  style: Theme.of(context).textTheme.caption,
                ),

                ///
                SizedBox(height: heightDp! * 10),
                Text(
                  LocaleKeys.ConfigurationPageString_emailLabel.tr(),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: heightDp! * 5),
                CustomTextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  width: widthDp! * 180,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(heightDp! * 6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
                  hintText: "monadresse@email.com",
                  hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black.withOpacity(0.4)),
                  errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (input) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode);
                  },
                  validator: (input) => !KeicyValidators.isValidEmail(input) ? LocaleKeys.ValidateErrorString_emailErrorText.tr() : null,
                  onSaved: (input) => _email = input,
                ),

                ///
                SizedBox(height: heightDp! * 10),
                Text(
                  LocaleKeys.ConfigurationPageString_phoneLabel.tr(),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: heightDp! * 5),
                CustomTextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  width: widthDp! * 180,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(heightDp! * 6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
                  hintText: "# ## ## ## ##",
                  hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black.withOpacity(0.4)),
                  errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                  prefixIcon: Container(
                    alignment: Alignment.center,
                    child: Text("+33 0", style: Theme.of(context).textTheme.subtitle1),
                  ),
                  prefixIconConstraints: BoxConstraints(maxWidth: widthDp! * 50),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    MaskTextInputFormatter(mask: '# ## ## ## ##', filter: {"#": RegExp(r'[0-9]')})
                  ],
                  onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                  validator: (input) => input.replaceAll(" ", "").length != 9
                      ? LocaleKeys.ValidateErrorString_textlengthErrorText.tr(namedArgs: {"length": "9"})
                      : null,
                  onSaved: (input) => _phoneNumber = input.replaceAll(" ", ""),
                ),

                ///
                SizedBox(height: heightDp! * 10),
                CustomTextButton(
                  text: LocaleKeys.ConfigurationPageString_receiveSms.tr().toUpperCase(),
                  textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                  width: widthDp! * 180,
                  bordercolor: Colors.grey.withOpacity(0.6),
                  borderRadius: heightDp! * 6,
                  elevation: 0,
                  onPressed: _smsHandler,
                ),

                ///
                SizedBox(height: heightDp! * 20),
                Text(
                  LocaleKeys.ConfigurationPageString_loginLabel.tr().toUpperCase(),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: heightDp! * 10),
                Text(
                  LocaleKeys.ConfigurationPageString_smsLabel.tr(),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: heightDp! * 5),
                CustomTextFormField(
                  controller: _smsController,
                  focusNode: _smsFocusNode,
                  width: widthDp! * 100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(heightDp! * 6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
                  hintText: "## ## ## ##",
                  hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black.withOpacity(0.4)),
                  errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    MaskTextInputFormatter(mask: '## ## ## ##', filter: {"#": RegExp(r'[0-9]')})
                  ],
                  onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                  validator: (input) => _authProvider!.authState.smsCode == true && input.replaceAll(" ", "").length != 8
                      ? LocaleKeys.ValidateErrorString_textlengthErrorText.tr(namedArgs: {"length": "8"})
                      : null,
                  onSaved: (input) => _smsCode = input.replaceAll(" ", ""),
                ),
                SizedBox(height: heightDp! * 5),
                CustomElevatedButton(
                  width: widthDp! * 120,
                  text: LocaleKeys.ConfigurationPageString_login.tr().toUpperCase(),
                  borderRadius: heightDp! * 6,
                  backColor: AppColors.yello,
                  onPressed: _authProvider!.authState.smsCode == false ? null : _loginHandler,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logInPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.login, size: heightDp! * 25, color: Colors.black),
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
                    "${_authProvider!.authState.userModel!.name!}",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${_authProvider!.authState.userModel!.organizationName!}",
                    style: Theme.of(context).textTheme.subtitle1!,
                  ),
                  Text(
                    "${_authProvider!.authState.userModel!.email!}",
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

  Widget _permissionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.toggle_on_outlined, size: heightDp! * 25, color: Colors.black),
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
                  Text(
                    LocaleKeys.ConfigurationPageString_camera_permission.tr(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    LocaleKeys.ConfigurationPageString_camera_permission_desc.tr(),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            Switch(
              activeColor: AppColors.yello,
              inactiveTrackColor: Colors.grey,
              value: _appDataProvider!.appDataState.settingsModel!.allowCamera!,
              onChanged: (value) {
                _appDataProvider!.settingsHandler(allowCamera: value);
              },
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
                  Text(
                    LocaleKeys.ConfigurationPageString_microphone_permission.tr(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    LocaleKeys.ConfigurationPageString_microphone_permission_desc.tr(),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            Switch(
              activeColor: AppColors.yello,
              inactiveTrackColor: Colors.grey,
              value: _appDataProvider!.appDataState.settingsModel!.allowMicrophone!,
              onChanged: (value) {
                _appDataProvider!.settingsHandler(allowMicrophone: value);
              },
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
                  Text(
                    LocaleKeys.ConfigurationPageString_location_permission.tr(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    LocaleKeys.ConfigurationPageString_location_permission_desc.tr(),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            Switch(
              activeColor: AppColors.yello,
              inactiveTrackColor: Colors.grey,
              value: _appDataProvider!.appDataState.settingsModel!.allowLocation!,
              onChanged: (value) {
                _appDataProvider!.settingsHandler(allowLocation: value);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _storagePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.storage, size: heightDp! * 25, color: Colors.black),
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
                        LocaleKeys.ConfigurationPageString_storage_condition1.tr(),
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
        SizedBox(height: heightDp! * 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.ConfigurationPageString_image_size.tr(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    LocaleKeys.ConfigurationPageString_image_size_desc.tr(),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            Switch(
              activeColor: AppColors.yello,
              inactiveTrackColor: Colors.grey,
              value: _appDataProvider!.appDataState.settingsModel!.withRestriction!,
              onChanged: (value) {
                _appDataProvider!.settingsHandler(withRestriction: value);
              },
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
            Icon(Icons.error_outline, size: heightDp! * 25, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_infomation.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Text(
          LocaleKeys.ConfigurationPageString_infomation_desc.tr(),
          style: Theme.of(context).textTheme.bodyText1,
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
            Icon(Icons.bug_report_outlined, size: heightDp! * 25, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              LocaleKeys.ConfigurationPageString_analyse.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        SizedBox(height: heightDp! * 10),
        Text(
          LocaleKeys.ConfigurationPageString_analyse_desc.tr(),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }
}
