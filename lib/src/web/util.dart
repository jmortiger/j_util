import 'dart:convert' as dc;

import 'package:archive/archive.dart' as archive
  if (dart.library.io) 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:j_util/src/types.dart';
import 'package:j_util/src/extensions.dart';
import 'package:j_util/src/j_util_base.dart' as util;
//import 'package:logging/logging.dart' as logging;

String getBasicAuthHeaderValue(String identifier, String secret) =>
    'Basic ${dc.base64Encode(
      dc.ascii.encode(
        '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
      ),
    )}';

enum HttpMethod with PrettyPrintEnum {
  get,
  post,
  head,
  put,
  delete,
  patch,
  ;

  static const String GET = "GET";
  static const String POST = "POST";
  static const String HEAD = "HEAD";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";
  static const String PATCH = "PATCH";

  bool canHaveBody() => this == HttpMethod.get || this == HttpMethod.head;

  @override
  String toString() => nameUpper;
}

enum RequestParameterType with PrettyPrintEnum {
  header,
  body,
  query,
}

// ignore: unnecessary_question_mark
typedef ValueValidator = (bool, dynamic?) Function(
  Map<String, dynamic>? variableToProposedValue,
);
typedef ParamToValueMapping = Map<String, dynamic>;
typedef Validator<T> = String Function(String replacedParam, T proposedValue);
typedef MapGenerator = String Function(
  ParamToValueMapping? variableToProposedValue,
);
typedef UriModifier = Uri Function(Uri, RegExp?, Map<String, dynamic>);

final class RequestValue {
  final String baseString;
  final String templateFormatStr;
  RegExp get templateFormat => RegExp(templateFormatStr);
  final Generator? generator;
  final MapGenerator? _typedGenerator;
  MapGenerator get typedGenerator => _typedGenerator ?? _defaultGenerator;
  final Validator? validator;
  final List<Type>? validTypes;

  const RequestValue({
    required this.baseString,
    this.generator,
    MapGenerator? typedGenerator,
    this.validator,
    this.validTypes,
    String? templateFormat,
  })  : templateFormatStr =
            templateFormat ?? util.matchAsteriskBoundConstantNameString,
        _typedGenerator = typedGenerator;

  String generate(ParamToValueMapping? mapping) =>
      (_typedGenerator ?? _defaultGenerator).call(mapping);

  String dispatchGenerator(String Function(Function)? dispatcher) =>
      generator?.generate(dispatcher);

  String _defaultGenerator(ParamToValueMapping? mapping) =>
      baseString.replaceAllMapped(templateFormat, (match) {
        var group = match.group(1) ??
            (throw ArgumentError.value(
              templateFormat,
              "templateFormat",
              "Matched `baseString` (\"$baseString\"), but didn't place "
                  "the name section of the match (`${match.group(0)}`) "
                  "in group 1: ",
            ));
        return validator?.call(group, mapping?[group]) ??
            (mapping?[group]?.toString()) ??
            (throw ArgumentError.value(mapping, "mapping",
                "Didn't contain required parameter `$group`: "));
      });
}

final class RequestParameter {
  final List<String>? validValues;
  bool get requiresParameters =>
      (validValues?.isNotEmpty ?? false) &&
      !validValues!.any((element) => templateFormat.hasMatch(element));
  int get nonGeneratedValueIndex =>
      validValues?.indexWhere((element) => templateFormat.hasMatch(element)) ??
      -1;
  final List<RequestValue>? validValueGenerators;
  final bool required;
  final String templateFormatStr;
  RegExp get templateFormat => RegExp(templateFormatStr);
  final List<ValueValidator>? customValueValidators;
  final ValueValidator? customValueValidator;

  ///
  /// The *group* matched by [templateFormat] must be the value in [validValues], and the *entire match* will be replaced.
  ///
  /// e.g. If a valid value is "Bearer \*YOUR_ACCESS_TOKEN\*", then [templateFormat] must match \*YOUR_ACCESS_TOKEN\*, and
  /// if YOUR_ACCESS_TOKEN is grouped, that must be in [validValues], but if \*YOUR_ACCESS_TOKEN\* is grouped, that must be in [validValues] instead.
  const RequestParameter({
    required this.required,
    this.validValues,
    this.validValueGenerators,
    this.customValueValidators,
    this.customValueValidator,
    String? templateFormat,
  }) : templateFormatStr =
            templateFormat ?? util.matchAsteriskBoundConstantNameString;

