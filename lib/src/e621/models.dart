import 'dart:convert' as dc;
import 'package:j_util/e621.dart';
import 'package:j_util/src/e621/e621.dart';
import 'package:j_util/src/types.dart';

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

  factory Pool.fromRawJson(String str) => Pool.fromJson(dc.json.decode(str));

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

  factory Note.fromRawJson(String str) => Note.fromJson(dc.json.decode(str));

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

class PostScore {
  /// `up` The number of times voted up.
  final int up;

  /// `down` A negative number representing the number of times voted down.
  final int down;

  /// `total` The total score (up + down).
  final int total;

  PostScore({required this.up, required this.down, required this.total});

  PostScore copyWith({int? up, int? down, int? total}) => PostScore(
        up: up ?? this.up,
        down: down ?? this.down,
        total: total ?? this.total,
      );
}

class User {
  final int id;
  final String createdAt;
  final String name;
  final int level;
  final int baseUploadLimit;
  final int noteUpdateCount;
  final int postUpdateCount;
  final int postUploadCount;
  final bool isBanned;
  final bool canApprovePosts;
  final bool canUploadFree;
  final UserLevel levelString;
  final int? avatarId;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.level,
    required this.baseUploadLimit,
    required this.noteUpdateCount,
    required this.postUpdateCount,
    required this.postUploadCount,
    required this.isBanned,
    required this.canApprovePosts,
    required this.canUploadFree,
    required this.levelString,
    required this.avatarId,
  });

  User copyWith({
    int? id,
    String? createdAt,
    String? name,
    int? level,
    int? baseUploadLimit,
    int? noteUpdateCount,
    int? postUpdateCount,
    int? postUploadCount,
    bool? isBanned,
    bool? canApprovePosts,
    bool? canUploadFree,
    UserLevel? levelString,
    int? avatarId,
  }) =>
      User(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        level: level ?? this.level,
        baseUploadLimit: baseUploadLimit ?? this.baseUploadLimit,
        noteUpdateCount: noteUpdateCount ?? this.noteUpdateCount,
        postUpdateCount: postUpdateCount ?? this.postUpdateCount,
        postUploadCount: postUploadCount ?? this.postUploadCount,
        isBanned: isBanned ?? this.isBanned,
        canApprovePosts: canApprovePosts ?? this.canApprovePosts,
        canUploadFree: canUploadFree ?? this.canUploadFree,
        levelString: levelString ?? this.levelString,
        avatarId: avatarId ?? this.avatarId,
      );

  factory User.fromRawJson(String str) => User.fromJson(dc.json.decode(str));

  String toRawJson() => dc.json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        createdAt: json["created_at"],
        name: json["name"],
        level: json["level"],
        baseUploadLimit: json["base_upload_limit"],
        noteUpdateCount: json["note_update_count"],
        postUpdateCount: json["post_update_count"],
        postUploadCount: json["post_upload_count"],
        isBanned: json["is_banned"],
        canApprovePosts: json["can_approve_posts"],
        canUploadFree: json["can_upload_free"],
        levelString: UserLevel(json["level_string"]),
        avatarId: json["avatar_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "name": name,
        "level": level,
        "base_upload_limit": baseUploadLimit,
        "note_update_count": noteUpdateCount,
        "post_update_count": postUpdateCount,
        "post_upload_count": postUploadCount,
        "is_banned": isBanned,
        "can_approve_posts": canApprovePosts,
        "can_upload_free": canUploadFree,
        "level_string": levelString.jsonString,
        "avatar_id": avatarId,
      };
}

enum UserLevel with PrettyPrintEnum {
  anonymous._default(),
  blocked._default(),
  member._default(),
  privileged._default(),
  formerStaff._default(),
  janitor._default(),
  moderator._default(),
  admin._default();

  @override
  String toString() => namePretty;
  String get jsonString => namePretty;
  const UserLevel._default();
  // static UserLevel fromJsonString(String json) => switch (json) {
  // factory UserLevel.fromJsonString(String json) => switch (json) {
  factory UserLevel(String json) => switch (json) {
        "Anonymous" => anonymous,
        "Blocked" => blocked,
        "Member" => member,
        "Privileged" => privileged,
        "Former Staff" => formerStaff,
        "Janitor" => janitor,
        "Moderator" => moderator,
        "Admin" => admin,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of "Anonymous", "Blocked", "Member", '
                '"Privileged", "Former Staff", "Janitor", "Moderator", or "Admin".',
          ),
      };
  static const jsonPropertyName = "level_string";
}

class UserDetailed extends User {
  /// wiki_page_version_count
  final String wikiPageVersionCount;

