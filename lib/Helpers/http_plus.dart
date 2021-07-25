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

Future<Map<String, dynamic>> commonHeaders() async {
  Map<String, String> headers = {};

  String authToken = await getAuthToken();

  if (authToken != "") {
    headers["X-USER-TOKEN"] = authToken;
  }

  return headers;
}

Future<String> getAuthToken() async {
  SharedPreferences _prefs;
  String _rememberUserKey = "remember_me";

  _prefs = await SharedPreferences.getInstance();
  var rememberUserData = _prefs.getString(_rememberUserKey) == null ? null : json.decode(_prefs.getString(_rememberUserKey)!);

  if (rememberUserData != null) {
    return rememberUserData['token'];
  }

  return "";
}
