/* // TODO: Test
// TODO: Make and manage http.Client (maybe?)
import 'package:http/http.dart' as http;
import 'package:j_util/j_util_full.dart';

class ApiEndpoint extends ApiEndpointInstance{
  @override
  final String method;
  @override
  final Uri uri;
  @override
  final Uri Function(Uri base, RegExp? matcher, Map<String, dynamic> map)?
      uriModifier;
  @override
  final RegExp? uriMatcher;

  /// Contains the headers for the request, and (optionally) the
  /// acceptable values for them.
  @override
  final Map<String, RequestParameter>? headers;

  /// Contains the body parameters for the request, and (optionally) the
  /// acceptable values for them.
  @override
  final Map<String, RequestParameter>? bodyParameters;

  /// Contains the query parameters for the request, and (optionally) the
  /// acceptable values for them.
  @override
  final Map<String, RequestParameter>? queryParameters;

  @override
  final Map<String, List<String>?>? responseFormat;
  const ApiEndpoint({
    required this.method,
    required this.uri,
    this.uriModifier,
    this.uriMatcher,
    this.headers,
    this.bodyParameters,
    this.queryParameters,
    this.responseFormat,
  });
  // @override
  // bool isValid({
  //   required Map<String, List<String>?> rules,
  //   required Map<String, String> submission,
  //   bool restrictSubmissionToRules = false,
  //   bool requireSubmissionToSupplyAllOfRules = true,
  //   bool requireSubmissionToSupplyValidValues = true,
  // }) =>
  //     (!requireSubmissionToSupplyAllOfRules ||
  //         rules.entries.reduceUntilTrue(
  //             (_, elem, i, __) => (submission.containsKey(elem.key) &&
  //                     (!requireSubmissionToSupplyValidValues ||
  //                         (rules[elem.key]?.contains(submission[elem.key]) ??
  //                             true)))
  //                 ? (true, false)
  //                 : (false, true),
  //             true)) &&
  //     (!restrictSubmissionToRules ||
  //         submission.entries.reduceUntilTrue(
  //             (_, elem, i, __) => !(rules.containsKey(elem.key) &&
  //                     (!requireSubmissionToSupplyValidValues ||
  //                         (rules[elem.key]?.contains(submission[elem.key]) ??
  //                             true)))
  //                 ? (false, true)
  //                 : (true, false),
  //             true));

  // @override
  // Map<String, String> validate({
  //   required Map<String, List<String>?> rules,
  //   required Map<String, String> submission,
  //   bool restrictSubmissionToRules = false,
  //   bool requireSubmissionToSupplyAllOfRules = true,
  //   bool requireSubmissionToSupplyValidValues = true,
  //   bool failIfSubmissionSuppliesInvalidValues = true,
  // }) {
  //   var l = submission.length;
  //   if (requireSubmissionToSupplyAllOfRules &&
  //       !rules.entries.reduceUntilTrue(
  //           (_, elem, i, __) => (submission.containsKey(elem.key) &&
  //                   (!failIfSubmissionSuppliesInvalidValues ||
  //                       (rules[elem.key]?.contains(submission[elem.key]) ??
  //                           true)))
  //               ? (true, false)
  //               : (false, true),
  //           true)) {
  //     throw ArgumentError.value(
  //       submission,
  //       "submission",
  //       "Value doesn't supply required parameters",
  //     );
  //   }
  //   if (failIfSubmissionSuppliesInvalidValues &&
  //       !submission.entries.reduceUntilTrue(
  //           (_, elem, i, __) =>
  //               (!(/* rules.containsKey(elem.key) &&  */ (rules[elem.key]
  //                           ?.contains(elem.value) ??
  //                       true)))
  //                   ? (false, true)
  //                   : (true, false),
  //           true)) {
  //     throw ArgumentError.value(
  //       submission,
  //       "submission",
  //       "Value supplies invalid values for required parameters",
  //     );
  //   }
  //   if (restrictSubmissionToRules) {
  //     submission.removeWhere((key, value) => !(rules.containsKey(key) &&
  //         (!requireSubmissionToSupplyValidValues ||
  //             (rules[key]?.contains(value) ?? true))));
  //   }
  //   // TODO: Warn
  //   // if (submission.length != l)
  //   // logging.Logger.root.log(logging.Level.WARNING, "Some entries removed");
  //   return submission;
  // }

  // @override
  // @Deprecated("Use genRequest")
  // http.Request generateRequest({
  //   Map<String, String>? query,
  //   Map<String, String>? body,
  //   Map<String, String>? headers,
  // }) {
  //   // TODO: Handle validation for acceptable query/body/header fields
  //   var req = http.Request(method, uri);
  //   if (this.headers?.isEmpty ?? true) {
  //     // Shortcut headers setup
  //   } else if ((headers?.isNotEmpty ?? false) &&
  //       this.headers!.entries.reduceUntilTrue(
  //           (_, elem, i, __) => (!headers!.containsKey(elem.key))
  //               ? (false, true)
  //               : (true, false),
  //           true)) {
  //     // add headers
  //     req.headers.addAll(headers!);
  //   } else {
  //     // this.headers are not fulfilled by headers
  //     throw ArgumentError.value(
  //       headers,
  //       "headers",
  //       "Value doesn't cover required parameters",
  //     );
  //   }
  //   if (queryParameters?.isEmpty ?? true) {
  //     // Shortcut query setup
  //   } else if ((query?.isNotEmpty ?? false) &&
  //       queryParameters!.entries.reduceUntilTrue(
  //           (_, elem, i, __) =>
  //               (!query!.containsKey(elem.key)) ? (false, true) : (true, false),
  //           true)) {
  //     //.containsAll(query!.keys)) {
  //     // fill query
  //     req.url.queryParameters.addAll(query!);
  //   } else {
  //     // queryParameters are not fulfilled by query
  //     throw ArgumentError.value(
  //       query,
  //       "query",
  //       "Value doesn't cover required parameters",
  //     );
  //   }
  //   if (bodyParameters?.isEmpty ?? true) {
  //     // Shortcut body setup
  //   } else if ((body?.isNotEmpty ?? false) &&
  //       bodyParameters!.entries.reduceUntilTrue(
  //           (_, elem, i, __) => (!headers!.containsKey(elem.key))
  //               ? (false, true)
  //               : (true, false),
  //           true)) {
  //     //.containsAll(body!.keys)) {
  //     // fill body
  //     if (req.headers["Content-Type"] == "application/x-www-form-urlencoded") {
  //       req.bodyFields = body!;
  //     } else {
  //       req.body = body!.toString();
  //     }
  //   } else {
  //     // bodyParameters are not fulfilled by body
  //     throw ArgumentError.value(
  //       body,
  //       "body",
  //       "Value doesn't cover required parameters",
  //     );
  //   }
  //   return req;
  // }

  // static Uri applyUriModification(
  //   Uri Function(Uri, RegExp?, Map<String, dynamic>)? uriModifier,
  //   Uri baseUri,
  //   RegExp? uriMatcher,
  //   Map<String, dynamic>? uriModifierParam,
  // ) {
  //   if (uriModifier != null) {
  //     if (uriModifierParam == null) {
  //       throw ArgumentError.value(
  //         uriModifierParam,
  //         "uriModifierParam",
  //         "uri requires modification.",
  //       );
  //     }
  //     baseUri = uriModifier.call(baseUri, uriMatcher, uriModifierParam);
  //   }
  //   return baseUri;
  // }

  // @override
  // http.Request genRequest({
  //   Map<String, (int, ParamToValueMapping?)>? query,
  //   Map<String, (int, ParamToValueMapping?)>? body,
  //   Map<String, (int, ParamToValueMapping?)>? headers,
  //   Map<String, dynamic>? uriModifierParam,
  // }) {
  //   var tempUrl = applyUriModification(
  //     uriModifier,
  //     uri,
  //     uriMatcher,
  //     uriModifierParam,
  //   );
  //   if (queryParameters?.isEmpty ?? true) {
  //     // Shortcut query setup
  //   } else if (/* (query?.isNotEmpty ?? false) && */
  //       queryParameters!.entries.reduceUntilTrue(
  //           (bAcc, elem, i, _) => (!elem.value.required ||
  //                   elem.value.tryGenerateValidValue(valueIndex: query?[elem.key]?.$1 ?? 0) != null || !(query?.containsKey(elem.key) ?? false))
  //               ? (bAcc, false)
  //               : (false, true),
  //           true)) {
  //     // add query
  //     Map<String, String> newQP = {};
  //     for (var element in (query ?? {}).entries) {
  //       var rp = queryParameters![element.key];
  //       if (rp != null) {
  //         var output = rp.required
  //             ? rp.generateValidValue(
  //                 valueIndex: element.value.$1,
  //                 paramToValueMapping: element.value.$2)
  //             : rp.tryGenerateValidValue(
  //                 valueIndex: element.value.$1,
  //                 paramToValueMapping: element.value.$2);
  //         if (output != null) {
  //           newQP[element.key] = output;
  //         } else {
  //           // TODO: Warn of discarded optional value
  //         }
  //       } else {
  //         // TODO: Warn of missing expected key
  //       }
  //     }
  //     tempUrl = tempUrl.replace(queryParameters: newQP);
  //   } else {
  //     // this.query are not fulfilled by query
  //     throw ArgumentError.value(
  //       query,
  //       "query",
  //       "Value doesn't cover required parameters",
  //     );
  //   }
  //   var req = http.Request(method, tempUrl);
  //   if (this.headers?.isEmpty ?? true) {
  //     // Shortcut headers setup
  //   } else if (/* (headers?.isNotEmpty ?? false) && */
  //       this.headers!.entries.reduceUntilTrue(
  //           (bAcc, elem, i, _) => (!elem.value.required ||
  //                   elem.value.tryGenerateValidValue(valueIndex: headers?[elem.key]?.$1 ?? 0) != null || !(headers?.containsKey(elem.key) ?? false))
  //               ? (bAcc, false)
  //               : (false, true),
  //           true)) {
  //     // add headers
  //     for (var element in (headers ?? {}).entries) {
  //       var rp = this.headers![element.key];
  //       if (rp != null) {
  //         var output = rp.required
  //             ? rp.generateValidValue(
  //                 valueIndex: element.value.$1,
  //                 paramToValueMapping: element.value.$2)
  //             : rp.tryGenerateValidValue(
  //                 valueIndex: element.value.$1,
  //                 paramToValueMapping: element.value.$2);
  //         if (output != null) {
  //           req.headers[element.key] = output;
  //         } else {
  //           // TODO: Warn of discarded optional value
  //         }
  //       } else {
  //         // TODO: Warn of missing expected key
  //       }
  //     }
  //   } else {
  //     // this.headers are not fulfilled by headers
  //     throw ArgumentError.value(
  //       headers,
  //       "headers",
  //       "Value doesn't cover required parameters",
  //     );
  //   }
  //   if (bodyParameters?.isEmpty ?? true) {
  //     // Shortcut body setup
  //   } else if (/* (body?.isNotEmpty ?? false) && */
  //       bodyParameters!.entries.reduceUntilTrue(
  //           (bAcc, elem, i, _) => (!elem.value.required ||
  //                   elem.value.tryGenerateValidValue(valueIndex: body?[elem.key]?.$1 ?? 0) != null || !(body?.containsKey(elem.key) ?? false))
  //               ? (bAcc, false)
  //               : (false, true),
  //           true)) {
  //     // add body
  //     Map<String, String> newBody = {};
  //     for (var element in (body ?? {}).entries) {
  //       var rp = bodyParameters![element.key];
  //       if (rp != null) {
  //         var output = rp.required
  //             ? rp.generateValidValue(
  //                 valueIndex: element.value.$1,
  //                 paramToValueMapping: element.value.$2)
  //             : rp.tryGenerateValidValue(
  //                 valueIndex: element.value.$1,
  //                 paramToValueMapping: element.value.$2);
  //         if (output != null) {
  //           newBody[element.key] = output;
  //         } else {
  //           // TODO: Warn of discarded optional value
  //         }
  //       } else {
  //         // TODO: Warn of missing expected key
  //       }
  //     }
  //     req.bodyFields = newBody;
  //   } else {
  //     // this.body are not fulfilled by body
  //     throw ArgumentError.value(
  //       body,
  //       "body",
  //       "Value doesn't cover required parameters",
  //     );
  //   }
  //   print(req);
  //   return req;
  // }

  // @override
  // Future<http.StreamedResponse> fireRequest(
  //   http.Client client, {
  //   Map<String, (int, ParamToValueMapping?)>? query,
  //   Map<String, (int, ParamToValueMapping?)>? body,
  //   Map<String, (int, ParamToValueMapping?)>? headers,
  //   Map<String, dynamic>? uriModifierParam,
  // }) =>
  //     client.send(genRequest(
  //       body: body,
  //       headers: headers,
  //       query: query,
  //       uriModifierParam: uriModifierParam,
  //     ));

  // @override
  // Future<http.StreamedResponse> sendRequest({
  //   Map<String, (int, ParamToValueMapping?)>? query,
  //   Map<String, (int, ParamToValueMapping?)>? body,
  //   Map<String, (int, ParamToValueMapping?)>? headers,
  //   Map<String, dynamic>? uriModifierParam,
  // }) =>
  //     genRequest(
  //       body: body,
  //       headers: headers,
  //       query: query,
  //       uriModifierParam: uriModifierParam,
  //     ).send();

  @override
  ApiEndpointInstance createInstance() => ApiEndpointInstance(
        method: method,
        uri: uri,
        bodyParameters: bodyParameters,
        headers: headers,
        queryParameters: queryParameters,
        responseFormat: responseFormat,
        uriMatcher: uriMatcher,
        uriModifier: uriModifier,
      );
}