  /// artist_version_count
  final String artistVersionCount;

  /// pool_version_count
  final String poolVersionCount;

  /// forum_post_count
  final String forumPostCount;

  /// comment_count
  final String commentCount;

  /// flag_count
  final String flagCount;

  /// positive_feedback_count
  final String positiveFeedbackCount;

  /// neutral_feedback_count
  final String neutralFeedbackCount;

  /// negative_feedback_count
  final String negativeFeedbackCount;

  /// upload_limit
  final String uploadLimit;

  UserDetailed({
    required this.wikiPageVersionCount,
    required this.artistVersionCount,
    required this.poolVersionCount,
    required this.forumPostCount,
    required this.commentCount,
    required this.flagCount,
    required this.positiveFeedbackCount,
    required this.neutralFeedbackCount,
    required this.negativeFeedbackCount,
    required this.uploadLimit,
    required super.id,
    required super.createdAt,
    required super.name,
    required super.level,
    required super.baseUploadLimit,
    required super.postUploadCount,
    required super.postUpdateCount,
    required super.noteUpdateCount,
    required super.isBanned,
    required super.canApprovePosts,
    required super.canUploadFree,
    required super.levelString,
    required super.avatarId,
  });

  factory UserDetailed.fromRawJson(String str) =>
      UserDetailed.fromJson(dc.json.decode(str));

  String toRawJson() => dc.json.encode(toJson());

  factory UserDetailed.fromJson(Map<String, dynamic> json) => UserDetailed(
        wikiPageVersionCount: json["wiki_page_version_count"],
        artistVersionCount: json["artist_version_count"],
        poolVersionCount: json["pool_version_count"],
        forumPostCount: json["forum_post_count"],
        commentCount: json["comment_count"],
        flagCount: json["flag_count"],
        positiveFeedbackCount: json["positive_feedback_count"],
        neutralFeedbackCount: json["neutral_feedback_count"],
        negativeFeedbackCount: json["negative_feedback_count"],
        uploadLimit: json["upload_limit"],
        id: json["id"],
        createdAt: json["created_at"],
        name: json["name"],
        level: json["level"],
        baseUploadLimit: json["base_upload_limit"],
        postUploadCount: json["post_upload_count"],
        postUpdateCount: json["post_update_count"],
        noteUpdateCount: json["note_update_count"],
        isBanned: json["is_banned"],
        canApprovePosts: json["can_approve_posts"],
        canUploadFree: json["can_upload_free"],
        levelString: json["level_string"],
        avatarId: json["avatar_id"],
      );
  @override
  Map<String, dynamic> toJson() => {
        "wiki_page_version_count": wikiPageVersionCount,
        "artist_version_count": artistVersionCount,
        "pool_version_count": poolVersionCount,
        "forum_post_count": forumPostCount,
        "comment_count": commentCount,
        "flag_count": flagCount,
        "positive_feedback_count": positiveFeedbackCount,
        "neutral_feedback_count": neutralFeedbackCount,
        "negative_feedback_count": negativeFeedbackCount,
        "upload_limit": uploadLimit,
        "id": id,
        "created_at": createdAt,
        "name": name,
        "level": level,
        "base_upload_limit": baseUploadLimit,
        "post_upload_count": postUploadCount,
        "post_update_count": postUpdateCount,
        "note_update_count": noteUpdateCount,
        "is_banned": isBanned,
        "can_approve_posts": canApprovePosts,
        "can_upload_free": canUploadFree,
        "level_string": levelString,
        "avatar_id": avatarId,
      };
}

/// https://e621.net/post_sets.json?35356
class Set {
  final int id;
  final String createdAt;
  final String updatedAt;
  final int creatorId;
  final bool isPublic;
  final String name;
  final String shortname;
  final String description;
  final int postCount;
  final bool transferOnDelete;
  final List<int> postIds;

  Set({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorId,
    required this.isPublic,
    required this.name,
    required this.shortname,
    required this.description,
    required this.postCount,
    required this.transferOnDelete,
    required this.postIds,
  });

