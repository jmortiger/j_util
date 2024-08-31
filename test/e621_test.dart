import 'package:http/http.dart';
import 'package:j_util/web_full.dart';
import 'package:j_util/e621.dart';
import 'package:j_util/e621_api.dart' as Api;

import 'dev_data.dart';
import 'package:test/test.dart';
import 'package:test/test.dart' as test_lib;

void main() {
  logRequestData(Request req) {
    print(req);
    print(req.method);
    print(req.body);
    print(req.url);
    print(req.headers);
  }

  logResponseData(Response res) {
    print(res);
    print(res.body);
    print(res.statusCode);
    print(res.reasonPhrase);
    print(res.statusCodeInfo);
    if (res.statusCodeInfo.isRedirect) {
      print(
          "Location header: ${res.headers["location"] ?? res.headers["Location"]}");
    }
  }

  searchPostId(int postId, BaseCredentials? c) async =>
      (await Api.initSearchPostRequest(
        postId,
        credentials: c,
      ).send().toResponse());

  searchSetId(int setId, BaseCredentials? c) async =>
      (await Api.initGetSetRequest(
        setId,
        credentials: c,
      ).send().toResponse());

  group("Set", () {
    late E6Credentials c;
    late int postId, postId2, setId;
    setUp(() {
      c = E6Credentials.fromJson(devData["e621"]);
      postId = devData["e621"]["posts"][0]["id"];
      postId2 = devData["e621"]["posts"][1]["id"];
      setId = devData["e621"]["sets"][0]["id"];
    });
    removeSetPostSlim([Response? priorStartState]) async {
      var req = Api.initRemoveFromSetRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
    }

    addSetPostSlim([Response? priorStartState]) async {
      var req = Api.initAddToSetRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
    }

    test("AddSetPost", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(Api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (initialIds.contains(postId)) {
        await removeSetPostSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      print("BEGINNING");
      var req = Api.initAddToSetRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
    });
    test("RemoveSetPost", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(Api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (!initialIds.contains(postId)) {
        await addSetPostSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      var req = Api.initRemoveFromSetRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
    });
    addSetPostsSlim([Response? priorStartState]) async {
      var req = Api.initAddToSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
      expect(postId2, isIn(t.postIds));
    }

    removeSetPostsSlim([Response? priorStartState]) async {
      var req = Api.initRemoveFromSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
      expect(postId2, isNot(isIn(t.postIds)));
    }

    test("AddSetPosts", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(Api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (initialIds.contains(postId) || initialIds.contains(postId2)) {
        await removeSetPostsSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      print("BEGINNING");
      // addSetPostsSlim(priorStartState);
      var req = Api.initAddToSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
      expect(postId2, isIn(t.postIds));
    });
    test("RemoveSetPosts", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(Api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (!initialIds.contains(postId) || !initialIds.contains(postId2)) {
        await addSetPostsSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      print("BEGINNING");
      // removeSetPostsSlim(priorStartState);
      var req = Api.initRemoveFromSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
      expect(postId2, isNot(isIn(t.postIds)));
    });
    test("UpdateSetPosts", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(Api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (!initialIds.contains(postId) || !initialIds.contains(postId2)) {
        await addSetPostsSlim(startState);
        startState = await searchSetId(setId, c);
        print(startState.body);
      }
      print("BEGINNING");
      print("Testing removing 1 keeping 1");
      var req = Api.initUpdateSetPostsRequest(
        setId,
        [postId],
        credentials: c,
      );
      logRequestData(req);
      var res = await Api.sendRequest(req);
      logResponseData(res);
      expect(res.statusCode, test_lib.anyOf(201, 302));
      if (res.statusCode != 201) {
        req = Api.initGetSetRequest(
          setId,
          credentials: c,
        );
        logRequestData(req);
        res = await Api.sendRequest(req);
        logResponseData(res);
      }
      PostSet t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
      expect(postId2, isNot(isIn(t.postIds)));
      print("Testing switching kept post");
      req = Api.initUpdateSetPostsRequest(
        setId,
        [postId2],
        credentials: c,
      );
      logRequestData(req);
      res = await Api.sendRequest(req);
      logResponseData(res);
      expect(res.statusCode, test_lib.anyOf(201, 302));
      if (res.statusCode != 201) {
        req = Api.initGetSetRequest(
          setId,
          credentials: c,
        );
        logRequestData(req);
        res = await Api.sendRequest(req);
        logResponseData(res);
      }
      t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
      expect(postId2, isIn(t.postIds));
      print("Testing adding both");
      req = Api.initUpdateSetPostsRequest(
        setId,
        [postId, postId2],
        credentials: c,
      );
      logRequestData(req);
      res = await Api.sendRequest(req);
      logResponseData(res);
      expect(res.statusCode, test_lib.anyOf(201, 302));
      if (res.statusCode != 201) {
        req = Api.initGetSetRequest(
          setId,
          credentials: c,
        );
        logRequestData(req);
        res = await Api.sendRequest(req);
        logResponseData(res);
      }
      t = PostSet.fromRawJson(res.body);
      expect(postId, isIn(t.postIds));
      expect(postId2, isIn(t.postIds));
      print("Testing Removing both");
      req = Api.initUpdateSetPostsRequest(
        setId,
        [],
        credentials: c,
      );
      logRequestData(req);
      res = await Api.sendRequest(req);
      logResponseData(res);
      expect(res.statusCode, test_lib.anyOf(201, 302));
      if (res.statusCode != 201) {
        req = Api.initGetSetRequest(
          setId,
          credentials: c,
        );
        logRequestData(req);
        res = await Api.sendRequest(req);
        logResponseData(res);
      }
      t = PostSet.fromRawJson(res.body);
      expect(postId, isNot(isIn(t.postIds)));
      expect(postId2, isNot(isIn(t.postIds)));
    });
    tearDown(() {
      Api.initRemoveFromSetRequest(
        setId,
        [postId, postId2],
        credentials: c,
      ).send();
    });
  });
  group("Favorite", () {
    late E6Credentials c;
    late int postId;
    setUp(() {
      c = E6Credentials.fromJson(devData["e621"]);
      postId = devData["e621"]["posts"][2]["id"];
    });
    late final Future<void> Function([Response? priorStartState]) removeFav;
    addFav([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchPostId(postId, c));
      print(startState.body);
      await Future.delayed(Api.softRateLimit);
      if (Post.fromRawJson(startState.body).isFavorited) {
        await removeFav();
      }
      var req = Api.initCreateFavoriteRequest(
        postId: postId,
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 201);
      Post t = Post.fromRawJson(res.body);
      expect(postId, t.id);
      expect(t.isFavorited, true);
    }

    removeFav = ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchPostId(postId, c));
      print(startState.body);
      await Future.delayed(Api.softRateLimit);
      if (!Post.fromRawJson(startState.body).isFavorited) {
        await addFav(startState);
      }
      var req = Api.initDeleteFavoriteRequest(
        postId: postId,
        credentials: c,
      );
      logRequestData(req);
      var res = await req.send().toResponse();
      logResponseData(res);
      expect(res.statusCode, 204);
      expect(res.body, "");
      await Future.delayed(Api.softRateLimit);
      var p = await Api.initSearchPostRequest(postId, credentials: c)
          .send()
          .toResponse();
      Post t = Post.fromRawJson(p.body);
      expect(postId, t.id);
      expect(t.isFavorited, false);
    };

    test("AddFav", addFav);
    test("RemoveFav", removeFav);
  });
}
