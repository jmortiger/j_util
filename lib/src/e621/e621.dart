import 'dart:convert' as dc;
import 'package:http/http.dart' as http;
import 'package:j_util/e621.dart';
import 'package:j_util/src/types.dart';
 
import 'models.dart';

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
  // #region URI
  static final baseUri = Uri.https(authority);
  static const baseUrl = origin;
  static const origin = "$scheme://$authority";
  static const protocol = "$scheme:";
  static const scheme = "https";
  static const authority = "$hostName$port";
  static const host = authority;
  static const hostName = "e621.net";
  static const port = "";
  // #endregion URI

  // #region Rate Limit
  /// The rate limit in seconds per request.
  static const rateLimit = 1;

  /// The hard rate limit in seconds per request.
  static const hardRateLimit = 1;

  /// The soft rate limit in seconds per request.
  static const softRateLimit = 2;

  /// The ideal rate limit in seconds per request.
  static const idealRateLimit = 3;
  // #endregion Rate Limit
  static const maxPostsPerSearch = 320;

  /// Use this to automatically enforce rate limit.
  static final http.Client client = http.Client();

  // #region Credentials
  static BaseCredentials? activeCredentials;

  static bool _validateCredentials(BaseCredentials? credentials,
          [bool throwIfNeeded = true]) =>
      ((credentials ?? Api.activeCredentials) == null)
          ? throwIfNeeded
              ? throw ArgumentError.value(
                  credentials,
                  "credentials",
                  "Either the static credentials or the argument credentials must be defined.",
                )
              : false
          : true;

  static BaseCredentials _getValidCredentials(BaseCredentials? credentials) =>
      credentials ??
      activeCredentials ??
      (throw ArgumentError.value(
        credentials,
        "credentials",
        "Either the static credentials or the argument credentials must be defined.",
      ));
  // #endregion Credentials
  // #region Helpers
  static http.Request _baseInitRequestCredentialsRequired({
    required String path,
    required String method,
    Map<String, dynamic>? queryParameters,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: path, queryParameters: queryParameters);
    var req = http.Request(method, uri);
    _getValidCredentials(credentials).addToHeadersMap(req.headers);
    return req;
  }

  static http.Request _baseInitRequestCredentialsOptional({
    required String path,
    required String method,
    Map<String, dynamic>? queryParameters,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: path, queryParameters: queryParameters);
    var req = http.Request(method, uri);
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
    return req;
  }

  /// [upperBound] is inclusive
  static int _validateLimit(
    int limit, {
    int lowerBound = 0,
    int upperBound = 320,
    int defaultValue = 75,
  }) =>
      (limit > lowerBound && limit <= upperBound) ? limit : defaultValue;

  // #endregion Helpers
  // #region Posts
  /* /// TODO: Requires multipart form 
  /// https://pub.dev/documentation/http/latest/http/MultipartRequest-class.html#:~:text=A%20multipart%2Fform%2Ddata%20request,value%20set%20by%20the%20user
  /// https://stackoverflow.com/questions/71424265/how-to-send-multipart-file-with-flutter
  /// (Create)[https://e621.net/wiki_pages/2425#posts_create]
  /// The base URL is /uploads.json called with POST.
  /// There are only four mandatory fields: you need to supply the file (either through a multipart form or through a source URL), the tags, a source (even if blank), and the rating.
  /// 
  /// * `upload[tag_string]` A space delimited list of tags.
  /// * `upload[file]` The file data encoded as a multipart form.
  /// * `upload[rating]` The rating for the post. Can be: s, q or e for safe, questionable, and explicit respectively.
  /// * `upload[direct_url]` If this is a URL, e621 will download the file.
  /// * `upload[source]` This will be used as the post's 'Source' text. Separate multiple URLs with %0A (url-encoded newline) to define multiple sources. Limit of ten URLs
  /// * `upload[description]` The description for the post.
  /// * `upload[parent_id]` The ID of the parent post.
  /// * `upload[as_pending]`
  /// If the call fails, the following response reasons are possible:
  /// 
  /// * `MD5` mismatch This means you supplied an MD5 parameter and what e621 got doesn't match. Try uploading the file again.
  /// * `duplicate` This post already exists in e621 (based on the MD5 hash). An additional attribute called location will be set, pointing to the (relative) URL of the original post.
  /// * `other` Any other error will have its error message printed.
  /// Response:
  /// Success:
  /// HTTP 200 OK
  /// 
  /// {
  ///     "success":true",
  ///     ”location":"/posts/<Post_ID>",
  ///     "post_id":<Post_ID>
  /// }
  /// Failed due to the post already existing:
  /// HTTP 412
  /// 
  /// {
  ///     "success":false,
  ///     "reason":"duplicate",
  ///     "location":"/posts/<Post_ID>",
  ///     "post_id":<Post_ID>
  /// }
  static http.Request initCreatePostRequest({
    String? uploadTagString,
    String? uploadFile,
    String? uploadRating,
    String? uploadDirectUrl,
    String? uploadSource,
    String? uploadDescription,
    String? uploadParentId,
    String? uploadAsPending,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsRequired(
          path: "/uploads.json",
          queryParameters: {
            if (uploadTagString != null) "upload[tag_string]": uploadTagString,
            if (uploadFile != null) "upload[file]": uploadFile,
            if (uploadRating != null) "upload[rating]": uploadRating,
            if (uploadDirectUrl != null) "upload[direct_url]": uploadDirectUrl,
            if (uploadSource != null) "upload[source]": uploadSource,
            if (uploadDescription != null) "upload[description]": uploadDescription,
            if (uploadParentId != null) "upload[parent_id]": uploadParentId,
            if (uploadAsPending != null) "upload[as_pending]": uploadAsPending,
          },
          method: "POST",
          credentials: credentials); */
  /// [List](https://e621.net/wiki_pages/2425#posts_list)
  ///
  /// The base URL is /posts.json called with GET.
  /// Deleted posts are returned when status:deleted/status:any is in the searched tags.
  ///
  /// The most efficient method to iterate a large number of posts is to search use the page parameter, using page=b<ID> and using the lowest ID retrieved from the previous list of posts. The first request should be made without the page parameter, as this returns the latest posts first, so you can then iterate using the lowest ID. Providing arbitrarily large values to obtain the most recent posts is not portable and may break in the future.
  ///
  /// Note: Using page=<number> without a or b before the number just searches through pages. Posts will shift between pages if posts are deleted or created to the site between requests and page numbers greater than 750 will return an error.
  ///
  /// * limit How many posts you want to retrieve. There is a hard limit of 320 posts per request. Defaults to the value set in user preferences.
  /// * tags The tag search query. Any tag combination that works on the website will work here.
  /// * page The page that will be returned. Can also be used with a or b + post_id to get the posts after or before the specified post ID. For example a13 gets every post after post_id 13 up to the limit. This overrides any ordering meta-tag, order:id_desc is always used instead.
  /// {@template PostListing}
  /// This returns a JSON array, for each post it returns:
  ///
  /// * id The ID number of the post.
  /// * created_at The time the post was created in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  /// * updated_at The time the post was last updated in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  /// * file (array group)
  /// * width The width of the post.
  /// * height The height of the post.
  /// * ext The file’s extension.
  /// * size The size of the file in bytes.
  /// * md5 The md5 of the file.
  /// * url The URL where the file is hosted on E6
  /// * preview (array group)
  /// * width The width of the post preview.
  /// * height The height of the post preview.
  /// * url The URL where the preview file is hosted on E6
  /// * sample (array group)
  /// * has If the post has a sample/thumbnail or not. (True/False)
  /// * width The width of the post sample.
  /// * height The height of the post sample.
  /// * url The URL where the sample file is hosted on E6.
  /// * score (array group)
  /// * up The number of times voted up.
  /// * down A negative number representing the number of times voted down.
  /// * total The total score (up + down).
  /// * tags (array group)
  /// * general A JSON array of all the general tags on the post.
  /// * species A JSON array of all the species tags on the post.
  /// * character A JSON array of all the character tags on the post.
  /// * artist A JSON array of all the artist tags on the post.
  /// * invalid A JSON array of all the invalid tags on the post.
  /// * lore A JSON array of all the lore tags on the post.
  /// * meta A JSON array of all the meta tags on the post.
  /// * locked_tags A JSON array of tags that are locked on the post.
  /// * change_seq An ID that increases for every post alteration on E6 (explained below)
  /// * flags (array group)
  /// * pending If the post is pending approval. (True/False)
  /// * flagged If the post is flagged for deletion. (True/False)
  /// * note_locked If the post has it’s notes locked. (True/False)
  /// * status_locked If the post’s status has been locked. (True/False)
  /// * rating_locked If the post’s rating has been locked. (True/False)
  /// * deleted If the post has been deleted. (True/False)
  /// * rating The post’s rating. Either s, q or e.
  /// * fav_count How many people have favorited the post.
  /// * sources The source field of the post.
  /// * pools An array of Pool IDs that the post is a part of.
  /// * relationships (array group)
  /// * parent_id The ID of the post’s parent, if it has one.
  /// * has_children If the post has child posts (True/False)
  /// * has_active_children
  /// * children A list of child post IDs that are linked to the post, if it has any.
  /// * approver_id The ID of the user that approved the post, if available.
  /// * uploader_id The ID of the user that uploaded the post.
  /// * description The post’s description.
  /// * comment_count The count of comments on the post.
  /// * is_favorited If provided auth credentials, will return if the authenticated user has favorited the post or not.
  /// * change_seq is a number that is increased every time a post is changed on the site. It gets updated whenever a post has any of these values change:
  ///     * tag_string
  ///     * source
  ///     * description
  ///     * rating
  ///     * md5
  ///     * parent_id
  ///     * approver_id
  ///     * is_deleted
  ///     * is_pending
  ///     * is_flagged
  ///     * is_rating_locked
  ///     * is_pending
  ///     * is_flagged
  ///     * is_rating_locked
  /// {@endtemplate}
  static http.Request initSearchPostsRequest({
    int? limit,
    String? tags,
    String? page,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
          path: "/posts.json",
          queryParameters: {
            if (limit != null) "limit": limit,
            if (tags != null) "tags": tags,
            if (page != null) "page": page,
          },
          method: "GET",
          credentials: credentials);

  /// [Update](https://e621.net/wiki_pages/2425#posts_update)
  ///
  /// The base URL is `/posts/<Post_ID>.json` called with `PATCH`.
  /// Leave parameters blank if you don't want to change them.
  ///
  /// * `post[tag_string_diff]` A space delimited list of tag changes such as dog -cat. This is a much preferred method over the old version.
  /// (The old method of updating a post’s tags still works, with `post[old_tag_string]` and `post[tag_string]`, but `post[tag_string_diff]` is preferred.)
  ///
  /// * `post[source_diff]` A (URL encoded) newline delimited list of source changes. This works the same as `post[tag_string_diff]` but with sources.
  /// (The old method of updating a post’s sources still works, with `post[old_source]` and `post[source]`, but `post[source_diff]` is preferred.)
  ///
  /// * `post[parent_id]` The ID of the parent post.
  /// * `post[old_parent_id]` The ID of the previously parented post.
  /// * `post[description]` This will be used as the post's 'Description' text.
  /// * `post[old_description]` Should include the same descriptions submitted to `post[description]` minus any intended changes.
  /// * `post[rating]` The rating for the post. Can be: s, q or e for safe, questionable, and explicit respectively.
  /// * `post[old_rating]` The previous post’s rating.
  /// * `post[is_rating_locked]` Set to true to prevent others from changing the rating.
  /// * `post[is_note_locked]` Set to true to prevent others from adding notes.
  /// * `post[edit_reason]` The reason for the submitted changes. Inline DText allowed.
  static http.Request initUpdatePostRequest({
    required int postId,
    String? postTagStringDiff,
    String? postSourceDiff,
    String? postParentId,
    String? postOldParentId,
    String? postDescription,
    String? postOldDescription,
    String? postRating,
    String? postOldRating,
    String? postIsRatingLocked,
    String? postIsNoteLocked,
    String? postEditReason,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsRequired(
          path: "/posts/$postId.json",
          queryParameters: {
            if (postTagStringDiff != null)
              "post[tag_string_diff]": postTagStringDiff,
            if (postSourceDiff != null) "post[source_diff]": postSourceDiff,
            if (postParentId != null) "post[parent_id]": postParentId,
            if (postOldParentId != null) "post[old_parent_id]": postOldParentId,
            if (postDescription != null) "post[description]": postDescription,
            if (postOldDescription != null)
              "post[old_description]": postOldDescription,
            if (postRating != null) "post[rating]": postRating,
            if (postOldRating != null) "post[old_rating]": postOldRating,
            if (postIsRatingLocked != null)
              "post[is_rating_locked]": postIsRatingLocked,
            if (postIsNoteLocked != null)
              "post[is_note_locked]": postIsNoteLocked,
            if (postEditReason != null) "post[edit_reason]": postEditReason,
          },
          method: "PATCH",
          credentials: credentials);

  /// [Vote](https://e621.net/wiki_pages/2425#posts_vote)
  ///
  /// The base URL is `/posts/<Post_ID>/votes.json` called with `POST`.
  ///
  /// * `score` Set to 1 to vote up and -1 to vote down. Repeat the request to remove the vote.
  /// * `no_unvote` Set to true to have this score replace the old score. Repeat votes will not remove the vote.
  /// Response:
  /// Success:
  /// HTTP 200
  ///
  /// {
  ///    "score":<total>,
  ///    "up":<up>,
  ///    "down":<down>,
  ///    "our_score":x
  /// }
  /// Where our_score is 1, 0, -1 depending on the action.
  /// Failure:
  /// HTTP 422
  ///
  /// {
  ///     "success": false,
  ///     "message": "An unexpected error occurred.",
  ///     "code": null
  /// }
  static http.Request initVotePostRequest({
    required int postId,
    required int score,
    bool? noUnvote,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsRequired(
          path: "/posts/$postId/votes.json",
          queryParameters: {
            // "score": score,
            "score": switch (score) {
              < 0 => -1,
              > 0 => 1,
              // == 0 => 1,
              _ => throw ArgumentError.value(
                  score, "score", "Must be +/- 1; cannot be 0"),
            },
            if (noUnvote != null) "no_unvote": noUnvote,
          },
          method: "POST",
          credentials: credentials);
  // #endregion Posts
  // #region Tags
  /// (Listing)[https://e621.net/wiki_pages/2425#tags_listing]
  /// The base URL is `/tags.json` called with `GET`.
  ///
  /// * `search[name_matches]` A tag name expression to match against, which can include * as a wildcard.
  /// * `search[category]` Filters results to a particular category. Default value is blank (show all tags). See below for allowed values.
  /// * `search[order]` Changes the sort order. Pass one of date (default), count, or name.
  /// * `search[hide_empty]` Hide tags with zero visible posts. Pass true (default) or false.
  /// * `search[has_wiki]` Show only tags with, or without, a wiki page. Pass true, false, or blank (default).
  /// * `search[has_artist]` Show only tags with, or without an artist page. Pass true, false, or blank (default).
  /// * `limit` Maximum number of results to return per query. Default is 75. There is a hard upper limit of 320.
  /// * `page` The page that will be returned. Can also be used with a or b + tag_id to get the tags after or before the specified tag ID. For example a13 gets every tag after tag_id 13 up to the limit. This overrides the specified search ordering, date is always used instead.
  /// <details>
  /// <summary>Categories:</summary>
  /// The following values can be specified.
  /// * 0 general
  /// * 1 artist
  /// * 3 copyright
  /// * 4 character
  /// * 5 species
  /// * 6 invalid
  /// * 7 meta
  /// * 8 lore
  /// See here for a description of what different types of tags are and do.
  /// </details>
  /// Response:
  /// Success:
  /// HTTP 200
  ///
  /// ```
  /// [{
  ///    "id":<numeric tag id>,
  ///    "name":<tag display name>,
  ///    "post_count":<# matching visible posts>,
  ///    "related_tags":<space-delimited list of tags>,
  ///    "related_tags_updated_at":<ISO8601 timestamp>,
  ///    "category":<numeric category id>,
  ///    "is_locked":<boolean>,
  ///    "created_at":<ISO8601 timestamp>,
  ///    "updated_at":<ISO8601 timestamp>
  /// },
  /// ...
  /// ]
  /// ```
  /// If your query succeeds but produces no results, you will receive instead the following special value:
  /// `{ "tags":[] }`
  static http.Request initSearchTagsRequest({
    String? searchNameMatches,
    int? searchCategory,
    String? searchOrder,
    bool? searchHideEmpty,
    bool? searchHasWiki,
    bool? searchHasArtist,
    int? limit = 75,
    String? page,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
          path: "/tags.json",
          queryParameters: {
            if (searchNameMatches != null)
              "search[name_matches]": searchNameMatches,
            if (searchCategory != null) "search[category]": searchCategory,
            if (searchOrder != null) "search[order]": searchOrder,
            if (searchHideEmpty != null) "search[hide_empty]": searchHideEmpty,
            if (searchHasWiki != null) "search[has_wiki]": searchHasWiki,
            if (searchHasArtist != null) "search[has_artist]": searchHasArtist,
            if (limit != null) "limit": _validateLimit(limit),
            if (page != null) "page": page,
          },
          method: "GET",
          credentials: credentials);

  /// (Listing)[https://e621.net/wiki_pages/2425#tag_alias_listing]
  /// The base URL is `/tag_aliases.json` called with `GET`.
  ///
  /// * `search[name_matches]` A tag name expression to match against, which can include * as a wildcard. Both the aliased-to and the aliased-by tag are matched.
  /// * `search[antecedent_name]` Supports multiple tag names, comma-separated.
  /// * `search[consequent_name]` Supports multiple tag names, comma-separated.
  /// * `search[antecedent_tag_category]` Pass a valid tag category. Supports multiple values, comma-separated.
  /// * `search[consequent_tag_category]` Pass a valid tag category. Supports multiple values, comma-separated.
  /// * `search[creator_name]` Name of the creator.
  /// * `search[approver_name]` Name of the approver.
  /// * `search[status]` Filters aliases by status. Pass one of approved, active, pending, deleted, retired, processing, queued, or blank (default). *
  /// * `search[order]` Changes the sort order. Pass one of status (default), created_at, updated_at, name, or tag_count.
  /// * `limit` Maximum number of results to return per query.
  /// * `page` The page that will be returned. Can also be used with a or b + alias_id to get the aliases after or before the specified alias ID. For example a13 gets every alias after alias_id 13 up to the limit. This overrides the specified search ordering, created_at is always used instead.
  /// * Some aliases have a status which is an error message, these show up in searches where status is omitted but there is no way to search for them specifically.
  ///
  /// Response:
  /// Success:
  /// HTTP 200
  ///
  /// [{
  ///    "id": <numeric alias id>,
  ///    "status": <status string>,
  ///    "antecedent_name": <aliased-by tag name>,
  ///    "consequent_name": <aliased-to tag name>,
  ///    "post_count": <# matching posts>,
  ///    "reason": <explanation>,
  ///    "creator_id": <user id>,
  ///    "approver_id": <user id>
  ///    "created_at": <ISO8601 timestamp>,
  ///    "updated_at": <ISO8601 timestamp>,
  ///    "forum_post_id": <post id>,
  ///    "forum_topic_id": <topic id>,
  /// },
  /// ...
  /// ]
  /// If your query succeeds but produces no results, you will receive instead the following special value:
  ///
  /// { "tag_aliases":[] }
  static http.Request initSearchTagAliasesRequest({
    String? searchNameMatches,
    String? searchAntecedentName,
    String? searchConsequentName,
    String? searchAntecedentTagCategory,
    String? searchConsequentTagCategory,
    String? searchCreatorName,
    String? searchApproverName,
    String? searchStatus,
    String? searchOrder,
    int? limit,
    String? page,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
          path: "/tag_aliases.json",
          queryParameters: {
            if (searchNameMatches != null)
              "search[name_matches]": searchNameMatches,
            if (searchAntecedentName != null)
              "search[antecedent_name]": searchAntecedentName,
            if (searchConsequentName != null)
              "search[consequent_name]": searchConsequentName,
            if (searchAntecedentTagCategory != null)
              "search[antecedent_tag_category]": searchAntecedentTagCategory,
            if (searchConsequentTagCategory != null)
              "search[consequent_tag_category]": searchConsequentTagCategory,
            if (searchCreatorName != null)
              "search[creator_name]": searchCreatorName,
            if (searchApproverName != null)
              "search[approver_name]": searchApproverName,
            if (searchStatus != null) "search[status]": searchStatus,
            if (searchOrder != null) "search[order]": searchOrder,
            if (limit != null) "limit": limit, //_validateLimit(limit),
            if (page != null) "page": page,
          },
          method: "GET",
          credentials: credentials);

  /// (Listing)[https://e621.net/wiki_pages/2425#tag_alias_listing]
  /// The base URL is `/tag_implications.json` called with `GET`.
  ///
  /// * `search[name_matches]` A tag name expression to match against, which can include * as a wildcard. Both the implied-to and the implied-by tag are matched.
  /// * `search[antecedent_name]` Supports multiple tag names, comma-separated.
  /// * `search[consequent_name]` Supports multiple tag names, comma-separated.
  /// * `search[antecedent_tag_category]` Pass a valid tag category. Supports multiple values, comma-separated.
  /// * `search[consequent_tag_category]` Pass a valid tag category. Supports multiple values, comma-separated.
  /// * `search[creator_name]` Name of the creator.
  /// * `search[approver_name]` Name of the approver.
  /// * `search[status]` Filters implications by status. Pass one of approved, active, pending, deleted, retired, processing, queued, or blank (default). *
  /// * `search[order]` Changes the sort order. Pass one of status (default), created_at, updated_at, name, or tag_count.
  /// * `limit` Maximum number of results to return per query.
  /// * `page` The page that will be returned. Can also be used with a or b + implication_id to get the implications after or before the specified implication ID. For example a13 gets every implication after implication_id 13 up to the limit. This overrides the specified search ordering, created_at is always used instead.
  /// * Some implications have a status which is an error message, these show up in searches where status is omitted but there is no way to search for them specifically.
  ///
  /// Response:
  /// Success:
  /// HTTP 200
  ///
  /// [{
  ///    "id": <numeric implication id>,
  ///    "status": <status string>,
  ///    "antecedent_name": <implied-by tag name>,
  ///    "consequent_name": <implied-to tag name>,
  ///    "post_count": <# matching posts>,
  ///    "reason": <explanation>,
  ///    "creator_id": <user id>,
  ///    "approver_id": <user id>
  ///    "created_at": <ISO8601 timestamp>,
  ///    "updated_at": <ISO8601 timestamp>,
  ///    "forum_post_id": <post id>,
  ///    "forum_topic_id": <topic id>,
  /// },
  /// ...
  /// ]
  /// If your query succeeds but produces no results, you will receive instead the following special value:
  ///
  /// { "tag_implications":[] }
  static http.Request initSearchTagImplicationsRequest({
    String? searchNameMatches,
    String? searchAntecedentName,
    String? searchConsequentName,
    String? searchAntecedentTagCategory,
    String? searchConsequentTagCategory,
    String? searchCreatorName,
    String? searchApproverName,
    String? searchStatus,
    String? searchOrder,
    int? limit,
    String? page,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
          path: "/tag_implications.json",
          queryParameters: {
            if (searchNameMatches != null)
              "search[name_matches]": searchNameMatches,
            if (searchAntecedentName != null)
              "search[antecedent_name]": searchAntecedentName,
            if (searchConsequentName != null)
              "search[consequent_name]": searchConsequentName,
            if (searchAntecedentTagCategory != null)
              "search[antecedent_tag_category]": searchAntecedentTagCategory,
            if (searchConsequentTagCategory != null)
              "search[consequent_tag_category]": searchConsequentTagCategory,
            if (searchCreatorName != null)
              "search[creator_name]": searchCreatorName,
            if (searchApproverName != null)
              "search[approver_name]": searchApproverName,
            if (searchStatus != null) "search[status]": searchStatus,
            if (searchOrder != null) "search[order]": searchOrder,
            if (limit != null) "limit": limit, //_validateLimit(limit),
            if (page != null) "page": page,
          },
          method: "GET",
          credentials: credentials);
  // #endregion Tags

  // #region Favorites
  /// {@template ListFavorites}
  /// [Listing](https://e621.net/wiki_pages/2425#favorites_listing)
  /// The base URL is `/favorites.json` called with `GET`.
  ///
  /// * `user_id` Optional, the user to fetch the favorites from. If not specified will fetch the favorites from the currently authorized user.
  ///
  /// ### Response:
  ///
  /// #### Success:
  /// * HTTP 200
  ///
  /// {@macro postListing}
  /// See #posts_list for post data specification.
  /// ```
  /// {
  ///     "posts": [
  ///         <post data>
  ///     ]
  /// }
  /// ```
  /// #### Error:
  /// * HTTP 403 if the user has hidden their favorites.
  /// * HTTP 404 if the specified user_id does not exist or user_id is not specified and the user is not authorized.
  /// {@endtemplate}
  static http.Request initListFavoritesRequest({
    int? userId,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
          path: "/favorites.json",
          queryParameters: {
            if (userId != null) "user_id": userId,
          },
          method: "GET",
          credentials: credentials);

  /// {@template CreateFavorite}
  /// [Create](https://e621.net/wiki_pages/2425#favorites_create)
  /// The base URL is `/favorites.json` called with `POST`.
  ///
  /// * `post_id` The post id you want to favorite.
  ///
  /// ### Response:
  ///
  /// #### Success:
  /// * HTTP 200
  ///
  /// {@macro postListing}
  /// See #posts_list for post data specification.
  /// ```
  /// {
  ///     "posts": [
  ///         <post data>
  ///     ]
  /// }
  /// ```
  /// #### Error:
  /// * HTTP 422 if the user has hit the 80000 favorites cap with this body:
  /// ```
  /// {
  ///   "success": false,
  ///   "message": "You can only keep up to 80000 favorites.",
  ///   "code": null
  /// }
  /// ```
  /// {@endtemplate}
  static http.Request initCreateFavoriteRequest({
    required int postId,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsRequired(
          path: "/favorites.json",
          queryParameters: {
            "post_id": postId,
          },
          method: "GET",
          credentials: credentials);

  /// {@template DeleteFavorite}
  /// [Delete](https://e621.net/wiki_pages/2425#favorites_delete)
  /// The base URL is `/favorites/<post_id>.json` called with `DELETE`.
  ///
  /// There is no response.
  /// {@endtemplate}
  static http.Request initDeleteFavoriteRequest({
    required int postId,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsRequired(
          path: "/favorites/$postId.json",
          method: "DELETE",
          credentials: credentials);
  // #region Redirects
  /// {@macro ListFavorites}
  static http.Request initListFavoritesWithIdRequest({
    required int userId,
    BaseCredentials? credentials,
  }) =>
      initListFavoritesRequest(userId: userId, credentials: credentials);

  /// {@macro ListFavorites}
  static http.Request initListFavoritesWithCredentialsRequest({
    required BaseCredentials credentials,
  }) =>
      initListFavoritesRequest(credentials: credentials);
  // #endregion Redirects
  // #endregion Favorites

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
  static http.Request initSearchNotesRequest({
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
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
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
  static http.Request initCreateNoteRequest({
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
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
    return req;
  }

  /// [Delete](https://e621.net/wiki_pages/2425#notes_delete)
  ///
  /// The base URL is ``/notes/[noteId].json`` called with `DELETE`.
  ///
  /// There is no response.
  static http.Request initDeleteNoteRequest(
    int noteId, {
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(path: "/notes/$noteId.json");
    var req = http.Request("DELETE", uri);
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
    return req;
  }

  /// [Revert](https://e621.net/wiki_pages/2425#notes_revert)
  ///
  /// The base URL is ``/notes/[noteId]/revert.json`` called with PUT.
  ///
  /// * `version_id` The note version id to revert to.
  static http.Request initRevertNoteRequest(
    int noteId, {
    required int versionId,
    BaseCredentials? credentials,
  }) {
    var uri = baseUri.replace(
        path: "/notes/$noteId.json",
        queryParameters: {"version_id": versionId});
    var req = http.Request("PUT", uri);
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
    return req;
  }

  // #endregion Notes
  // #region Users
  /// https://e621.net/users.json?search%5Bname_matches%5D=a&search%5Babout_me%5D=a&search%5Bavatar_id%5D=1&search%5Blevel%5D=10&search%5Bmin_level%5D=10&search%5Bmax_level%5D=10&search%5Bcan_upload_free%5D=true&search%5Bcan_approve_posts%5D=true&search%5Border%5D=name
  /// `/users.json` `GET`
  /// * `search[name_matches]`
  /// * `search[about_me]`
  /// * `search[avatar_id]`
  /// * `search[level]`
  /// * `search[min_level]`
  /// * `search[max_level]`
  /// * `search[can_upload_free]`
  /// * `search[can_approve_posts]`
  /// * `search[order]`
  /// * limit How many items you want to retrieve. There is a hard limit of 320 items per request. Defaults to 75.
  /// * page The page that will be returned. Can also be used with a or b + item_id to get the items after or before the specified item ID. For example a13 gets every item after item_id 13 up to the limit.
  static http.Request initSearchUsersRequest({
    String? searchNameMatches,
    String? searchAboutMe,
    int? searchAvatarId,
    UserLevel? searchLevel,
    UserLevel? searchMinLevel,
    UserLevel? searchMaxLevel,
    bool? searchCanUploadFree,
    bool? searchCanApprovePosts,
    UserOrder? searchOrder,
    int? limit = 75,
    String? page,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
          path: "/users.json",
          queryParameters: {
            if (searchNameMatches != null) "": searchNameMatches,
            if (searchAboutMe != null) "": searchAboutMe,
            if (searchAvatarId != null) "": searchAvatarId,
            if (searchLevel != null) "": searchLevel,
            if (searchMinLevel != null) "": searchMinLevel,
            if (searchMaxLevel != null) "": searchMaxLevel,
            if (searchCanUploadFree != null) "": searchCanUploadFree,
            if (searchCanApprovePosts != null) "": searchCanApprovePosts,
            if (searchOrder != null) "": searchOrder,
            if (limit != null) "limit": _validateLimit(limit),
            if (page != null) "page": page,
          },
          method: "GET",
          credentials: credentials);

  /// https://e621.net/users/248688.json
  /// `/users/<User_ID>.json` `GET`
  static http.Request initGetUserRequest(
    int userId, {
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
          path: "/users/$userId.json", method: "GET", credentials: credentials);
  // #endregion Users
  // #region Sets
  /// https://e621.net/post_sets.json?search%5Bname%5D=*&search%5Bshortname%5D=*&search%5Bcreator_name%5D=baggie&search%5Border%5D=name
  /// `/post_sets.json` `GET`
  /// * `search[name]` * wildcard
  /// * `search[shortname]` * wildcard
  /// * `search[creator_name]` Must be a username, can't be a user id (I think)
  /// * `search[order]`
  /// * limit How many items you want to retrieve. There is a hard limit of 320 items per request. Defaults to 75.
  /// * page The page that will be returned. Can also be used with a or b + item_id to get the items after or before the specified item ID. For example a13 gets every item after item_id 13 up to the limit.
  static http.Request initSearchSetsRequest({
    String? searchName,
    String? searchShortname,
    String? searchCreatorName,
    SetOrder? searchOrder,
    int? limit = 75,
    String? page,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
        path: "/post_sets.json",
        method: "GET",
        credentials: credentials,
        queryParameters: {
          if (searchName != null) "search[name]": searchName,
          if (searchShortname != null) "search[shortname]": searchShortname,
          if (searchCreatorName != null)
            "search[creator_name]": searchCreatorName,
          if (searchOrder != null) "search[order]": searchOrder,
          if (limit != null) "limit": _validateLimit(limit),
          if (page != null) "page": page,
        },
      );

  /// https://e621.net/post_sets/35356.json
  /// `/post_sets/$setId.json` `GET`
  static http.Request initGetSetRequest(
    int setId, {
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsOptional(
        path: "/post_sets/$setId.json",
        method: "GET",
        credentials: credentials,
      );

  /// `/post_sets/$setId.json` `PATCH`
  /// * `post_set[name]`
  /// * `post_set[shortname]` The short name is used for the set's metatag name. Can only contain letters, numbers, and underscores and must contain at least one letter or underscore. set:example
  /// * `post_set[description]`
  /// * `post_set[is_public]` Private sets are only visible to you. Public sets are visible to anyone, but only you and users you assign as maintainers can edit the set. Only accounts three days or older can make public sets.
  /// * `post_set[transfer_on_delete]` If "Transfer on Delete" is enabled, when a post is deleted from the site, its parent (if any) will be added to this set in its place. Disable if you want posts to simply be removed from this set with no replacement.
  static http.Request initUpdateSetRequest(
    int setId, {
    String? postSetName,
    String? postSetShortname,
    String? postSetDescription,
    bool? postSetIsPublic,
    bool? postSetTransferOnDelete,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsRequired(
        path: "/post_sets/$setId.json",
        method: "PATCH",
        credentials: credentials,
        queryParameters: {
          if (postSetName != null) "": postSetName,
          if (postSetShortname != null) "": postSetShortname,
          if (postSetDescription != null) "": postSetDescription,
          if (postSetIsPublic != null) "": postSetIsPublic,
          if (postSetTransferOnDelete != null) "": postSetTransferOnDelete,
        },
      );

  /// `/post_sets/$setId.json` `POST`
  /// * `post_set[name]`
  /// * `post_set[shortname]` The short name is used for the set's metatag name. Can only contain letters, numbers, and underscores and must contain at least one letter or underscore. set:example
  /// * `post_set[description]`
  /// * `post_set[is_public]` Private sets are only visible to you. Public sets are visible to anyone, but only you and users you assign as maintainers can edit the set. Only accounts three days or older can make public sets.
  /// * `post_set[transfer_on_delete]` If "Transfer on Delete" is enabled, when a post is deleted from the site, its parent (if any) will be added to this set in its place. Disable if you want posts to simply be removed from this set with no replacement.
  static http.Request initCreateSetRequest({
    String? postSetName,
    String? postSetShortname,
    String? postSetDescription,
    bool? postSetIsPublic,
    bool? postSetTransferOnDelete,
    BaseCredentials? credentials,
  }) =>
      _baseInitRequestCredentialsRequired(
        path: "/post_sets.json",
        method: "POST",
        credentials: credentials,
        queryParameters: {
          if (postSetName != null) "": postSetName,
          if (postSetShortname != null) "": postSetShortname,
          if (postSetDescription != null) "": postSetDescription,
          if (postSetIsPublic != null) "": postSetIsPublic,
          if (postSetTransferOnDelete != null) "": postSetTransferOnDelete,
        },
      );
  // #endregion Sets
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
  static http.Request initSearchPoolsRequest({
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
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
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
  static http.Request initUpdatePoolRequest(
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
        "pool[post_ids]":
            poolPostIds.fold("", (accumulator, elem) => "$accumulator $elem"),
      if (poolIsActive != null) "pool[is_active]": poolIsActive,
      if (poolCategory != null) "pool[category]": poolCategory.toJsonString(),
    });
    var req = http.Request("PUT", uri);
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
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
  static http.Request initCreatePoolRequest({
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
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
    return req;
  }

  /// https://e621.net/wiki_pages/2425#pools_revert
  ///
  /// The base URL is `/pools/<Pool_ID>/revert.json` called with `PUT`.
  ///
  /// * `version_id` The version ID to revert to.
  static http.Request initRevertPoolRequest(
    int poolId, {
    int? versionId,
    BaseCredentials? credentials,
  }) {
    var uri =
        baseUri.replace(path: "/pools/$poolId/revert.json", queryParameters: {
      if (versionId != null) "version_id": versionId,
    });
    var req = http.Request("PUT", uri);
    (credentials ?? Api.activeCredentials)?.addToHeadersMap(req.headers);
    return req;
  }
  // #endregion Pools
}

enum SetOrder with PrettyPrintEnum {
  name._default("name"),
  shortname._default("shortname"),
  postCount._default("post_count"),
  createdAt._default("created_at"),
  updatedAt._default("updated_at");

  @override
  String toString() => jsonString;
  // String get jsonString => nameSnake;
  final String jsonString;
  const SetOrder._default(this.jsonString);
  // static SetOrder fromJsonString(String json) => switch (json) {
  // factory SetOrder.fromJsonString(String json) => switch (json) {
  factory SetOrder(String json) => switch (json) {
        "name" => name,
        "shortname" => shortname,
        "post_count" => postCount,
        "created_at" => createdAt,
        "updated_at" => updatedAt,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"name", '
                '"shortname", '
                '"post_count", '
                '"created_at", '
                'or "updated_at".',
          ),
      };
  static const jsonPropertyName = "level_string";
}

enum UserOrder with PrettyPrintEnum {
  joinDate._default("date"),
  name._default("name"),
  postUploadCount._default("post_upload_count"),
  noteCount._default("note_count"),
  postUpdateCount._default("post_update_count");

  @override
  String toString() => jsonString;
  // String get jsonString => nameSnake;
  final String jsonString;
  const UserOrder._default(this.jsonString);
  // static UserOrder fromJsonString(String json) => switch (json) {
  // factory UserOrder.fromJsonString(String json) => switch (json) {
  factory UserOrder(String json) => switch (json) {
        "name" => name,
        "date" => joinDate,
        "post_upload_count" => postUploadCount,
        "note_count" => noteCount,
        "post_update_count" => postUpdateCount,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"name", '
                '"date", '
                '"post_upload_count", '
                '"post_update_count", '
                'or "note_count".',
          ),
      };
  static const jsonPropertyName = "level_string";
}
//https://e621.net/forum_topics/21958
// Form data:
// _method: patch
// authenticity_token: MwYipMby8SqSTPPG9-1NdXebekJRZcq28AqwxASfULwPoXSM3MASwrl65Wkqvjuc2uiU_INkQKB2xY4Ip1xekA
// post_set[name]: ***REMOVED***character
// post_set[shortname]: ***REMOVED***character
// post_set[description]:
// post_set[is_public]: 0
// post_set[transfer_on_delete]: 0
// commit: Submit
// Url encoded: _method=patch&authenticity_token=MwYipMby8SqSTPPG9-1NdXebekJRZcq28AqwxASfULwPoXSM3MASwrl65Wkqvjuc2uiU_INkQKB2xY4Ip1xekA&post_set%5Bname%5D=***REMOVED***character&post_set%5Bshortname%5D=***REMOVED***character&post_set%5Bdescription%5D=&post_set%5Bis_public%5D=0&post_set%5Btransfer_on_delete%5D=0&commit=Submit
// Create:
// /post_sets/<Set_ID> w/ POST
// `/post_sets/<Set_ID>.json` with `POST`
// Edit:
// /post_sets/<Set_ID> w/ PATCH
// `/post_sets/<Set_ID>.json` with `PATCH`
// post_set[transfer_on_delete] If "Transfer on Delete" is enabled, when a post is deleted from the site, its parent (if any) will be added to this set in its place. Disable if you want posts to simply be removed from this set with no replacement.
// post_set[is_public] Private sets are only visible to you. Public sets are visible to anyone, but only you and users you assign as maintainers can edit the set. Only accounts three days or older can make public sets.
// post_set[description]
// post_set[shortname] The short name is used for the set's metatag name. Can only contain letters, numbers, and underscores and must contain at least one letter or underscore. set:example
// post_set[name]

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

// /post_sets/11775/update_posts method post
// post_set[post_ids_string]
enum Endpoint {
  /// https://e621.net/wiki_pages/2425#posts_create
  postCreate,

  /// https://e621.net/wiki_pages/2425#posts_update
  postUpdate,

  /// https://e621.net/wiki_pages/2425#posts_list
  postSearch,

  /// https://e621.net/wiki_pages/2425#flags_listing
  postFlagSearch,

  /// https://e621.net/wiki_pages/2425#flags_creating
  postFlagCreate,

  /// https://e621.net/wiki_pages/2425#Posts_vote
  postVote,

  /// https://e621.net/wiki_pages/2425#favorites_list
  favoriteSearch,

  /// https://e621.net/wiki_pages/2425#favorites_create
  favoriteCreate,

  /// https://e621.net/wiki_pages/2425#favorites_delete
  favoriteDelete,

  /// https://e621.net/wiki_pages/2425#tags_listing
  tagSearch,

  /// https://e621.net/wiki_pages/2425#tag_alias_listing
  tagAliasSearch,

  /// https://e621.net/wiki_pages/2425#tag_alias_listing
  tagImplicationSearch,

  /// https://e621.net/wiki_pages/2425#notes_listing
  noteSearch,

  /// https://e621.net/wiki_pages/2425#notes_create
  noteCreate,

  /// https://e621.net/wiki_pages/2425#notes_update
  noteUpdate,

  /// https://e621.net/wiki_pages/2425#notes_delete
  noteDelete,

  /// https://e621.net/wiki_pages/2425#notes_revert
  noteRevert,

  /// https://e621.net/wiki_pages/2425#pools_listing
  poolSearch,

  /// https://e621.net/wiki_pages/2425#pools_create
  poolCreate,

  /// https://e621.net/wiki_pages/2425#pools_update
  poolUpdate,

  /// https://e621.net/wiki_pages/2425#pools_revert
  poolRevert,

  /// https://e621.net/forum_topics/34583
  userInfo,

  /// https://e621.net/post_sets/7410.json
  setInfo,
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