  Set copyWith({
    String? createdAt,
    int? creatorId,
    String? description,
    int? id,
    bool? isPublic,
    String? name,
    int? postCount,
    List<int>? postIds,
    String? shortname,
    bool? transferOnDelete,
    String? updatedAt,
  }) =>
      Set(
        createdAt: createdAt ?? this.createdAt,
        creatorId: creatorId ?? this.creatorId,
        description: description ?? this.description,
        id: id ?? this.id,
        isPublic: isPublic ?? this.isPublic,
        name: name ?? this.name,
        postCount: postCount ?? this.postCount,
        postIds: postIds ?? this.postIds,
        shortname: shortname ?? this.shortname,
        transferOnDelete: transferOnDelete ?? this.transferOnDelete,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Set.fromRawJson(String str) => Set.fromJson(dc.json.decode(str));

  String toRawJson() => dc.json.encode(toJson());

  factory Set.fromJson(Map<String, dynamic> json) => Set(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        creatorId: json["creator_id"],
        isPublic: json["is_public"],
        name: json["name"],
        shortname: json["shortname"],
        description: json["description"],
        postCount: json["post_count"],
        transferOnDelete: json["transfer_on_delete"],
        postIds: (json["post_ids"] as List).cast(),
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "creator_id": creatorId,
        "is_public": isPublic,
        "name": name,
        "shortname": shortname,
        "description": description,
        "post_count": postCount,
        "transfer_on_delete": transferOnDelete,
        "post_ids": postIds,
      };
}

final class Post {
  // #region Json Fields
  /// The ID number of the post.
  final int id;

  /// The time the post was created in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  final String createdAt;

  /// The time the post was last updated in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  final String updatedAt;

  /// (array group)
  final File file;

  /// (array group)
  final Preview preview;

  /// (array group)
  final Sample sample;

  /// (array group)
  final Score score;

  /// (array group)
  final PostTags tags;

  /// A JSON array of tags that are locked on the post.
  final List<String> lockedTags;

  /// An ID that increases for every post alteration on E6 (explained below)
  final int changeSeq;

  /// (array group)
  final PostFlags flags;

  /// The post’s rating. Either s, q or e.
  final String rating;

  /// How many people have favorited the post.
  final int favCount;

  /// The source field of the post.
  final List<String> sources;

  /// An array of Pool IDs that the post is a part of.
  final List<String> pools;

  /// (array group)
  final PostRelationships relationships;

  /// The ID of the user that approved the post, if available.
  final int? approverId;

  /// The ID of the user that uploaded the post.
  final int uploaderId;

  /// The post’s description.
  final String description;

  /// The count of comments on the post.
  final int commentCount;

  /// If provided auth credentials, will return if the authenticated user has
  /// favorited the post or not. If not provided, will be false.
  final bool isFavorited;

  // #region Not Documented
  /// Guess
  final bool hasNotes;

  /// If post is a video, the video length. Otherwise, null.
  final num? duration;
  // #endregion Not Documented
  // #endregion Json Fields

  Post({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.file,
    required this.preview,
    required this.sample,
    required this.score,
    required this.tags,
    required this.lockedTags,
    required this.changeSeq,
    required this.flags,
    required this.rating,
    required this.favCount,
    required this.sources,
    required this.pools,
    required this.relationships,
    required this.approverId,
    required this.uploaderId,
    required this.description,
    required this.commentCount,
    required this.isFavorited,
    required this.hasNotes,
    required this.duration,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"] as int,
        createdAt: json["created_at"] as String,
        updatedAt: json["updated_at"] as String,
        file: File.fromJson(json["file"]),
        preview: Preview.fromJson(json["preview"]),
        sample: Sample.fromJson(json["sample"]),
        score: Score.fromJson(json["score"]),
        tags: PostTags.fromJson(json["tags"]),
        lockedTags: (json["locked_tags"] as List).cast<String>(),
        changeSeq: json["change_seq"] as int,
        flags: PostBitFlags.fromJson(json["flags"]),
        rating: json["rating"] as String,
        favCount: json["fav_count"] as int,
        sources: (json["sources"] as List).cast<String>(),
        pools: (json["pools"] as List).cast<String>(),
        relationships: PostRelationships.fromJson(json["relationships"]),
        approverId: json["approver_id"] as int?,
        uploaderId: json["uploader_id"] as int,
        description: json["description"] as String,
        commentCount: json["comment_count"] as int,
        isFavorited: json["is_favorited"] as bool,
        hasNotes: json["has_notes"] as bool,
        duration: json["duration"] as num?,
      );
  Post copyWith({
    int? id,
    String? createdAt,
    String? updatedAt,
    File? file,
    Preview? preview,
    Sample? sample,
    Score? score,
    PostTags? tags,
    List<String>? lockedTags,
    int? changeSeq,
    PostFlags? flags,
    String? rating,
    int? favCount,
    List<String>? sources,
    List<String>? pools,
    PostRelationships? relationships,
    int? approverId = -1,
    int? uploaderId,
    String? description,
    int? commentCount,
    bool? isFavorited,
    bool? hasNotes,
    num? duration = -1,
  }) =>
      Post(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        file: file ?? this.file,
        preview: preview ?? this.preview,
        sample: sample ?? this.sample,
        score: score ?? this.score,
        tags: tags ?? this.tags,
        lockedTags: lockedTags ?? this.lockedTags,
        changeSeq: changeSeq ?? this.changeSeq,
        flags: flags ?? this.flags,
        rating: rating ?? this.rating,
        favCount: favCount ?? this.favCount,
        sources: sources ?? this.sources,
        pools: pools ?? this.pools,
        relationships: relationships ?? this.relationships,
        approverId: (approverId ?? 1) < 0 ? approverId : this.approverId,
        uploaderId: uploaderId ?? this.uploaderId,
        description: description ?? this.description,
        commentCount: commentCount ?? this.commentCount,
        isFavorited: isFavorited ?? this.isFavorited,
        hasNotes: hasNotes ?? this.hasNotes,
        duration: (duration ?? 1) < 0 ? duration : this.duration,
      );
}

class File extends Preview {
  /// The file’s extension.
  final String ext;

