import 'dart:async';
// import 'dart:collection' show ListQueue;
import 'dart:convert' as dc;
import 'package:http/http.dart' as http;

import 'credentials.dart';
import 'e621.dart';
// import 'general_enums.dart' as ge;
// import 'search_enums.dart' as se;

/// Use this to automatically enforce rate limit.
// ignore: unnecessary_late
late http.Client client = http.Client();

// #region Rate Limit
/// The hard rate limit in seconds per request.
///
/// `hardRateLimit = Duration(seconds: 1);`
const hardRateLimit = Duration(seconds: 1);

/// The soft rate limit in seconds per request.
///
/// `softRateLimit = Duration(seconds: 2);`
const softRateLimit = Duration(seconds: 2);

/// The ideal rate limit in seconds per request.
///
/// The ideal rate limit is a way to ensure that the true rate limit is never even approached.
///
/// `idealRateLimit = Duration(seconds: 3);`
const idealRateLimit = Duration(seconds: 3);
bool forceHardLimit = false;
bool useIdealLimit = true;
Duration get currentRateLimit => forceHardLimit
    ? hardRateLimit
    : useIdealLimit
        ? idealRateLimit
        : softRateLimit;
DateTime timeOfLastRequest =
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
int defaultBurstLimit = 60;
int get currentBurstLimit => defaultBurstLimit;
// ListQueue<DateTime> burstTimes = ListQueue(defaultBurstLimit - 1);
List<DateTime> burstTimes = <DateTime>[];
/* typedef ApiStreamEvent = (http.StreamedResponse, DateTime);
final StreamController<ApiStreamEvent> _responseStreamController =
    StreamController<ApiStreamEvent>.broadcast(
  onListen: _onListen,
  onCancel: _onCancel,
);
Stream<ApiStreamEvent> get responseStream => _responseStreamController.stream;

void _onListen() {}
// void _onPause() {}
// void _onResume() {}
void _onCancel() {} */

/// Won't blow the rate limit
Future<http.StreamedResponse> sendRequestStreamed(
  http.BaseRequest request, {
  bool useBurst = false,
  bool overrideRateLimit = false,
}) async {
  doTheThing() {
    /* final ts =  */ timeOfLastRequest = DateTime.timestamp();
    return client.send(
        request) /* ..then((v) => _responseStreamController.add((v, ts))).ignore() */;
  }

  var t = DateTime.timestamp().difference(timeOfLastRequest);
  if (t >= currentRateLimit || overrideRateLimit) {
    return doTheThing();
  } else {
    if (useBurst && burstTimes.length < currentBurstLimit) {
      final ts = DateTime.timestamp();
      burstTimes.add(ts);
      Future.delayed(currentRateLimit, () => burstTimes.remove(ts)).ignore();
      return client.send(
          request) /* ..then((v) => _responseStreamController.add((v, ts))).ignore() */;
    }
    return Future.delayed(currentRateLimit - t, doTheThing);
  }
}

/// Won't blow the rate limit
Future<http.Response> sendRequest(
  http.BaseRequest request, {
  bool useBurst = false,
  bool overrideRateLimit = false,
}) async =>
    sendRequestStreamed(request, useBurst: useBurst).then((v) async {
      var t =
          await http.ByteStream(v.stream.asBroadcastStream()).bytesToString();
      return http.Response(
        t,
        v.statusCode,
        headers: v.headers,
        isRedirect: v.isRedirect,
        persistentConnection: v.persistentConnection,
        reasonPhrase: v.reasonPhrase,
        request: v.request,
      );
    });
// #endregion Rate Limit

/// Attempts to clear the vote from the selected post.
///
/// {@macro postVote}
Future<http.Response> clearPostVote({
  required int postId,
  BaseCredentials? credentials,
}) =>
    sendRequest(
      initVotePostRequest(postId: postId, score: 1, credentials: credentials),
    ).then((r) => r.statusCode >= 200 && r.statusCode < 300 // Is successful
        ? dc.jsonDecode(r.body)["our_score"] == 0
            ? r as FutureOr<http.Response>
            : sendRequest(initVotePostRequest(
                postId: postId,
                score: 1,
                credentials: credentials,
              ))
        : r);
