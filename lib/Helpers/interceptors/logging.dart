import 'package:http_interceptor/http_interceptor.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({RequestData? data}) async {
    print("=========== request ==============");
    print(data.toString());
    print("===================================");
    return data!;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData? data}) async {
    print("=========== response ==============");
    print(data!.body.toString());
    print("===================================");
    return data;
  }
}