  /// The size of the file in bytes.
  final int size;

  /// The md5 of the file.
  final String md5;

  const File({
    required super.width,
    required super.height,
    required this.ext,
    required this.size,
    required this.md5,
    required super.url,
  });
  File._useParentFromJson({
    required this.ext,
    required this.size,
    required this.md5,
    required Map<String, dynamic> json,
  }) : super.fromJsonGen(json);
  factory File.fromJson(Map<String, dynamic> json) =>
      File._useParentFromJson(
        ext: json["ext"] as String,
        size: json["size"] as int,
        md5: json["md5"] as String,
        json: json,
      );
}

class Preview {
  /// The width of the file.
  final int width;

  /// The height of the file.
  final int height;

  /// {@template E6Preview.url}
  ///
  /// The URL where the preview file is hosted on E6
  ///
  /// If the post is a video, this is a preview image from the video
  ///
  /// If auth is not provided, [this may be null][1]. This is currently replaced
  /// with an empty string in from json.
  ///
  /// [1]: https://e621.net/help/global_blacklist
  ///
  /// {@endtemplate}
  final String url;

  const Preview({
    required this.width,
    required this.height,
    required this.url,
  });
  factory Preview.fromJson(Map<String, dynamic> json) => Preview(
        width: json["width"],
        height: json["height"],
        url: json["url"] as String? ?? "",
      );
  Preview.fromJsonGen(Map<String, dynamic> json)
      : width = json["width"],
        height = json["height"],
        url = json["url"] as String? ?? "";
}

class Sample extends Preview {
  /// If the post has a sample/thumbnail or not. (True/False)
  final bool has;

  const Sample({
    required this.has,
    required super.width,
    required super.height,
    required super.url,
  });
  Sample._useParentFromJson({
    required this.has,
    required Map<String, dynamic> json,
  }) : super.fromJsonGen(json);
  factory Sample.fromJson(Map<String, dynamic> json) =>
      Sample._useParentFromJson(
        has: json["has"],
        json: json,
      );
}

class Score {
  /// The number of times voted up.
  final int up;

  /// A negative number representing the number of times voted down.
  final int down;

  /// The total score (up + down).
  final int total;

  const Score({
    required this.up,
    required this.down,
    required this.total,
  });
  factory Score.fromJson(Map<String, dynamic> json) => Score(
        up: json["up"] as int,
        down: json["down"] as int,
        total: json["total"] as int,
      );

  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "total": total,
      };
}

class PostTags {
  /// A JSON array of all the general tags on the post.
  final List<String> general;

  /// A JSON array of all the species tags on the post.
  final List<String> species;

  /// A JSON array of all the character tags on the post.
  final List<String> character;

  /// A JSON array of all the artist tags on the post.
  final List<String> artist;

  /// A JSON array of all the invalid tags on the post.
  final List<String> invalid;

  /// A JSON array of all the lore tags on the post.
  final List<String> lore;

  /// A JSON array of all the meta tags on the post.
  final List<String> meta;

  // #region Undocumented
  /// A JSON array of all the copyright tags on the post.
  final List<String> copyright;
  // #endregion Undocumented

  List<String> getByCategory(TagCategory c) =>
      getByCategorySafe(c) ??
      (throw ArgumentError.value(c, "c", "Can't be TagCategory._error"));
  List<String>? getByCategorySafe(TagCategory c) => switch (c) {
        TagCategory.general => general,
        TagCategory.species => species,
        TagCategory.character => character,
        TagCategory.artist => artist,
        TagCategory.invalid => invalid,
        TagCategory.lore => lore,
        TagCategory.meta => meta,
        TagCategory.copyright => copyright,
        _ => null,
      };

