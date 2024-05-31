import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:webview_flutter/webview_flutter.dart';

// TODO: remove json packages from dependancies
final class OAuthConfig {
  // static final String pathToCredentials = par;
  OAuthConfig({
    required this.identifier,
    required this.secret,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.redirectUrl,
    required this.credentialsFile,
    this.basicAuth = true,
    CredentialsRefreshedCallback? onCredentialsRefreshed = _replace,
  }) : onCredentialsRefreshed = (onCredentialsRefreshed == OAuthConfig._replace)
            ? getDefaultRefreshedCredentials(credentialsFile)
            : onCredentialsRefreshed;
  static void _replace(oauth2.Credentials newCredentials) {}
  // final OAuthClientConfig config;
  final String identifier;
  final String secret;

  /// Endpoint for authorization code creation.
  final Uri authorizationEndpoint;

  /// Endpoint for access token creation.
  final Uri tokenEndpoint;
  final Uri redirectUrl;
  final File credentialsFile;
  final bool basicAuth;

  factory OAuthConfig.fromJson(Map<String, dynamic> json) => OAuthConfig(
        identifier: json["identifier"] as String,
        secret: json["secret"] as String,
        authorizationEndpoint: json["authorizationEndpoint"] as Uri,
        tokenEndpoint: json["tokenEndpoint"] as Uri,
        redirectUrl: json["redirectUrl"] as Uri,
        credentialsFile: File(json['credentialsFile'] as String),
        basicAuth: json['basicAuth'] as bool,
      );

  Map<String, dynamic> toJson(OAuthConfig instance) => <String, dynamic>{
        "identifier": instance.identifier,
        "secret": instance.secret,
        "authorizationEndpoint": instance.authorizationEndpoint,
        "tokenEndpoint": instance.tokenEndpoint,
        "redirectUrl": instance.redirectUrl,
        "credentialsFile": instance.credentialsFile.absolute.path,
        "basicAuth": instance.basicAuth,
      };

  final CredentialsRefreshedCallback? onCredentialsRefreshed;

  void defaultRefreshedCredentials(oauth2.Credentials newCredentials) =>
      credentialsFile.writeAsString(
        newCredentials.toJson(),
        mode: FileMode.write,
        flush: true,
      );

  static oauth2.CredentialsRefreshedCallback getDefaultRefreshedCredentials(
          File credentialsFile) =>
      (oauth2.Credentials newCredentials) => credentialsFile.writeAsString(
            newCredentials.toJson(),
            mode: FileMode.write,
            flush: true,
          );
  OAuthClientConfig createClientConfig(
    Credentials credentials, {
    bool basicAuth = true,
    onCredentialsRefreshed = _replace,
  }) =>
      OAuthClientConfig(
        credentials: credentials,
        basicAuth: basicAuth,
        onCredentialsRefreshed: (onCredentialsRefreshed == OAuthConfig._replace)
            ? getDefaultRefreshedCredentials(credentialsFile)
            : onCredentialsRefreshed,
      );
}

final class OAuthClientConfig {
  CredentialsRefreshedCallback? onCredentialsRefreshed;
  Credentials credentials;
  final bool basicAuth;
  OAuthClientConfig({
    required this.credentials,
    this.basicAuth = true,
    this.onCredentialsRefreshed,
  });
}

class WOAuthManager extends StatefulWidget {
  // #region Static Members
  static final Map<OAuthConfig, Client> validClients = <OAuthConfig, Client>{};
  static Future<oauth2.Client> generateValidClient(
    BuildContext context,
    OAuthConfig config,
  ) async {
    if (validClients[config] != null) return validClients[config]!;
    var c = await tryLoadingCredentials(config);
    if (c != null) {
      return validClients[config] = instantiate2(config, c);
    }
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: WOAuthManager(
          onSuccessCallback: (vc) => validClients[config] = vc,
          config: config,
        ), // actions: <Widget>[],
      ),
    );
    return validClients[config]!;
  }

  static oauth2.Client instantiate(
          OAuthConfig config, OAuthClientConfig data) =>
      oauth2.Client(
        data.credentials,
        identifier: config.identifier,
        secret: config.secret,
        onCredentialsRefreshed: config.onCredentialsRefreshed,
        basicAuth: data.basicAuth,
      );

  static oauth2.Client instantiate2(OAuthConfig config, Credentials credentials,
          {bool basicAuth = true}) =>
      oauth2.Client(
        credentials,
        identifier: config.identifier,
        secret: config.secret,
        onCredentialsRefreshed: config.onCredentialsRefreshed,
        basicAuth: basicAuth,
      );

  oauth2.Client iInstantiate(OAuthClientConfig data) => oauth2.Client(
        data.credentials,
        identifier: config.identifier,
        secret: config.secret,
        onCredentialsRefreshed: config.onCredentialsRefreshed,
        basicAuth: data.basicAuth,
      );

  oauth2.Client iInstantiate2(Credentials credentials,
          {bool basicAuth = true}) =>
      oauth2.Client(
        credentials,
        identifier: config.identifier,
        secret: config.secret,
        onCredentialsRefreshed: config.onCredentialsRefreshed,
        basicAuth: basicAuth,
      );

  static Future<oauth2.Credentials> overwriteCredentials(
      String credentialJson) {
    throw UnimplementedError("not implemented");
  }

  static Future<oauth2.Credentials?> tryLoadingCredentials(
      OAuthConfig config) async {
    if (await config.credentialsFile.exists()) {
      try {
        return oauth2.Credentials.fromJson(
            await config.credentialsFile.readAsString());
      } on FormatException {
        return null;
      } catch (e) {
        // rethrow;
        return null;
      }
    }
    return null;
  }

  static Future<(oauth2.Client?, OAuthClientConfig)> tryReloadClient(
      OAuthConfig config, OAuthClientConfig clientConfig) async {
    var exists = await config.credentialsFile.exists();

    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (exists) {
      var credentials = await tryLoadingCredentials(config);
      if (credentials == null) {
        return (null, clientConfig);
      } else {
        clientConfig.credentials = credentials;
        return (
          oauth2.Client(
            credentials,
            identifier: config.identifier,
            secret: config.secret,
            onCredentialsRefreshed: config.onCredentialsRefreshed,
            basicAuth: clientConfig.basicAuth,
          ),
          clientConfig
        );
      }
    } else {
      await config.credentialsFile.create(recursive: true, exclusive: true);
      return (null, clientConfig);
    }
  }
  // #endregion Static Members

  final OAuthConfig config;

  final void Function(oauth2.Client authorizedClient) onSuccessCallback;
  final WebViewController controller;
  WOAuthManager({
    super.key,
    required this.onSuccessCallback,
    required this.config,
  }) : controller = WebViewController() {
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setOnConsoleMessage(
          (message) => print("WebConsole: ${message.message}"));
  }
  @override
  State<WOAuthManager> createState() => _WOAuthManagerState();
}

