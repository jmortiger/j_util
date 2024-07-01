import 'dart:async';
import 'dart:convert' as dc;

import 'package:archive/archive.dart' as archive
  if (dart.library.io) 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:j_util/src/types.dart';
import 'package:j_util/src/extensions.dart';
import 'package:j_util/src/j_util_base.dart' as util;
//import 'package:logging/logging.dart' as logging;
// TODO: http.Client override w/ auto rate-limiting
/* String getBasicAuthHeaderValue(String identifier, String secret) =>
    'Basic ${dc.base64Encode(dc.ascii.encode(
        '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
      ))}'; */
String getBasicAuthHeaderValue(String identifier, String secret) =>
    'Basic ${getAsciiBase64Encoding(
      '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
    )}';
/// [input] should follow the format `urlEncodedIdentifier:urlEncodedSecret` 
/// for a Basic Authorization header value, and should prepend the return value
/// with `Basic `.
String getAsciiBase64Encoding(String input) =>
    dc.base64Encode(dc.ascii.encode(input));

Future<String> decompressGzPlainTextStream(http.StreamedResponse r) => r
  .stream
  .toBytes()
  .then((v) => http.ByteStream.fromBytes(
      archive.GZipDecoder().decodeBytes(v.toList(growable: false)),
    ).bytesToString());

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

  static HttpMethod getFromString(String method) => switch (method.toUpperCase()) {
    "GET" => get,
    "POST" => post,
    "HEAD" => head,
    "PUT" => put,
    "DELETE" => delete,
    "PATCH" => patch,
    _ => throw UnsupportedError("Unsupported method"),
  };
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
typedef ParamValueMap = Map<String, dynamic>;
typedef Validator<T> = String Function(String replacedParam, T proposedValue);
typedef MapGenerator = String Function(
  ParamValueMap? variableToProposedValue,
);
typedef UriModifier = Uri Function(String baseUri, RegExp? matcher, Map<String, dynamic> map);

final class RequestValue {
  /// The basic format of the value. e.g. for a `Content-Type` header, might look
  /// like `*MIME_TYPE*/*MIME_SUBTYPE*; *OPTIONAL_PARAMETER*=*OPTIONAL_VALUE*`,
  /// which could be result in an ultimate output of `text/html; charset=utf-8`.
  /// This may not represent the output's format; the [typedGenerator] can
  /// completely ignore this if that behavior is desired, or it can use it in a
  /// different way (like a basic `Authorization` using `*IDENTIFIER*:*SECRET*`
  /// in order to set up the string for base64 encoding and the return a value
  /// of `Basic encodedStringHere`). This should remove as much formatting as
  /// possible from the [typedGenerator]. If there remains no formatting to be
  /// done at all, and only parameters to replace, then the default value for
  /// [typedGenerator] will suffice.
  final String baseString;
  /// {@template RequestValue.templateFormat}
  /// The *group* matched by [templateFormat] must be the *key* in the map 
  /// passed to [generate], and the *entire match* will be replaced.
  ///
  /// e.g. If [baseString] is `Bearer *YOUR_ACCESS_TOKEN*`, then 
  /// [templateFormat] must match `*YOUR_ACCESS_TOKEN*`, and if 
  /// `YOUR_ACCESS_TOKEN` is grouped, that must be the key in the map passed to
  /// [generate], but if `*YOUR_ACCESS_TOKEN*` is grouped, that must be the key
  /// in the map passed to [generate] instead.
  /// {@endtemplate}
  final String templateFormatStr;
  /// {@macro RequestValue.templateFormat}
  RegExp get templateFormat => RegExp(templateFormatStr);
  final Generator? generator;
  final MapGenerator? _typedGenerator;
  MapGenerator get typedGenerator => _typedGenerator ?? _defaultGenerator;
  final Validator? validator;
  final List<Type>? validTypes;
  List<String> get parameters => templateFormat.allMatches(baseString).reduceToType((accumulator, elem, index, list) => (elem.group(1)?.isNotEmpty ?? false) ? (accumulator..add(elem.group(1)!)) : accumulator, <String>[]);

  const RequestValue({
    required this.baseString,
    this.generator,
    MapGenerator? typedGenerator,
    this.validator,
    this.validTypes,
    String? templateFormat,
  })  : templateFormatStr =
            templateFormat ?? RegExpExt.asteriskBoundConstantString,
        _typedGenerator = typedGenerator;

  String generate(ParamValueMap? mapping) =>
      typedGenerator.call(mapping);

  String dispatchGenerator(String Function(Function)? dispatcher) =>
      generator?.generate(dispatcher);