  const PostTags({
    required this.general,
    required this.species,
    required this.character,
    required this.artist,
    required this.invalid,
    required this.lore,
    required this.meta,
    required this.copyright,
  });
  factory PostTags.fromJson(Map<String, dynamic> json) => PostTags(
        general: (json["general"] as List).cast<String>(),
        species: (json["species"] as List).cast<String>(),
        character: (json["character"] as List).cast<String>(),
        artist: (json["artist"] as List).cast<String>(),
        invalid: (json["invalid"] as List).cast<String>(),
        lore: (json["lore"] as List).cast<String>(),
        meta: (json["meta"] as List).cast<String>(),
        copyright: (json["copyright"] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        "general": List<dynamic>.from(general.map((x) => x)),
        "species": List<dynamic>.from(species.map((x) => x)),
        "character": List<dynamic>.from(character.map((x) => x)),
        "artist": List<dynamic>.from(artist.map((x) => x)),
        "invalid": List<dynamic>.from(invalid.map((x) => x)),
        "lore": List<dynamic>.from(lore.map((x) => x)),
        "meta": List<dynamic>.from(meta.map((x) => x)),
        "copyright": List<dynamic>.from(copyright.map((x) => x)),
      };
}

class PostFlags {
  /// If the post is pending approval. (True/False)
  final bool pending;

  /// If the post is flagged for deletion. (True/False)
  final bool flagged;

  /// If the post has it’s notes locked. (True/False)
  final bool noteLocked;

  /// If the post’s status has been locked. (True/False)
  final bool statusLocked;

  /// If the post’s rating has been locked. (True/False)
  final bool ratingLocked;

  /// If the post has been deleted. (True/False)
  final bool deleted;

  const PostFlags({
    required this.pending,
    required this.flagged,
    required this.noteLocked,
    required this.statusLocked,
    required this.ratingLocked,
    required this.deleted,
  });
  factory PostFlags.fromJson(Map<String, dynamic> json) => PostFlags(
        pending: json["pending"] as bool,
        flagged: json["flagged"] as bool,
        noteLocked: json["note_locked"] as bool,
        statusLocked: json["status_locked"] as bool,
        ratingLocked: json["rating_locked"] as bool,
        deleted: json["deleted"] as bool,
      );
}

enum PostFlag {
  /// int.parse("000001", radix: 2);
  pending(bit: 1),

  /// int.parse("000010", radix: 2);
  flagged(bit: 2),

  /// int.parse("000100", radix: 2);
  noteLocked(bit: 4),

  /// int.parse("001000", radix: 2);
  statusLocked(bit: 8),

  /// int.parse("010000", radix: 2);
  ratingLocked(bit: 16),

  /// int.parse("100000", radix: 2);
  deleted(bit: 32);

  final int bit;
  const PostFlag({required this.bit});

  /// int.parse("000001", radix: 2);
  static const int pendingFlag = 1;

  /// int.parse("000010", radix: 2);
  static const int flaggedFlag = 2;

  /// int.parse("000100", radix: 2);
  static const int noteLockedFlag = 4;

  /// int.parse("001000", radix: 2);
  static const int statusLockedFlag = 8;

  /// int.parse("010000", radix: 2);
  static const int ratingLockedFlag = 16;

  /// int.parse("100000", radix: 2);
  static const int deletedFlag = 32;
  static int toInt(PostFlag f) => f.bit;
  static List<PostFlag> getFlags(int f) {
    var l = <PostFlag>[];
    if (f & pending.bit == pending.bit) l.add(pending);
    if (f & flagged.bit == flagged.bit) l.add(flagged);
    if (f & noteLocked.bit == noteLocked.bit) l.add(noteLocked);
    if (f & statusLocked.bit == statusLocked.bit) l.add(statusLocked);
    if (f & ratingLocked.bit == ratingLocked.bit) l.add(ratingLocked);
    if (f & deleted.bit == deleted.bit) l.add(deleted);
    return l;
  }

  bool hasFlag(int f) => (PostFlag.toInt(this) & f) == PostFlag.toInt(this);
}

class PostBitFlags implements PostFlags {
  @override
  bool get deleted => (_data & pendingFlag) == pendingFlag;

  @override
  bool get flagged => (_data & flaggedFlag) == flaggedFlag;

  @override
  bool get noteLocked => (_data & noteLockedFlag) == noteLockedFlag;

  @override
  bool get pending => (_data & statusLockedFlag) == statusLockedFlag;