  bool isValid(dynamic proposedValue) {
    if (validValues == null) return /* customValueValidator() ??  */ true;
    if (validValues!.firstWhere(
            (element) =>
                element == proposedValue || element == proposedValue.toString(),
            orElse: () => "") !=
        "") return true;
    for (var val in validValues!) {
      var fm = templateFormat.firstMatch(val);
      if (fm == null) continue;
      if (fm.start == 0 && fm.end == val.length) {
        // if (customValueValidators())
      }
      int lastIndex = 0;
      // templateFormat.allMatches(val).mapAsList((elem, index, list) {
      //   // elem.start
      // })
    }
    // TODO: Validating template strings not implemented
    throw UnimplementedError("Validating template strings not implemented");
  }

  /// TODO: Add support for reformatting strings based on [myType] (i.e. invalid chars)
  ///
  /// If the value selected is not a template, [paramToValueMapping] should be left blank.
  ///
  /// Throws a [UnsupportedError] if [validValues] is [null].
  ///
  /// Throws an [ArgumentError] if [validValues]\[
  /// [valueIndex]\] is [null].
  ///
  /// Throws an [ArgumentError] if [validValues]\[
  /// [valueIndex]\] has a parameter name not present in [paramToValueMapping].
  String generateValidValue({
    int valueIndex = -1,
    ParamToValueMapping? paramToValueMapping,
    RequestParameterType myType = RequestParameterType.body,
  }) {
    if (validValueGenerators == null) {
      if (validValues == null) {
        throw UnsupportedError(
            "validValues or validValueGenerators must be defined to use this method.");
      } else {
        valueIndex = valueIndex < 0 ? nonGeneratedValueIndex : valueIndex;
        if (valueIndex < 0) {
          if (paramToValueMapping == null) {
            throw ArgumentError.value(
                paramToValueMapping,
                "paramToValueMapping",
                "All values are templates that must have values "
                    "in paramToValueMapping to resolve.");
          }
          valueIndex = 0;
        }
        var selectedValue = validValues![valueIndex], retVal = selectedValue;
        if (templateFormat.hasMatch(selectedValue)) {
          var matches = templateFormat.allMatches(selectedValue);
          if (matches.isNotEmpty && paramToValueMapping == null) {
            throw ArgumentError.value(
                paramToValueMapping,
                "paramToValueMapping",
                "The selected value is a template that must have"
                    " values in paramToValueMapping to resolve.");
          }
          var lastMatchEnd = 0;
          retVal = matches.reduceToType((accumulator, elem, index, _) {
            var paramName = elem.group(1);
            if (paramName == null) {
              throw ArgumentError.value(
                  selectedValue,
                  "validValues[$valueIndex]",
                  "The selected value is read incorrectly by the regex and produces an empty result.");
            }
            if (paramToValueMapping![paramName] == null) {
              throw ArgumentError.value(
                  paramToValueMapping[paramName],
                  "paramToValueMapping[$paramName]",
                  "The selected value is a template that must have a non-null value for $paramName.");
            }
            accumulator +=
                selectedValue.substring(lastMatchEnd + 1, elem.start);
            accumulator += paramToValueMapping[paramName].toString();
            lastMatchEnd = elem.end;
            return accumulator;
          }, '');
        }
        return retVal;
      }
    }
    return validValueGenerators![valueIndex].generate(paramToValueMapping);
  }

  /// Like [generateValidValue] but will catch errors and return a null
  /// instead. Use for non-required parameters.
  String? tryGenerateValidValue({
    int valueIndex = -1,
    ParamToValueMapping? paramToValueMapping,
    RequestParameterType myType = RequestParameterType.body,
  }) {
    try {
      return generateValidValue(
        valueIndex: valueIndex,
        paramToValueMapping: paramToValueMapping,
        myType: myType,
      );
    } catch (e) {
      // TODO: Warn
      return null;
    }
  }
}

// TODO: Test
// TODO: Make and manage http.Client (maybe?)
class ApiEndpoint {
  final String method;
  final Uri uri;
  final UriModifier? uriModifier;
  final RegExp? uriMatcher;

  /// Contains the headers for the request, and (optionally) the
  /// acceptable values for them.
  final Map<String, RequestParameter>? headers;

  /// Contains the body parameters for the request, and (optionally) the
  /// acceptable values for them.
  final Map<String, RequestParameter>? bodyParameters;

  /// Contains the query parameters for the request, and (optionally) the
  /// acceptable values for them.
  final Map<String, RequestParameter>? queryParameters;

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

