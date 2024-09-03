// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert' as dc;

import 'package:archive/archive.dart' as archive
  if (dart.library.io) 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:j_util/src/types.dart';
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

Map<String, dynamic> prepareQueryParameters(Map<String, dynamic> queryParameters) => queryParameters..updateAll((k, v) {
    dynamic recurse(val) => switch (val) {
      String v1 => v1,
      Iterable v1 => v1.map(recurse),
      _ => val.toString(),
    };
    return recurse(v);
  });