  @override
  bool get ratingLocked => (_data & ratingLockedFlag) == ratingLockedFlag;

  @override
  bool get statusLocked => (_data & deletedFlag) == deletedFlag;
  final int _data;
  PostBitFlags({
    required bool pending,
    required bool flagged,
    required bool noteLocked,
    required bool statusLocked,
    required bool ratingLocked,
    required bool deleted,
  }) : _data = (pending ? pendingFlag : 0) +
            (flagged ? flaggedFlag : 0) +
            (noteLocked ? noteLockedFlag : 0) +
            (statusLocked ? statusLockedFlag : 0) +
            (ratingLocked ? ratingLockedFlag : 0) +
            (deleted ? deletedFlag : 0);
  factory PostBitFlags.fromJson(Map<String, dynamic> json) => PostBitFlags(
        pending: json["pending"] as bool,
        flagged: json["flagged"] as bool,
        noteLocked: json["note_locked"] as bool,
        statusLocked: json["status_locked"] as bool,
        ratingLocked: json["rating_locked"] as bool,
        deleted: json["deleted"] as bool,
      );
  static int getValue({
    bool pending = false,
    bool flagged = false,
    bool noteLocked = false,
    bool statusLocked = false,
    bool ratingLocked = false,
    bool deleted = false,
  }) =>
      (pending ? pendingFlag : 0) +
      (flagged ? flaggedFlag : 0) +
      (noteLocked ? noteLockedFlag : 0) +
      (statusLocked ? statusLockedFlag : 0) +
      (ratingLocked ? ratingLockedFlag : 0) +
      (deleted ? deletedFlag : 0);

  static const int pendingFlag = 1; //int.parse("000001", radix: 2);
  static const int flaggedFlag = 2; //int.parse("000010", radix: 2);
  static const int noteLockedFlag = 4; //int.parse("000100", radix: 2);
  static const int statusLockedFlag = 8; //int.parse("001000", radix: 2);
  static const int ratingLockedFlag = 16; //int.parse("010000", radix: 2);
  static const int deletedFlag = 32; //int.parse("100000", radix: 2);
}

class PostRelationships {
  /// The ID of the post’s parent, if it has one.
  final int? parentId;

  /// If the post has child posts (True/False)
  final bool hasChildren;

  /// If the post has active child posts (True/False)
  ///
  /// J's Note: I assume "active" means not deleted
  final bool hasActiveChildren;

  /// A list of child post IDs that are linked to the post, if it has any.
  final List<String> children;

  bool get hasParent => parentId != null;

  PostRelationships({
    required this.parentId,
    required this.hasChildren,
    required this.hasActiveChildren,
    required this.children,
  });
  factory PostRelationships.fromJson(Map<String, dynamic> json) =>
      PostRelationships(
        parentId: json["parent_id"] as int?,
        hasChildren: json["has_children"] as bool,
        hasActiveChildren: json["has_active_children"] as bool,
        children: (json["children"] as List).cast<String>(),
      );
}

class Alternates {
  // Alternate? the480P;
  // Alternate? the720P;
  Alternate? original;
  Map<String, Alternate> alternates;

  Alternates({
    // this.the480P,
    // this.the720P,
    Alternate? original,
    required this.alternates,
  }) : original = original ?? alternates["original"];

  factory Alternates.fromJson(Map<String, dynamic> json) => Alternates(
        // the480P: json["480p"] == null ? null : Alternate.fromJson(json["480p"]),
        // the720P: json["720p"] == null ? null : Alternate.fromJson(json["720p"]),
        original: json["original"] == null
            ? null
            : Alternate.fromJson(json["original"]),
        alternates: {
          for (var e in json.entries) e.key: Alternate.fromJson(e.value)
        },
      );

  // Map<String, dynamic> toJson() => {
  //       "480p": the480P?.toJson(),
  //       "720p": the720P?.toJson(),
  //       "original": original?.toJson(),
  //     };
  Map<String, dynamic> toJson() => alternates;
}

class Alternate {
  int height;
  String type;

  /// 0. the webm version (almost always null on original)
  /// 1. the mp4 version
  List<String?> urls;
  int width;

  Alternate({
    required this.height,
    required this.type,
    required this.urls,
    required this.width,
  });

  factory Alternate.fromJson(Map<String, dynamic> json) => Alternate(
        height: json["height"],
        type: json["type"],
        urls: List<String?>.from(json["urls"].map((x) => x)),
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "type": type,
        "urls": List<dynamic>.from(urls.map((x) => x)),
        "width": width,
      };
}

enum AlternateResolution {
  $720p(1280, 720),
  $480p(640, 480),
  original(double.infinity, double.infinity);