class ApiEndpointInstance {
  String method;
  Uri uri;
  Uri Function(Uri base, RegExp? matcher, Map<String, dynamic> map)?
      uriModifier;
  RegExp? uriMatcher;

  /// Contains the headers for the request, and (optionally) the
  /// acceptable values for them.
  Map<String, RequestParameter>? headers;

  /// Contains the body parameters for the request, and (optionally) the
  /// acceptable values for them.
  Map<String, RequestParameter>? bodyParameters;

  /// Contains the query parameters for the request, and (optionally) the
  /// acceptable values for them.
  Map<String, RequestParameter>? queryParameters;

  Map<String, List<String>?>? responseFormat;
  ApiEndpointInstance({
    required this.method,
    required this.uri,
    this.bodyParameters,
    this.headers,
    this.queryParameters,
    this.responseFormat,
    this.uriMatcher,
    this.uriModifier,
  });
  bool isValid({
    required Map<String, List<String>?> rules,
    required Map<String, String> submission,
    bool restrictSubmissionToRules = false,
    bool requireSubmissionToSupplyAllOfRules = true,
    bool requireSubmissionToSupplyValidValues = true,
  }) =>
      (!requireSubmissionToSupplyAllOfRules ||
          rules.entries.reduceUntilTrue(
              (_, elem, i, __) => (submission.containsKey(elem.key) &&
                      (!requireSubmissionToSupplyValidValues ||
                          (rules[elem.key]?.contains(submission[elem.key]) ??
                              true)))
                  ? (true, false)
                  : (false, true),
              true)) &&
      (!restrictSubmissionToRules ||
          submission.entries.reduceUntilTrue(
              (_, elem, i, __) => !(rules.containsKey(elem.key) &&
                      (!requireSubmissionToSupplyValidValues ||
                          (rules[elem.key]?.contains(submission[elem.key]) ??
                              true)))
                  ? (false, true)
                  : (true, false),
              true));