  static bool validateParams(
          Map<String, RequestParameter>? local,
          Map<String, (int, ParamToValueMapping?)>?
              arg) => /* (arg?.isNotEmpty ?? false) && */
      local!.entries.reduceUntilTrue(
          (bAcc, elem, i, _) => (!elem.value.required ||
                  !elem.value.requiresParameters ||
                  !(arg?.containsKey(elem.key) ?? false))
              ? (bAcc, false)
              : (false, true),
          true);
  static void perform(
      Map<String, RequestParameter>? local,
      Map<String, (int, ParamToValueMapping?)>? arg,
      void Function(String key, String output) onSuccess) {
    for (var element in (arg ?? {}).entries) {
      var rp = local![element.key];
      if (rp != null) {
        var output = rp.required
            ? rp.generateValidValue(
                valueIndex: element.value.$1,
                paramToValueMapping: element.value.$2)
            : rp.tryGenerateValidValue(
                valueIndex: element.value.$1,
                paramToValueMapping: element.value.$2);
        if (output != null) {
          // newQP[element.key] = output;
          onSuccess(element.key, output);
        } else {
          // TODO: Warn of discarded optional value
        }
      } else {
        // TODO: Warn of missing expected key
      }
    }
  }

  http.Request genRequest({
    Map<String, (int, ParamToValueMapping?)>? query,
    Map<String, (int, ParamToValueMapping?)>? body,
    Map<String, (int, ParamToValueMapping?)>? headers,
    Map<String, dynamic>? uriModifierParam,
  }) =>
      requestGeneration(
          uri: uri,
          method: method,
          uriMatcher: uriMatcher,
          uriModifier: uriModifier,
          headerParameters: this.headers,
          bodyParameters: bodyParameters,
          queryParameters: queryParameters,
          body: body,
          headers: headers,
          query: query,
          uriModifierParam: uriModifierParam);

  static http.Request requestGeneration({
    required Uri uri,
    required String method,
    required RegExp? uriMatcher,
    required UriModifier? uriModifier,
    required Map<String, RequestParameter>? headerParameters,
    required Map<String, RequestParameter>? bodyParameters,
    required Map<String, RequestParameter>? queryParameters,
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
    } else if (validateParams(queryParameters, query)) {
      // add query
      Map<String, String> newQP = {};
      perform(
        queryParameters,
        query,
        (key, output) => newQP[key] = output,
      );
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
    if (headerParameters?.isEmpty ?? true) {
      // Shortcut headers setup
    } else if (validateParams(headerParameters, headers)) {
      // add headers
      perform(
        headerParameters,
        headers,
        (key, output) => req.headers[key] = output,
      );
    } else {
      // headerParameters are not fulfilled by headers
      throw ArgumentError.value(
        headers,
        "headers",
        "Value doesn't cover required parameters",
      );
    }
    if (bodyParameters?.isEmpty ?? true) {
      // Shortcut body setup
    } else if (validateParams(bodyParameters, body)) {
      // add body
      Map<String, String> newBody = {};
      perform(
        bodyParameters,
        body,
        (key, output) => newBody[key] = output,
      );
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

class ApiEndpointInstance implements ApiEndpoint {
  @override
  String method;
  @override
  Uri uri;
  @override
  Uri Function(Uri base, RegExp? matcher, Map<String, dynamic> map)?
      uriModifier;
  @override
  RegExp? uriMatcher;

  /// Contains the headers for the request, and (optionally) the
  /// acceptable values for them.
  @override
  Map<String, RequestParameter>? headers;

  /// Contains the body parameters for the request, and (optionally) the
  /// acceptable values for them.
  @override
  Map<String, RequestParameter>? bodyParameters;

  /// Contains the query parameters for the request, and (optionally) the
  /// acceptable values for them.
  @override
  Map<String, RequestParameter>? queryParameters;

  @override
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
  @override
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

  @override
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

  @override
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

  @override
  http.Request genRequest({
    Map<String, (int, ParamToValueMapping?)>? query,
    Map<String, (int, ParamToValueMapping?)>? body,
    Map<String, (int, ParamToValueMapping?)>? headers,
    Map<String, dynamic>? uriModifierParam,
  }) =>
      ApiEndpoint.requestGeneration(
          uri: uri,
          method: method,
          uriMatcher: uriMatcher,
          uriModifier: uriModifier,
          headerParameters: this.headers,
          bodyParameters: bodyParameters,
          queryParameters: queryParameters,
          body: body,
          headers: headers,
          query: query,
          uriModifierParam: uriModifierParam);
  @override
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

  @override
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

Future<String> decompressGzPlainTextStream(http.StreamedResponse r) => r
  .stream
  .toBytes()
  .then((v) => http.ByteStream.fromBytes(
      archive.GZipDecoder().decodeBytes(v.toList(growable: false)),
    ).bytesToString());