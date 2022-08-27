// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'interceptors/auth.dart';
import 'interceptors/logging.dart';

Client http = InterceptedClient.build(
  interceptors: [
    AuthInterceptor(),
    LoggingInterceptor(), //Note:: this should be last so that details changed in previous interceptors will be visible.
  ],
);

Future<Map<String, String>> commonHeaders() async {
  Map<String, String> headers = {};

  String authToken = await getAuthToken();

  if (authToken != "") {
    headers["X-USER-TOKEN"] = authToken;
    // headers["Prediction-Key"] = authToken;
  }

  return headers;
}

Future<String> getAuthToken() async {
  SharedPreferences prefs;
  String rememberUserKey = "remember_me";

  prefs = await SharedPreferences.getInstance();
  var rememberUserData = prefs.getString(rememberUserKey) == null ? null : json.decode(prefs.getString(rememberUserKey)!);

  if (rememberUserData != null) {
    return rememberUserData['token'];
  }

  return "";
}