  Map<String, String> validate({
    required Map<String, List<String>?> rules,
    required Map<String, String> submission,
    bool restrictSubmissionToRules = false,
    bool requireSubmissionToSupplyAllOfRules = true,
    bool requireSubmissionToSupplyValidValues = true,
    bool failIfSubmissionSuppliesInvalidValues = true,
  }) {
    var l = submission.length;
    if (requireSubmissionToSupplyAllOfRules &&
        !rules.entries.reduceUntilTrue(
            (_, elem, i, __) => (submission.containsKey(elem.key) &&
                    (!failIfSubmissionSuppliesInvalidValues ||
                        (rules[elem.key]?.contains(submission[elem.key]) ??
                            true)))
                ? (true, false)
                : (false, true),
            true)) {
      throw ArgumentError.value(
        submission,
        "submission",
        "Value doesn't supply required parameters",
      );
    }
    if (failIfSubmissionSuppliesInvalidValues &&
        !submission.entries.reduceUntilTrue(
            (_, elem, i, __) =>
                (!(/* rules.containsKey(elem.key) &&  */ (rules[elem.key]
                            ?.contains(elem.value) ??
                        true)))
                    ? (false, true)
                    : (true, false),
            true)) {
      throw ArgumentError.value(
        submission,
        "submission",
        "Value supplies invalid values for required parameters",
      );
    }
    if (restrictSubmissionToRules) {
      submission.removeWhere((key, value) => !(rules.containsKey(key) &&
          (!requireSubmissionToSupplyValidValues ||
              (rules[key]?.contains(value) ?? true))));
    }
    // TODO: Warn
    // if (submission.length != l)
    // logging.Logger.root.log(logging.Level.WARNING, "Some entries removed");
    return submission;
  }

