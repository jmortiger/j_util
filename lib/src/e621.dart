import 'dart:convert' as dc;
import 'package:http/http.dart' as http;

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
      E6Credentials._direct(
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

class Api {
  static final baseUri = Uri.https(authority);
  static const baseUrl = origin;
  static const origin = "$scheme://$authority";
  static const protocol = "$scheme:";
  static const scheme = "https";
  static const authority = "$hostName$port";
  static const host = authority;
  static const hostName = "e621.net";
  static const port = "";

  /// The rate limit in seconds per request.
  static const rateLimit = 1;

  /// The hard rate limit in seconds per request.
  static const hardRateLimit = 1;

  /// The soft rate limit in seconds per request.
  static const softRateLimit = 2;

  /// The ideal rate limit in seconds per request.
  static const idealRateLimit = 3;
  static const maxPostsPerSearch = 320;

  /// Use this to automatically enforce rate limit.
  static final http.Client client = http.Client();

  // #region Notes
  /// [Listing](https://e621.net/wiki_pages/2425#notes_listing)
  ///
  /// The base URL is `/notes.json` called with `GET`.
  ///
  /// * `search[body_matches]` The note's body matches the given terms. Use a * in the search terms to search for raw strings.
  /// * `search[post_id]`
  /// * `search[post_tags_match]` The note's post's tags match the given terms. Meta-tags are not supported.
  /// * `search[creator_name]` The creator's name. Exact match.
  /// * `search[creator_id]` The creator's user id.
  /// * `search[is_active]` Can be: true, false
  /// * `limit` Limits the amount of notes returned to the number specified.
  ///
  /// This returns a JSON array, for each note it returns:
  /// {@template noteListing}
  /// * `id` The Note’s ID
  /// * `created_at` The time the note was created in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  /// * `updated_at` The time the mote was last updated in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  /// * `creator_id` The ID of the user that created the note.
  /// * `x` The X coordinate of the top left corner of the note in pixels from the top left of the post.
  /// * `y` The Y coordinate of the top left corner of the note in pixels from the top left of the post.
  /// * `width` The width of the box for the note.
  /// * `height` The height of the box for the note.
  /// * `version` How many times the note has been edited.
  /// * `is_active` If the note is currently active. (True/False)
  /// * `post_id` The ID of the post that the note is on.
  /// * `body` The contents of the note.
  /// * `creator_name` The name of the user that created the note.
  /// {@endtemplate}
  ///
  /// If no results are returned:
  /// ```{"notes":[]}```
  http.Request initSearchNotes({
    String? searchBodyMatches,
    String? searchPostId,
    String? searchPostTagsMatch,
    String? searchCreatorName,
    String? searchCreatorId,
    String? searchIsActive,
    int? limit,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: "/notes.json", queryParameters: {
      if (searchBodyMatches != null) "search[body_matches]": searchBodyMatches,
      if (searchPostId != null) "search[post_id]": searchPostId,
      if (searchPostTagsMatch != null)
        "search[post_tags_match]": searchPostTagsMatch,
      if (searchCreatorName != null) "search[creator_name]": searchCreatorName,
      if (searchCreatorId != null) "search[creator_id]": searchCreatorId,
      if (searchIsActive != null) "search[is_active]": searchIsActive,
      if (limit != null) "limit": limit,
    });
    var req = http.Request("GET", uri);
    if (credentials != null) {
      credentials.addToHeadersMap(req.headers);
    }
    return req;
  }

  /// [Create](https://e621.net/wiki_pages/2425#notes_create)
  ///
  /// The base URL is `/notes.json` called with `POST`.
  ///
  /// * note[post_id] The ID of the post you want to add a note to.
  /// * note[x] The X coordinate of the top left corner of the note in pixels from the top left of the post.
  /// * note[y] The Y coordinate of the top left corner of the note in pixels from the top left of the post.
  /// * note[width] The width of the box for the note.
  /// * note[height] The height of the box for the note.
  /// * note[body] The contents of the note.
  ///
  /// All fields are required.
  ///
  /// If successful it will return the added note in the format:
  /// {@macro noteListing}
  http.Request initCreateNote({
    required int notePostId,
    required int noteX,
    required int noteY,
    required int noteWidth,
    required int noteHeight,
    required String noteBody,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: "/notes.json", queryParameters: {
      "note[post_id]": notePostId,
      "note[x]": noteX,
      "note[y]": noteY,
      "note[width]": noteWidth,
      "note[height]": noteHeight,
      "note[body]": noteBody,
    });
    var req = http.Request("POST", uri);
    if (credentials != null) {
      credentials.addToHeadersMap(req.headers);
    }
    return req;
  }

  /// [Delete](https://e621.net/wiki_pages/2425#notes_delete)
  ///
  /// The base URL is ``/notes/[noteId].json`` called with `DELETE`.
  ///
  /// There is no response.
  http.Request initDeleteNote(
    int noteId, {
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: "/notes/$noteId.json");
    var req = http.Request("DELETE", uri);
    if (credentials != null) {
      credentials.addToHeadersMap(req.headers);
    }
    return req;
  }

  /// [Revert](https://e621.net/wiki_pages/2425#notes_revert)
  ///
  /// The base URL is ``/notes/[noteId]/revert.json`` called with PUT.
  ///
  /// * `version_id` The note version id to revert to.
  http.Request initRevertNote(
    int noteId, {
    required int versionId,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(
        path: "/notes/$noteId.json",
        queryParameters: {"version_id": versionId});
    var req = http.Request("PUT", uri);
    if (credentials != null) {
      credentials.addToHeadersMap(req.headers);
    }
    return req;
  }
  // #endregion Notes

  // #region Pools
  /// https://e621.net/wiki_pages/2425#pools_listing
  ///
  /// The base URL is `/pools.json` called with `GET`.
  ///
  /// * `search[name_matches]` Search pool names.
  /// * `search[id]` Search for a pool ID, you can search for multiple IDs at once, separated by commas.
  /// * `search[description_matches]` Search pool descriptions.
  /// * `search[creator_name]` Search for pools based on creator name.
  /// * `search[creator_id]` Search for pools based on creator ID.
  /// * `search[is_active]` If the pool is active or hidden. (True/False)
  /// * `search[category]` Can either be “series” or “collection”.
  /// * `search[order]` The order that pools should be returned, can be any of: name, created_at, updated_at, post_count. If not specified it orders by updated_at
  /// * `limit` The limit of how many pools should be retrieved.
  /// This returns a JSON array, for each pool it returns:
  /// {@template poolListing}
  /// * `id` The ID of the pool.
  /// * `name` The name of the pool.
  /// * `created_at` The time the pool was created in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  /// * `updated_at` The time the pool was updated in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  /// * `creator_id` the ID of the user that created the pool.
  /// * `description` The description of the pool.
  /// * `is_active` If the pool is active and still getting posts added. (True/False)
  /// * `category` Can be “series” or “collection”.
  /// * `post_ids` An array group of posts in the pool.
  /// * `creator_name` The name of the user that created the pool.
  /// * `post_count` the amount of posts in the pool.
  /// {@endtemplate}
  http.Request initSearchPoolsRequest({
    String? searchNameMatches,
    String? searchId,
    String? searchDescriptionMatches,
    String? searchCreatorName,
    String? searchCreatorId,
    String? searchIsActive,
    String? searchCategory,
    String? searchOrder,
    int? limit,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: "/pools.json", queryParameters: {
      if (searchNameMatches != null) "search[name_matches]": searchNameMatches,
      if (searchId != null) "search[id]": searchId,
      if (searchDescriptionMatches != null)
        "search[description_matches]": searchDescriptionMatches,
      if (searchCreatorName != null) "search[creator_name]": searchCreatorName,
      if (searchCreatorId != null) "search[creator_id]": searchCreatorId,
      if (searchIsActive != null) "search[is_active]": searchIsActive,
      if (searchCategory != null) "search[category]": searchCategory,
      if (searchOrder != null) "search[order]": searchOrder,
      if (limit != null) "limit": limit,
    });
    var req = http.Request("GET", uri);
    if (credentials != null) {
      req.headers["Authorization"] = credentials.headerValue;
    }
    return req;
  }

  /// https://e621.net/wiki_pages/2425#pools_update
  ///
  /// The base URL is /pools/[poolId].json called with PUT.
  ///
  /// Only post parameters you want to update.
  ///
  /// * `pool[name]` The name of the pool.
  /// * `pool[description]` The description of the pool.
  /// * `pool[post_ids]` List of space delimited post ids in order of where they should be in the pool.
  /// * `pool[is_active]` Can be either 1 or 0
  /// * `pool[category]` Can be either “series” or “collection”.
  ///
  /// Success will return the pool in the format:
  /// {@macro poolListing}
  http.Request initUpdatePoolRequest(
    int poolId, {
    String? poolName,
    String? poolDescription,
    Iterable<int>? poolPostIds,
    int? poolIsActive,
    PoolCategory? poolCategory,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: "/pools/$poolId.json", queryParameters: {
      if (poolName != null) "pool[name]": poolName,
      if (poolDescription != null) "pool[description]": poolDescription,
      if (poolPostIds != null)
        "pool[post_ids]": poolPostIds.fold("",
            (accumulator, elem) => "$accumulator $elem"),
      if (poolIsActive != null) "pool[is_active]": poolIsActive,
      if (poolCategory != null) "pool[category]": poolCategory.toJsonString(),
    });
    var req = http.Request("PUT", uri);
    if (credentials != null) {
      req.headers["Authorization"] = credentials.headerValue;
    }
    return req;
  }

  /// https://e621.net/wiki_pages/2425#pools_create
  ///
  /// The base URL is `/pools.json` called with `POST`.
  ///
  /// The pool’s name and description are required, though the description can be empty.
  ///
  /// * `pool[name]` The name of the pool.
  /// * `pool[description]` The description of the pool.
  /// * `pool[category]` Can be either `series` or `collection`.
  /// * `pool[is_locked]` 1 or 0, whether or not the pool is locked. Admin only function.
  ///
  /// Success will return the pool in the format:
  /// {@macro poolListing}
  http.Request initCreatePoolRequest({
    String? poolName,
    String? poolDescription,
    PoolCategory? poolCategory,
    int? poolIsLocked,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: "/pools.json", queryParameters: {
      if (poolName != null) "pool[name]": poolName,
      if (poolDescription != null) "pool[description]": poolDescription,
      if (poolCategory != null) "pool[category]": poolCategory.toJsonString(),
      if (poolIsLocked != null) "pool[is_locked]": poolIsLocked,
    });
    var req = http.Request("POST", uri);
    if (credentials != null) {
      req.headers["Authorization"] = credentials.headerValue;
    }
    return req;
  }

  /// https://e621.net/wiki_pages/2425#pools_revert
  ///
  /// The base URL is `/pools/<Pool_ID>/revert.json` called with `PUT`.
  ///
  /// * `version_id` The version ID to revert to.
  http.Request initRevertPoolRequest(
    int poolId, {
    int? versionId,
    BaseCredentials? credentials,
  }) {
    var uri =
        baseUri.replace(path: "/pools/$poolId/revert.json", queryParameters: {
      if (versionId != null) "version_id": versionId,
    });
    var req = http.Request("PUT", uri);
    if (credentials != null) {
      req.headers["Authorization"] = credentials.headerValue;
    }
    return req;
  }
  // #endregion Pools
}

class ResponseParsing {
  /// When an attempt to add a fav fails due to hitting the 80000 post cap, the code is 422 and the body is as follows:
  /// ```{
  ///   "success": false,
  ///   "message": "You can only keep up to 80000 favorites.",
  ///   "code": null
  /// }```
  /*{
  "success": false,
  "message": "You can only keep up to 80000 favorites.",
  "code": null
}*/
  static String retrieveErrorMessage(String body) {
    return dc.jsonDecode(body)["message"];
  }
}

class Pool {
  /// The ID of the pool.
  final int id;

  /// The name of the pool.
  final String name;

  /// The time the pool was created in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  final DateTime createdAt;

  /// The time the pool was updated in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  final DateTime updatedAt;

  /// The ID of the user that created the pool.
  final int creatorId;

  /// The description of the pool.
  final String description;

  /// If the pool is active and still getting posts added. (True/False)
  final bool isActive;

  /// Can be “series” or “collection”.
  final PoolCategory category;

  /// An array group of posts in the pool.
  final List<int> postIds;

  /// The name of the user that created the pool.
  final String creatorName;

  /// The amount of posts in the pool.
  final int postCount;

  Pool({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorId,
    required this.description,
    required this.isActive,
    required this.category,
    required this.postIds,
    required this.creatorName,
    required this.postCount,
  });
  Pool copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? creatorId,
    String? description,
    bool? isActive,
    PoolCategory? category,
    List<int>? postIds,
    String? creatorName,
    int? postCount,
  }) =>
      Pool(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        creatorId: creatorId ?? this.creatorId,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        category: category ?? this.category,
        postIds: postIds ?? this.postIds,
        creatorName: creatorName ?? this.creatorName,
        postCount: postCount ?? this.postCount,
      );

  // factory Pool.fromRawJson(String str) => Pool.fromJson(json.decode(str));
  factory Pool.fromRawJson(String str) => str.decodeRawJson();

  // String toRawJson() => json.encode(toJson());

  factory Pool.fromJson(Map<String, dynamic> json) => Pool(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        creatorId: json["creator_id"],
        description: json["description"],
        isActive: json["is_active"],
        // category: PoolCategory.map[json["category"]]!,
        category: PoolCategory.fromJson(json["category"]),
        postIds: List<int>.from(json["post_ids"].map((x) => x)),
        creatorName: json["creator_name"],
        postCount: json["post_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "creator_id": creatorId,
        "description": description,
        "is_active": isActive,
        // "category": PoolCategory.reverseMap[category],
        "category": category.toJson(),
        "post_ids": List<dynamic>.from(postIds.map((x) => x)),
        "creator_name": creatorName,
        "post_count": postCount,
      };
}

enum PoolCategory {
  collection,
  series;

  dynamic toJson() => name;
  static PoolCategory fromJson(dynamic json) => fromJsonString(json);

  String toJsonString() => name;
  static PoolCategory fromJsonString(String name) => switch (name) {
        "collection" => collection,
        "series" => series,
        _ => throw UnsupportedError(
            "Value $name not supported, must be `collection` or `series`.",
          ),
      };
  static PoolCategory fromJsonStringNonStrict(String name) =>
      switch (name.toLowerCase()) {
        "collection" => collection,
        "series" => series,
        _ => throw UnsupportedError(
            "Value $name not supported, must be `collection` or `series`.",
          ),
      };
  String toParamString() => name;
  static PoolCategory fromParamString(String name) => switch (name) {
        "collection" => collection,
        "series" => series,
        _ => throw UnsupportedError(
            "Value $name not supported, must be `collection` or `series`.",
          ),
      };
}
// mixin JsonFriendlyEnum<T extends Enum> on Enum {
//   dynamic toJson() => name;
//   static T fromJson(dynamic json) => fromJsonString(json);

//   String toJsonString() => name;
//   static T fromJsonString(String name) => switch (name) {
//         "collection" => collection,
//         "series" => series,
//         _ => throw UnsupportedError(
//             "Value $name not supported, must be `collection` or `series`.",
//           ),
//       };
//   static T fromJsonStringNonStrict(String name) =>
//       switch (name.toLowerCase()) {
//         "collection" => collection,
//         "series" => series,
//         _ => throw UnsupportedError(
//             "Value $name not supported, must be `collection` or `series`.",
//           ),
//       };
//   String toParamString() => name;
//   static T fromParamString(String name) => switch (name) {
//         "collection" => collection,
//         "series" => series,
//         _ => throw UnsupportedError(
//             "Value $name not supported, must be `collection` or `series`.",
//           ),
//       };

//   // static const Map<String, T> map = {
//   //   "collection": collection,
//   //   "series": series,
//   // };
//   // static const Map<T, String> reverseMap = {
//   //   collection: "collection",
//   //   series: "series",
//   // };
// }
class Note {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int creatorId;
  final int x;
  final int y;
  final int width;
  final int height;
  final int version;
  final bool isActive;
  final int postId;
  final String body;
  final String creatorName;

  Note({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.version,
    required this.isActive,
    required this.postId,
    required this.body,
    required this.creatorName,
  });

  Note copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? creatorId,
    int? x,
    int? y,
    int? width,
    int? height,
    int? version,
    bool? isActive,
    int? postId,
    String? body,
    String? creatorName,
  }) =>
      Note(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        creatorId: creatorId ?? this.creatorId,
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
        postId: postId ?? this.postId,
        body: body ?? this.body,
        creatorName: creatorName ?? this.creatorName,
      );

  // factory Note.fromRawJson(String str) => Note.fromJson(json.decode(str));
  factory Note.fromRawJson(String str) => str.decodeRawJson();

  // String toRawJson() => json.encode(toJson());

  /// Safely handles the special value when a search yields no results.
  static Note? fromJsonSafe(Map<String, dynamic> json) =>
      json["notes"]?.runtimeType == List ? null : Note.fromJson(json);

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        creatorId: json["creator_id"],
        x: json["x"],
        y: json["y"],
        width: json["width"],
        height: json["height"],
        version: json["version"],
        isActive: json["is_active"],
        postId: json["post_id"],
        body: json["body"],
        creatorName: json["creator_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "creator_id": creatorId,
        "x": x,
        "y": y,
        "width": width,
        "height": height,
        "version": version,
        "is_active": isActive,
        "post_id": postId,
        "body": body,
        "creator_name": creatorName,
      };
}
extension JsonHandling on String {
  
  /// Will throw an error if T doesn't have a `fromJson` named constructor.
  T decodeRawJson<T>() => (T as dynamic).fromJson(dc.json.decode(this));
}