class _WOAuthManagerState extends State<WOAuthManager> {
  late final bool _exists;
  late final oauth2.Credentials _credentials;
  Uri? _returnUri;
  int progressPercent = -1;

  _WOAuthManagerState() {
    refreshExists()
        .then((_) => refreshCredentials().then((_) => refreshClient()));
    widget.controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) => progressPercent = progress,
        onPageStarted: (String url) => progressPercent = 0,
        onPageFinished: (String url) => progressPercent = -1,
        onWebResourceError: (WebResourceError error) => print(error),
        onNavigationRequest: (NavigationRequest request) {
          print(request.url);
          // if (request.url.startsWith(WOAuthManager.redirectUrlString)) {
          // if (request.url.startsWith("${WOAuthManager.redirectUrl.origin}${WOAuthManager.redirectUrl.path}")) {
          if (request.url.startsWith(widget.config.redirectUrl.toString())) {
            _returnUri = Uri.parse(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    createClient().then((value) => widget.onSuccessCallback(value));
  }

  Future<void> refreshExists() async =>
      _exists = await widget.config.credentialsFile.exists();

  oauth2.Credentials? tryFromFile(String jsonString) {
    try {
      return oauth2.Credentials.fromJson(jsonString);
    } on FormatException {
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshCredentials() async {
    if (_exists) {
      _credentials = oauth2.Credentials.fromJson(
          await widget.config.credentialsFile.readAsString());
    }
  }

  Future<oauth2.Credentials?> tryLoadingCredentials() async {
    try {
      return _credentials;
    } catch (e) {
      await refreshCredentials();
      return _credentials;
    }
  }

  Future<void> refreshClient() async => _exists
      ? await refreshCredentials().then((_) => WOAuthManager
          .validClients[widget.config] = widget.iInstantiate2(_credentials))
      : null;

  Future<Uri> retrieveAuthResponseUrl() async {
    while (_returnUri == null) {
      await Future.delayed(
        const Duration(seconds: 2, milliseconds: 500),
      );
    }
    return _returnUri ?? Uri();
  }

  Future<oauth2.Client> createClient() async {
    var exists = await widget.config.credentialsFile.exists();

    if (exists) {
      var credentials =
          await WOAuthManager.tryLoadingCredentials(widget.config);
      if (credentials != null) {
        try {
          _credentials = credentials;
        } catch (e) {}
        return WOAuthManager.validClients[widget.config] =
            widget.iInstantiate2(credentials);
      }
    } else {
      await widget.config.credentialsFile
          .create(recursive: true, exclusive: true);
    }

    var grant = oauth2.AuthorizationCodeGrant(
      widget.config.identifier,
      widget.config.authorizationEndpoint,
      widget.config.tokenEndpoint,
      secret: widget.config.secret,
      basicAuth: widget.config.basicAuth,
      // enablePKCE: false,
      onCredentialsRefreshed: widget.config.onCredentialsRefreshed,
    );

    var authorizationUrl =
        grant.getAuthorizationUrl(widget.config.redirectUrl /* , scopes:  */);

    await widget.controller.loadRequest(authorizationUrl);
    Uri responseUrl = await retrieveAuthResponseUrl();

    return WOAuthManager.validClients[widget.config] =
        await grant.handleAuthorizationResponse(responseUrl.queryParameters);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (progressPercent >= 0 && progressPercent < 100)
          LinearProgressIndicator(
            value: progressPercent / 100,
            semanticsLabel: "Loading progress",
            semanticsValue: "$progressPercent%",
          ),
        WebViewWidget(controller: widget.controller),
      ],
    );
  }
}

class POAuthManager extends StatelessWidget {
  final WOAuthManager widget;
  POAuthManager({
    super.key,
    required void Function(oauth2.Client) onSuccessCallback,
    required OAuthConfig config,
  }) : widget = WOAuthManager(
          onSuccessCallback: onSuccessCallback,
          config: config,
        );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticate'),
        actions: <Widget>[
          IconButton(
            tooltip: "clearCache",
            onPressed: () => widget.controller.clearCache(),
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            tooltip: "clearLocalStorage",
            onPressed: () => widget.controller.clearLocalStorage(),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: widget,
    );
  }
}