  @Deprecated("Use genRequest")
  http.Request generateRequest({
    Map<String, String>? query,
    Map<String, String>? body,
    Map<String, String>? headers,
  }) {
    // TODO: Handle validation for acceptable query/body/header fields
    var req = http.Request(method, uri);
    if (this.headers?.isEmpty ?? true) {
      // Shortcut headers setup
    } else if ((headers?.isNotEmpty ?? false) &&
        this.headers!.entries.reduceUntilTrue(
            (_, elem, i, __) => (!headers!.containsKey(elem.key))
                ? (false, true)
                : (true, false),
            true)) {
      // add headers
      req.headers.addAll(headers!);
    } else {
      // this.headers are not fulfilled by headers
      throw ArgumentError.value(
        headers,
        "headers",
        "Value doesn't cover required parameters",
      );
    }
    if (queryParameters?.isEmpty ?? true) {
      // Shortcut query setup
    } else if ((query?.isNotEmpty ?? false) &&
        queryParameters!.entries.reduceUntilTrue(
            (_, elem, i, __) =>
                (!query!.containsKey(elem.key)) ? (false, true) : (true, false),
            true)) {
      //.containsAll(query!.keys)) {
      // fill query
      req.url.queryParameters.addAll(query!);
    } else {
      // queryParameters are not fulfilled by query
      throw ArgumentError.value(
        query,
        "query",
        "Value doesn't cover required parameters",
      );
    }
    if (bodyParameters?.isEmpty ?? true) {
      // Shortcut body setup
    } else if ((body?.isNotEmpty ?? false) &&
        bodyParameters!.entries.reduceUntilTrue(
            (_, elem, i, __) => (!headers!.containsKey(elem.key))
                ? (false, true)
                : (true, false),
            true)) {
      //.containsAll(body!.keys)) {
      // fill body
      if (req.headers["Content-Type"] == "application/x-www-form-urlencoded") {
        req.bodyFields = body!;
      } else {
        req.body = body!.toString();
      }
    } else {
      // bodyParameters are not fulfilled by body
      throw ArgumentError.value(
        body,
        "body",
        "Value doesn't cover required parameters",
      );
    }
    return req;
  }

