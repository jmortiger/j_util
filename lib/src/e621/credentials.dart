import 'dart:convert' as dc;

/// TODO: Credential reform
/// TODO: Use user agent in api calls
final class AccessData {
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
/* import 'dart:convert' as dc;

final class AccessData {
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
  }) : headerValue = getAuthHeaderValue(identifier, secret);

  static String getAuthHeaderValue(
    String identifier,
    String secret,
  ) =>
      'Basic ${dc.base64Encode(dc.ascii.encode(
        '${Uri.encodeFull(identifier)}:${Uri.encodeFull(secret)}',
      ))}';

  /// {@template DirectInit}
  /// Input must be congruent with the output of [getAuthHeaderValue].
  ///
  /// This should only be used for the retrieval of a previously encoded and
  /// stored credential.
  /// {@endtemplate}
  const BaseCredentials.encrypted(this.headerValue);
  factory BaseCredentials.fromJson(Map<String, dynamic> json) =>
      BaseCredentials.encrypted(json["headerValue"]);
  Map<String, dynamic> toJson() => {"headerValue": headerValue};
}

class E6Credentials extends BaseCredentials {
  static E6Credentials? currentCredentials;
  final String username;
  // final String apiKey;

  E6Credentials({
    required this.username,
    required /* this. */String apiKey,
  }) : super(identifier: username, secret: apiKey);
  /// {@macro DirectInit}
  const E6Credentials.encrypted({
    required this.username,
    /* required this. */String apiKey = "",
    required String headerValue,
  }) : super.encrypted(headerValue);
  factory E6Credentials.fromJson(Map<String, dynamic> json) =>
      json["headerValue"] == null
          ? E6Credentials(
              username: json["username"],
              apiKey: json["apiKey"],
            )
          : E6Credentials.encrypted(
              username: json["username"],
              // apiKey: json["apiKey"],
              headerValue: json["headerValue"],
            );
  @override
  Map<String, dynamic> toJson() => {
        "username": username,
        // "apiKey": apiKey,
        "headerValue": headerValue,
      };
}
 */