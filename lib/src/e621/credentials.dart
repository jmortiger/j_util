import 'dart:convert' as dc;
import 'package:flutter/services.dart';
import 'package:j_util/j_util_full.dart';

final devDataString = LazyInitializer<String>(
    () => (rootBundle.loadString("assets/devData.json")));
final devDataObj = LazyInitializer<Map<String, dynamic>>(
    () async => dc.jsonDecode(await devDataString.getItem()));

final class AccessData {
  static final devAccessData = LazyInitializer<AccessData>(() async =>
      AccessData.fromJson(
          (await devDataObj.getItem())["e621"] as Map<String, dynamic>));
  static String? get devApiKey => devAccessData.$Safe?.apiKey;
  static String? get devUsername => devAccessData.$Safe?.username;
  static String? get devUserAgent => devAccessData.$Safe?.userAgent;
  // static get devData => _devData;
  static final userData = LateFinal<AccessData>();
  final String apiKey;
  final String username;
  final String userAgent;
  E6Credentials get cred => E6Credentials(username: username, apiKey: apiKey);

  const AccessData({
    required this.apiKey,
    required this.username,
    required this.userAgent,
  });
  Map<String, dynamic> toJson() => {
        "apiKey": apiKey,
        "username": username,
        "userAgent": userAgent,
      };
  factory AccessData.fromJson(Map<String, dynamic> json) => AccessData(
        apiKey: json["apiKey"] as String,
        username: json["username"] as String,
        userAgent: json["userAgent"] as String,
      );
  // Map<String,String> generateHeaders() {

  // }
}

class BaseCredentials {
  static const headerKey = "Authorization";
  void addToHeadersMap(Map<String, dynamic> headers) =>
      headers[BaseCredentials.headerKey] = headerValue;
  final String headerValue;
  BaseCredentials({
    required String identifier,
    required String secret,
  }) : headerValue = 'Basic ${dc.base64Encode(dc.ascii.encode(
          '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
        ))}';

  static String getAuthHeaderValue(
    String identifier,
    String secret,
  ) =>
      'Basic ${dc.base64Encode(dc.ascii.encode(
        '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
      ))}';
  BaseCredentials._direct(this.headerValue);
  factory BaseCredentials.fromJson(Map<String, dynamic> json) =>
      BaseCredentials._direct(json["headerValue"]);
  Map<String, dynamic> toJson() => {"headerValue": headerValue};
}

class E6Credentials extends BaseCredentials {
  static E6Credentials? currentCredentials;
  final String username;
  final String apiKey;

  E6Credentials({
    required this.username,
    required this.apiKey,
  }) : super(identifier: username, secret: apiKey);
  E6Credentials._direct({
    required this.username,
    required this.apiKey,
    required String headerValue,
  }) : super._direct(headerValue);
  factory E6Credentials.fromJson(Map<String, dynamic> json) =>
      json["headerValue"] == null
          ? E6Credentials(
              username: json["username"],
              apiKey: json["apiKey"],
            )
          : E6Credentials._direct(
              username: json["username"],
              apiKey: json["apiKey"],
              headerValue: json["headerValue"],
            );
  @override
  Map<String, dynamic> toJson() => {
        "username": username,
        "apiKey": apiKey,
        "headerValue": headerValue,
      };
}
