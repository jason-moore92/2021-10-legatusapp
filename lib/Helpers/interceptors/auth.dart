import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Providers/index.dart';

import '../http_plus.dart';

class AuthInterceptor implements InterceptorContract {
  //Note:: URLs for which should not send token in any case.
  List<String> blacklist = [
    "/get-sms-code",
    "/login",
  ];

  @override
  Future<RequestData> interceptRequest({RequestData? data}) async {
    String currentRoute = data!.url.replaceAll(AppConfig.testApiBaseUrl, "");
    if (!blacklist.contains(currentRoute)) {
      String authToken = await getAuthToken();
      if (authToken != "") {
        data.headers["X-USER-TOKEN"] = authToken;
      }
    }

    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData? data}) async {
    if (data!.statusCode == 401) {
      var responseData = json.decode(data.body!);
      BridgeProvider().update(
        BridgeState(
          event: "log_out",
          data: {"message": responseData["message"]},
        ),
      );
    }
    return data;
  }
}