  String _defaultGenerator(ParamValueMap? mapping) =>
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
      ((validValues?.isNotEmpty ?? false) &&
      !validValues!.any((element) => templateFormat.hasMatch(element))) ||
      ((validValueGenerators?.isNotEmpty ?? false) &&
      !validValueGenerators!.any((element) => element.parameters.isNotEmpty));
  int get nonGeneratedValueIndex =>
      validValues?.indexWhere((element) => templateFormat.hasMatch(element)) ??
      -1;
  List<List<String>> get validValueParameters => (validValues ?? []).reduceToType(
    (acc, elem, i, l) => acc..add(templateFormat.allMatches(elem).reduceToType(
      (a, e, _, __) => (e.group(1)?.isNotEmpty ?? false) ? (a..add(e.group(1)!)) : a, 
      <String>[])), 
    <List<String>>[]);
  final List<RequestValue>? validValueGenerators;
  List<List<String>> get valueGeneratorParams => (validValueGenerators ?? []).mapAsList((e, index, list) => e.parameters);
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
  /// TODO: Better account for same # of matching params (e.g. which has few overall params).
  int findNonGeneratedIndexOfParams(List<String> params) {
    // validValueParameters.reduceUntilTrue((accumulator, elem, index, list) {
    //   var t = elem.where((element) => params.contains(element)).length;
    //   if (t == list.length) {
    //     return (accumulator..add(t), true);
    //   }
    //   return (accumulator..add(t), false);
    // }, []);
    /* validValueParameters.reduceToType((acc, elem, i, l) => acc..add(
      elem.where((element) => params.contains(element)).length,
      ), []); */
    return validValueParameters.reduceToType((acc, elem, i, l) {
      var t = elem.where((element) => params.contains(element)).length;
      return (t > acc.$1) ? (t, i) : acc;
    }, (-1, -1)).$2;
  }
  /// TODO: Better account for same # of matching params (e.g. which has few overall params).
  int findGeneratorIndexOfParams(List<String> params) {
    // valueGeneratorParams.reduceUntilTrue((accumulator, elem, index, list) {
    //   var t = elem.where((element) => params.contains(element)).length;
    //   if (t == list.length) {
    //     return (accumulator..add(t), true);
    //   }
    //   return (accumulator..add(t), false);
    // }, []);
    /* valueGeneratorParams.reduceToType((acc, elem, i, l) => acc..add(
      elem.where((element) => params.contains(element)).length,
      ), []); */
    return valueGeneratorParams.reduceToType((acc, elem, i, l) {
      var t = elem.where((element) => params.contains(element)).length;
      return (t > acc.$1) ? (t, i) : acc;
    }, (-1, -1)).$2;
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
    ParamValueMap? paramToValueMapping,
    RequestParameterType myType = RequestParameterType.body,
  }) {
    if (validValueGenerators == null) {
      if (validValues == null) {
        throw UnsupportedError(
            "validValues or validValueGenerators must be defined to use this method.");
      } else {
        // TODO: WARN defaulting to nonGeneratedValueIndex
        valueIndex = valueIndex < 0 ? nonGeneratedValueIndex : valueIndex;
        if (valueIndex < 0) {
          if (paramToValueMapping == null) {
            throw ArgumentError.value(
                paramToValueMapping,
                "paramToValueMapping",
                "All values are templates that must have values "
                    "in paramToValueMapping to resolve.");
          }
          if (valueIndex < 0) {
            // TODO: WARN we're guessing which index to use
            valueIndex = findNonGeneratedIndexOfParams(paramToValueMapping.keys.toList());
          }
        // TODO: WARN defaulting to zero
          if (valueIndex < 0) valueIndex = 0;
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
    if (valueIndex < 0) {
      if (paramToValueMapping != null) {
        // TODO: WARN we're guessing which index to use
        valueIndex = findGeneratorIndexOfParams(paramToValueMapping.keys.toList());
      }
      if (valueIndex < 0) {
        // TODO: WARN defaulting to zero
        valueIndex = 0;
      }
    }
    return validValueGenerators![valueIndex].generate(paramToValueMapping);
  }

  /// Like [generateValidValue] but will catch errors and return a null
  /// instead. Use for non-required parameters.
  String? tryGenerateValidValue({
    int valueIndex = -1,
    ParamValueMap? paramToValueMapping,
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
typedef RequestParameterValues = Map<String, (int, ParamValueMap?)>;
// TODO: Test
// TODO: Make and manage http.Client (maybe?)
class ApiEndpoint {
  final String method;
  Uri get uri => (_uriString != null) ? Uri.parse(_uriString!) : _uri!;
  final Uri? _uri;
  final String? _uriString;
  String get uriString => (_uriString != null) ? _uriString! : _uri!.toString();
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
    required Uri /* this. */uri,
    this.uriModifier,
    this.uriMatcher,
    this.headers,
    this.bodyParameters,
    this.queryParameters,
    this.responseFormat,
  }) : _uriString = null,
      _uri = uri;
  const ApiEndpoint.parameterizedUri({
    required this.method,
    required String /* this. */uriString,
    this.uriModifier,
    this.uriMatcher,
    this.headers,
    this.bodyParameters,
    this.queryParameters,
    this.responseFormat,
  }) : _uriString = uriString,
      _uri = null;
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
    UriModifier? uriModifier,
    String baseUri,
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
      return uriModifier.call(baseUri, uriMatcher, uriModifierParam);
    }
    return Uri.parse(baseUri);
  }

  static bool validateParams(
          Map<String, RequestParameter>? local,
          Map<String, (int, ParamValueMap?)>?
              arg) => /* (arg?.isNotEmpty ?? false) && */
      local?.entries.reduceUntilTrue(
          (bAcc, elem, i, _) => (!elem.value.required ||
                  !elem.value.requiresParameters ||
                  !(arg?.containsKey(elem.key) ?? false))
              ? (bAcc, false)
              : (false, true),
          true) ?? false;
  static void perform(
      Map<String, RequestParameter>? local,
      Map<String, (int, ParamValueMap?)>? arg,
      void Function(String key, String output) onSuccess) {
    for (var element in (local ?? {}).entries) {
      var rp = local![element.key];
      if (rp != null) {
        var a = arg?[element.key];
        var output = rp.required
            ? rp.generateValidValue(
                valueIndex: a?.$1 ?? 0,
                paramToValueMapping: a?.$2)
            : rp.tryGenerateValidValue(
                valueIndex: a?.$1 ?? 0,
                paramToValueMapping: a?.$2);
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
    RequestParameterValues? query,
    RequestParameterValues? body,
    RequestParameterValues? headers,
    Map<String, dynamic>? uriModifierParam,
  }) =>
      requestGeneration(
          uriString: uriString,
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
    required String uriString,
    required String method,
    required RegExp? uriMatcher,
    required UriModifier? uriModifier,
    required Map<String, RequestParameter>? headerParameters,
    required Map<String, RequestParameter>? bodyParameters,
    required Map<String, RequestParameter>? queryParameters,
    Map<String, (int, ParamValueMap?)>? query,
    Map<String, (int, ParamValueMap?)>? body,
    Map<String, (int, ParamValueMap?)>? headers,
    Map<String, dynamic>? uriModifierParam,
  }) {
    var tempUrl = applyUriModification(
      uriModifier,
      uriString,
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
    Map<String, (int, ParamValueMap?)>? query,
    Map<String, (int, ParamValueMap?)>? body,
    Map<String, (int, ParamValueMap?)>? headers,
    Map<String, dynamic>? uriModifierParam,
  }) =>
      client.send(genRequest(
        body: body,
        headers: headers,
        query: query,
        uriModifierParam: uriModifierParam,
      ));

  Future<http.StreamedResponse> sendRequest({
    Map<String, (int, ParamValueMap?)>? query,
    Map<String, (int, ParamValueMap?)>? body,
    Map<String, (int, ParamValueMap?)>? headers,
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
  // TODO: implement _uri
  Uri? get _uri => throw UnimplementedError();

  @override
  // TODO: implement _uriString
  String? get _uriString => throw UnimplementedError();

  @override
  // TODO: implement uriString
  String get uriString => throw UnimplementedError();
  @override
  String method;
  @override
  Uri uri;
  @override
  UriModifier? uriModifier;
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
    Map<String, (int, ParamValueMap?)>? query,
    Map<String, (int, ParamValueMap?)>? body,
    Map<String, (int, ParamValueMap?)>? headers,
    Map<String, dynamic>? uriModifierParam,
  }) =>
      ApiEndpoint.requestGeneration(
          uriString: uriString,
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
    Map<String, (int, ParamValueMap?)>? query,
    Map<String, (int, ParamValueMap?)>? body,
    Map<String, (int, ParamValueMap?)>? headers,
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
    Map<String, (int, ParamValueMap?)>? query,
    Map<String, (int, ParamValueMap?)>? body,
    Map<String, (int, ParamValueMap?)>? headers,
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

Map<String, dynamic> prepareQueryParameters(Map<String, dynamic> queryParameters) => queryParameters..updateAll((k, v) {
    dynamic recurse(val) => switch (val) {
      String v1 => v1,
      Iterable v1 => v1.map(recurse),
      _ => val.toString(),
    };
    return recurse(v);
  });