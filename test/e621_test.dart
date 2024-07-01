import 'package:http/http.dart';
import 'package:j_util/web.dart';
import 'package:j_util/e621.dart';

import 'dev_data.dart';
import 'package:test/test.dart';

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
    addSetPost([Response? priorStartState]) async {
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

    test("AddSetPost", addSetPost);
    test("RemoveSetPost", ([Response? priorStartState]) async {
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
    addSetPosts([Response? priorStartState]) async {
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
    test("AddSetPosts", addSetPosts);
    test("RemoveSetPosts", ([Response? priorStartState]) async {
      var startState = priorStartState ?? (await searchSetId(setId, c));
      print(startState.body);
      await Future.delayed(Api.softRateLimit);
      var initialIds = PostSet.fromRawJson(startState.body).postIds;
      if (!initialIds.contains(postId) || !initialIds.contains(postId2)) {
        await addSetPosts(startState);
      }
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