  final num maxVerticalResolution;
  final num maxHorizontalResolution;
  const AlternateResolution(
      this.maxHorizontalResolution, this.maxVerticalResolution);
  factory AlternateResolution.fromJson(String json) => switch (json) {
        "720p" => $720p,
        "480p" => $480p,
        "original" => original,
        _ => throw ArgumentError.value(
            json,
            "json",
            "must be "
                "720p, "
                "480p, "
                "or original"),
      };
  @override
  String toString() => switch (this) {
        $720p => "720p",
        $480p => "480p",
        original => "original",
      };
  static const AlternateResolution nhd = $480p;
  static const AlternateResolution sd = $480p;
  static const AlternateResolution vga = $480p;
  static const AlternateResolution hd = $720p;
  static const AlternateResolution hdtv = $720p;
  static const AlternateResolution wxga = $720p;
}

enum PostDataType {
  png,
  jpg,
  gif,
  webm,
  mp4,
  swf;

  bool isResourceOfDataType(String url) =>
      url.endsWith(toString()) ||
      (this == PostDataType.jpg && url.endsWith("jpeg"));
}

enum PostType {
  image,
  video,
  flash,
  ;
}

/// https://e621.net/wiki_pages/11262
enum TagCategory with PrettyPrintEnum {
  /// 0
  ///
  /// This is the default type of tag, hence why it's mentioned first. If you
  /// do not specify the type of tag you want a tag to be when you create it,
  /// this is what it will become. General tags are for things that do not fall
  /// under other categories (e.g., female, chair, and sitting).
  general,

  /// 1
  ///
  /// Artist tags identify the tag as the artist. This doesn't mean the artist
  /// of the original copyrighted artwork (for example, you wouldn't use the
  /// ken_sugimori tag on a picture of Pikachu drawn by someone else).
  artist,

  /// 2; WHY
  _error,

  /// 3
  ///
  /// A copyright tag is for the program or series that a copyrighted character
  /// or some other element (such as objects) was first featured in, like
  /// Renamon in Digimon or Pikachu and Poké Balls in Pokémon. It can also be
  /// used for the company that owns a work, media franchise, or character,
  /// like Disney owns the copyright to Mickey Mouse and Nintendo owns the
  /// Mario Bros series.
  copyright,

  /// 4
  ///
  /// A character tag is a tag defining the name of a character, like
  /// pinkie_pie_(mlp) or fox_mccloud.
  character,

  /// 5
  ///
  /// A species tag describes the species of a character or being in the
  /// picture like domestic_cat, feline or domestic_dog, canine.
  species,

  /// 6
  ///
  /// The invalid type, which was technically also introduced alongside Meta
  /// and Lore in March 2020, is for tags that are not allowed on any posts,
  /// such as things that are too common and unspecific to individually tag
  /// or common tagging errors. These kinds of tags should be either fixed to
  /// add the proper intended tags or modified to be more specific. If doing so
  /// is not necessary, then the invalid tag should be removed outright. Either
  /// way, invalid tags will be the first type you see on the sidebar, even
  /// above artists, as a reminder that those tags should not be there.
  ///
  /// Previously, tags were invalidated by being aliased to either invalid_tag
  /// or invalid_color. While eSix will continue using these tags for the
  /// foreseeable future, some invalidated tags had their original aliases
  /// removed and were retyped to the invalid type to encourage better tagging
  /// over a quick "remove the invalid tag and forget it" approach.
  invalid,

