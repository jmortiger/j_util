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
  Function jumper(HttpMethod method) => switch (method) {
        HttpMethod.get => get,
        HttpMethod.post => post,
        HttpMethod.head => head,
        HttpMethod.put => put,
        HttpMethod.delete => delete,
        HttpMethod.patch => patch,
      };

  /// If [body] is a String, it's encoded using [encoding] and used as the body of the request. The content-type of the request will default to "text/plain".

  /// If [body] is a List, it's used as a list of bytes for the body of the request.
  ///
  /// If [body] is a Map, it's encoded as form fields using [encoding]. The content-type of the request will be set to "application/x-www-form-urlencoded"; this cannot be overridden.
  ///
  /// [encoding] defaults to [utf8].
  Future<http.Response> sendGenericRequest(
    HttpMethod method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    dc.Encoding? encoding,
  }) =>
      (method.canHaveBody())
          ? jumper(method)(
              url,
              headers: headers,
              body: body,
              encoding: encoding,
            )
          : jumper(method)(
              url,
              headers: headers,
            );

  /// TODO: More robust body/encoding/Content-Type resolution
  Future<http.Response> sendNonStreamedRequest(http.Request request) {
    return sendGenericRequest(
      HttpMethod.getFromString(request.method),
        request.url,
        headers: request.headers,
        body: request.body.isEmpty ? null : request.body,
        encoding: request.encoding,
    );
  }
}

extension StatusCodes on http.BaseResponse {
  // bool get hasSuccessfulStatusCode => statusCode >= 200 && statusCode < 300;
  // bool get hasClientErrorStatusCode => statusCode >= 400 && statusCode < 500;
  // bool get hasServerErrorStatusCode => statusCode >= 500 /* && statusCode < 600*/;
  StatusCode get statusCodeInfo => StatusCode(statusCode);
}

class StatusCode {
  int statusCode;
  StatusCode(this.statusCode);
  bool get isInformative => statusCode >= 100 && statusCode < 200;
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
  bool get isRedirect => statusCode >= 300 && statusCode < 400;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500 /*  && statusCode < 300 */;
  bool get isError => isClientError || isServerError;
}
