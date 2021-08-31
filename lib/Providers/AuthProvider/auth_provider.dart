import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:legutus/ApiDataProviders/login_api_provider.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Providers/PlanningProvider/index.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'index.dart';

class AuthProvider extends ChangeNotifier {
  static AuthProvider of(BuildContext context, {bool listen = false}) => Provider.of<AuthProvider>(context, listen: listen);

  AuthState _authState = AuthState.init();
  AuthState get authState => _authState;

  String _rememberUserKey = "remember_me";

  void setAuthState(AuthState authState, {bool isNotifiable = true}) {
    if (_authState != authState) {
      _authState = authState;
      if (isNotifiable) notifyListeners();
    }
  }

  SharedPreferences? _prefs;
  SharedPreferences? get prefs => _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      String? result = _prefs!.getString(_rememberUserKey);
      if (result != null && result != "null") {
        _authState = _authState.update(
          progressState: 2,
          message: "",
          description: "",
          statusCode: 200,
          loginState: LoginState.IsLogin,
          userModel: UserModel.fromJson(json.decode(result)),
        );
      } else {
        _authState = _authState.update(
          progressState: 2,
          message: "",
          description: "",
          statusCode: 200,
          loginState: LoginState.IsNotLogin,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getSMSCode({@required String? email, @required String? phoneNumber, bool isNotifiable = true}) async {
    try {
      var result = await LoginApiProvider.getSMSCode(email: email, phoneNumber: phoneNumber);
      if (result["success"]) {
        _authState = _authState.update(
          progressState: 2,
          message: result["message"],
          description: result["description"],
          statusCode: result["statusCode"],
          loginState: LoginState.IsNotLogin,
          smsCode: true,
        );
      } else {
        _authState = _authState.update(
          progressState: -1,
          message: result["message"],
          description: result["description"],
          statusCode: result["statusCode"],
          loginState: LoginState.IsNotLogin,
          smsCode: false,
        );
      }
    } catch (e) {
      _authState = _authState.update(
        progressState: -1,
        message: "Something was wrong",
        description: e.toString(),
        statusCode: 500,
        loginState: LoginState.IsNotLogin,
        smsCode: false,
      );
    }

    if (isNotifiable) notifyListeners();
  }

  Future<void> login({@required String? email, @required String? password, bool isNotifiable = true}) async {
    try {
      var result = await LoginApiProvider.login(email: email, password: password);
      if (result["success"]) {
        if (_prefs == null) _prefs = await SharedPreferences.getInstance();

        _prefs!.setString(_rememberUserKey, json.encode(result["user"]));

        _authState = _authState.update(
          progressState: 2,
          message: result["message"],
          description: result["description"],
          statusCode: result["statusCode"],
          loginState: LoginState.IsLogin,
          userModel: UserModel.fromJson(result["user"]),
        );
      } else {
        _authState = _authState.update(
          progressState: -1,
          message: result["message"],
          description: result["description"],
          statusCode: result["statusCode"],
          loginState: LoginState.IsNotLogin,
        );
      }
    } catch (e) {
      _authState = _authState.update(
        progressState: -1,
        message: "Something was wrong",
        description: e.toString(),
        statusCode: 500,
        loginState: LoginState.IsNotLogin,
      );
    }

    if (isNotifiable) notifyListeners();
  }

  Future<void> logout(context, {bool isNotifiable = true}) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    _prefs!.setString(_rememberUserKey, "null");

    _authState = _authState.update(
      contextName: "",
      progressState: 2,
      message: "Vous avez été déconnecté avec succès",
      description: "",
      statusCode: 200,
      loginState: LoginState.IsNotLogin,
      smsCode: false,
      userModel: UserModel(),
    );

    PlanningProvider.of(context).setPlanningState(
      PlanningState.init(),
    );

    if (isNotifiable) notifyListeners();
  }
}
