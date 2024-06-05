import 'dart:convert' as dc;
import 'package:http/http.dart' as http;
import 'package:j_util/src/web/util.dart';

extension TypedRequests on http.Request {
  static http.Request generate(HttpMethod method, Uri url) =>
      http.Request(method.nameUpper, url);
}

extension MethodJumpTable on http.Client {
  static const Map<HttpMethod, Function> jumpTable = {
    HttpMethod.get: http.get,
    HttpMethod.post: http.post,
    HttpMethod.head: http.head,
    HttpMethod.put: http.put,
    HttpMethod.delete: http.delete,
    HttpMethod.patch: http.patch,
  };
  Future<http.Response> sendGenericRequest(
    HttpMethod method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    dc.Encoding? encoding,
  }) =>
      (method.canHaveBody())
          ? jumpTable[method]!(url,
              headers: headers, body: body, encoding: encoding)
          : jumpTable[method]!(url, headers: headers);
}