  /// 7
  ///
  /// Meta (as in metadata) was introduced as one of two new tag types in March
  /// 2020. This type is for the technical side of the post's file, the post
  /// itself, or things relating to e6's own handling of a post.
  ///
  /// <details><summary>Types of meta tags</summary>
  ///
  /// * File resolution: hi_res, absurd_res, superabsurd_res, low_res, and
  /// thumbnail. Resolution meta tags are added automatically by the site,
  /// since it can read resolution metadata.
  /// * Written, drawn, painted, or typed text.
  /// * Text done in specific languages, including "real" or natural languages (e.g. english_text, japanese_text) and constructed languages (e.g. esperanto_text and fictional languages including tantalog_text from Lilo & Stitch and aurebesh_text from Star Wars).
  /// * Poorly written English text (usually deliberate): engrish.
  /// * Translation related tags: translation_request, partially_translated, translation_check, translated, hard_translated, translated_description.
  /// * Audio spoken or sung in specific languages, including "real" or natural languages (e.g. english_audio, japanese_audio) and constructed languages.
  /// * File aspect ratio: e.g. 4:3, 3:4, 16:9, 1:1, widescreen, wallpaper, 4k.
  /// * Animation length: short_playtime for under 30 seconds, and long_playtime for at least 30 seconds.
  /// * Years in which the post itself was made: e.g. 2020.
  /// * Types of media that artwork are made in, which (with the exception of mixed_media) are suffixed with _(artwork): e.g. digital_media_(artwork), 3d_(artwork), photography_(artwork), traditional_media_(artwork), pencil_(artwork).
  /// * Animation and transitions: animated, animated_png (also media format-based), pixel_animation, 3d_animation, slideshow, frame_by_frame, loop.
  /// * Audiovisual media formats: flash and webm.
  /// * Flash posts with clickable or keyboard-compatible elements: interactive.
  /// * comic for the paneled form of communication media. This also includes manga, doujinshi, and 4koma.
  /// * Request tags for when users require assistance from others to provide further information (tagme, character_request, source_request, and the aforementioned translation_request) or if they want a censored post to have its censorship removed (uncensor_request).
  /// * Posts with incorrect or improper metadata in the sidebar: bad_metadata.
  /// * Posts that are missing a sample version of an image or whose sample image is broken: missing_sample.
  /// * How colors, color palettes, and contrasts are used in a post: e.g. restricted_palette, monochrome, greyscale, black_and_white, sepia, dark_theme, light_theme, blue_theme, blue_and_white, colorful, spot_color, high_contrast, color_contrast.
  /// * Images that are suitable for user avatars: icon.
  /// * Portrait tags featuring a single character's likeness: headshot_portrait, bust_portrait, half-length_portrait, three-quarter_portrait, full-length_portrait.
  /// * Posts edited by someone other than the artist: edit, cropped, censored, uncensored, nude_edit, color_edit.
  /// * Obviously doctored images: shopped, photo_manipulation, photomorph.
  /// * Shading, lines, and detail: detailed, colored, flat_colors, guide_lines, line_art, lineless_art, partially_colored, shaded, cel_shaded, sketch, colored_sketch, unfinished.
  /// * Audio (or lack thereof) in Flash and WebM posts: sound and no_sound.
  /// * Stories tied to posts: story, story_in_description, story_at_source.
  /// * Posts with sources that contain a different version of said post: alternate_version_at_source, better_version_at_source, smaller_version_at_source.
  /// * Posts with technical visual flaws, intentional or unintentional: compression_artifacts and aliasing.
  /// * Posts with at least 150 tags: tag_panic.
  /// * Watermarks: watermark, distracting_watermark, 3rd_party_watermark.
  /// * An artist's signature.
  /// * A web link or URL.</details>
  ///
  /// Note that there are also four meta tags that are typed as artist tags instead:
  ///
  /// * epilepsy_warning for posts containing flashing lights that could trigger epileptic seizures.
  /// * jumpscare_warning for animated and Flash posts containing shocking imagery and/or sounds that can catch a viewer off-guard.
  /// * audio_warning for loud, deafening audio in Flash and WebM posts
  /// * unknown_artist_signature for posts in which the artist isn't known but a signature is on it.
  /// * third-party edit for posts edited by someone other than the original artist(s).
  ///
  /// The first three are deliberately typed as such because the bright orange
  /// color warns users about the potential dangers of those posts. The fourth
  /// is to encourage members to try to identify artists by their signatures
  /// (especially since unknown_artist is already an artist tag anyway). The
  /// fifth is because the editor may have edited enough of the post that it
  /// can be seen as derivative art, although it also helps us keep track of
  /// edits that would violate the conditions of artists who don't allow edits
  /// of their works (see conditional_dnp).
  meta,

  /// 8
  ///
  /// This is for providing and correcting specific outside information (not
  /// covered by copyright or character) when tag what you see otherwise cannot
  /// provide such. These tags are all suffixed _(lore), and only admins can
  /// introduce new lore tags. [Read more](
  /// https://e621.net/wiki_pages/show_or_new?title=e621%3Alore_tags).
  lore;

  bool get isTrueCategory => this != _error;
  bool get isValidCategory => this != _error && this != invalid;

  dynamic toJson() => index.toString();
  factory TagCategory.fromJson(dynamic json) =>
      switch (int.parse(json as String)) {
        0 => TagCategory.general,
        1 => TagCategory.artist,
        2 => TagCategory._error,
        3 => TagCategory.copyright,
        4 => TagCategory.character,
        5 => TagCategory.species,
        6 => TagCategory.invalid,
        7 => TagCategory.meta,
        8 => TagCategory.lore,
        _ => throw UnsupportedError("type not supported"),
      };
}