  static Uri applyUriModification(
    Uri Function(Uri, RegExp?, Map<String, dynamic>)? uriModifier,
    Uri baseUri,
    RegExp? uriMatcher,
    Map<String, dynamic>? uriModifierParam,
  ) {
    if (uriModifier != null) {
      if (uriModifierParam == null) {
        throw ArgumentError.value(
          uriModifierParam,
          "uriModifierParam",
          "uri requires modification.",
        );
      }
      baseUri = uriModifier.call(baseUri, uriMatcher, uriModifierParam);
    }
    return baseUri;
  }

  http.Request genRequest({
    Map<String, (int, ParamToValueMapping?)>? query,
    Map<String, (int, ParamToValueMapping?)>? body,
    Map<String, (int, ParamToValueMapping?)>? headers,
    Map<String, dynamic>? uriModifierParam,
  }) {
    var tempUrl = applyUriModification(
      uriModifier,
      uri,
      uriMatcher,
      uriModifierParam,
    );
    if (queryParameters?.isEmpty ?? true) {
      // Shortcut query setup
    } else if (/* (query?.isNotEmpty ?? false) && */
        queryParameters!.entries.reduceUntilTrue(
            (bAcc, elem, i, _) => (!elem.value.required ||
                    elem.value.tryGenerateValidValue(valueIndex: query?[elem.key]?.$1 ?? 0) != null || !(query?.containsKey(elem.key) ?? false))
                ? (bAcc, false)
                : (false, true),
            true)) {
      // add query
      Map<String, String> newQP = {};
      for (var element in (query ?? {}).entries) {
        var rp = queryParameters![element.key];
        if (rp != null) {
          var output = rp.required
              ? rp.generateValidValue(
                  valueIndex: element.value.$1,
                  paramToValueMapping: element.value.$2)
              : rp.tryGenerateValidValue(
                  valueIndex: element.value.$1,
                  paramToValueMapping: element.value.$2);
          if (output != null) {
            newQP[element.key] = output;
          } else {
            // TODO: Warn of discarded optional value
          }
        } else {
          // TODO: Warn of missing expected key
        }
      }
      tempUrl = tempUrl.replace(queryParameters: newQP);
    } else {
      // this.query are not fulfilled by query
      throw ArgumentError.value(
        query,
        "query",
        "Value doesn't cover required parameters",
      );
    }
    var req = http.Request(method, tempUrl);
    if (this.headers?.isEmpty ?? true) {
      // Shortcut headers setup
    } else if (/* (headers?.isNotEmpty ?? false) && */
        this.headers!.entries.reduceUntilTrue(
            (bAcc, elem, i, _) => (!elem.value.required ||
                    elem.value.tryGenerateValidValue(valueIndex: headers?[elem.key]?.$1 ?? 0) != null || !(headers?.containsKey(elem.key) ?? false))
                ? (bAcc, false)
                : (false, true),
            true)) {
      // add headers
      for (var element in (headers ?? {}).entries) {
        var rp = this.headers![element.key];
        if (rp != null) {
          var output = rp.required
              ? rp.generateValidValue(
                  valueIndex: element.value.$1,
                  paramToValueMapping: element.value.$2)
              : rp.tryGenerateValidValue(
                  valueIndex: element.value.$1,
                  paramToValueMapping: element.value.$2);
          if (output != null) {
            req.headers[element.key] = output;
          } else {
            // TODO: Warn of discarded optional value
          }
        } else {
          // TODO: Warn of missing expected key
        }
      }
    } else {
      // this.headers are not fulfilled by headers
      throw ArgumentError.value(
        headers,
        "headers",
        "Value doesn't cover required parameters",
      );
    }
    if (bodyParameters?.isEmpty ?? true) {
      // Shortcut body setup
    } else if (/* (body?.isNotEmpty ?? false) && */
        bodyParameters!.entries.reduceUntilTrue(
            (bAcc, elem, i, _) => (!elem.value.required ||
                    elem.value.tryGenerateValidValue(valueIndex: body?[elem.key]?.$1 ?? 0) != null || !(body?.containsKey(elem.key) ?? false))
                ? (bAcc, false)
                : (false, true),
            true)) {
      // add body
      Map<String, String> newBody = {};
      for (var element in (body ?? {}).entries) {
        var rp = bodyParameters![element.key];
        if (rp != null) {
          var output = rp.required
              ? rp.generateValidValue(
                  valueIndex: element.value.$1,
                  paramToValueMapping: element.value.$2)
              : rp.tryGenerateValidValue(
                  valueIndex: element.value.$1,
                  paramToValueMapping: element.value.$2);
          if (output != null) {
            newBody[element.key] = output;
          } else {
            // TODO: Warn of discarded optional value
          }
        } else {
          // TODO: Warn of missing expected key
        }
      }
      req.bodyFields = newBody;
    } else {
      // this.body are not fulfilled by body
      throw ArgumentError.value(
        body,
        "body",
        "Value doesn't cover required parameters",
      );
    }
    print(req);
    return req;
  }

  Future<http.StreamedResponse> fireRequest(
    http.Client client, {
    Map<String, (int, ParamToValueMapping?)>? query,
    Map<String, (int, ParamToValueMapping?)>? body,
    Map<String, (int, ParamToValueMapping?)>? headers,
    Map<String, dynamic>? uriModifierParam,
  }) =>
      client.send(genRequest(
        body: body,
        headers: headers,
        query: query,
        uriModifierParam: uriModifierParam,
      ));

  Future<http.StreamedResponse> sendRequest({
    Map<String, (int, ParamToValueMapping?)>? query,
    Map<String, (int, ParamToValueMapping?)>? body,
    Map<String, (int, ParamToValueMapping?)>? headers,
    Map<String, dynamic>? uriModifierParam,
  }) =>
      genRequest(
        body: body,
        headers: headers,
        query: query,
        uriModifierParam: uriModifierParam,
      ).send();

  @override
  ApiEndpointInstance createInstance() => ApiEndpointInstance(
        method: method,
        uri: uri,
        bodyParameters: bodyParameters,
        headers: headers,
        queryParameters: queryParameters,
        responseFormat: responseFormat,
        uriMatcher: uriMatcher,
        uriModifier: uriModifier,
      );
}
 */