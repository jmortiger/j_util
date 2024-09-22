// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert' as dc;

import 'package:archive/archive.dart'
    if (dart.library.io) 'package:archive/archive_io.dart' show GZipDecoder;
import 'package:http/http.dart' as http;
import 'package:j_util/src/types.dart';

// TODO: http.Client override w/ auto rate-limiting
String getBasicAuthHeaderValue(String identifier, String secret) =>
    'Basic ${getAsciiBase64Encoding(
      '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
    )}';

/// [input] should follow the format `urlEncodedIdentifier:urlEncodedSecret`
/// for a Basic Authorization header value, and should prepend the return value
/// with `Basic `.
String getAsciiBase64Encoding(String input) =>
    dc.base64Encode(dc.ascii.encode(input));

Future<String> decompressGzPlainTextStream(http.StreamedResponse r) =>
    r.stream.toBytes().then((v) => http.ByteStream.fromBytes(
          GZipDecoder().decodeBytes(v.toList(growable: false)),
        ).bytesToString());

enum HttpMethod with PrettyPrintEnum {
  get,
  post,
  head,
  put,
  delete,
  patch;

  static const String GET = "GET",
      POST = "POST",
      HEAD = "HEAD",
      PUT = "PUT",
      DELETE = "DELETE",
      PATCH = "PATCH";

  static HttpMethod getFromString(String method) =>
      switch (method.toUpperCase()) {
        "GET" => get,
        "POST" => post,
        "HEAD" => head,
        "PUT" => put,
        "DELETE" => delete,
        "PATCH" => patch,
        _ => throw UnsupportedError("Unsupported method"),
      };
  @Deprecated("Use allowsBody")
  bool canHaveBody() => this != HttpMethod.get && this != HttpMethod.head;
  bool get allowsBody => this != HttpMethod.get && this != HttpMethod.head;

  @override
  String toString() => nameUpper;
}

Map<String, dynamic> prepareQueryParameters(Map<String, dynamic> parameters) =>
    parameters
      ..updateAll((k, v) {
        dynamic recurse(val) => switch (val) {
              String v1 => v1,
              Iterable v1 => v1.map(recurse),
              _ => val.toString(),
            };
        return recurse(v);
      });
