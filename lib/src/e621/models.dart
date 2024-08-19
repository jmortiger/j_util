import 'dart:convert' as dc;
import 'package:flutter/material.dart';
import 'package:j_util/e621.dart';

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

  String get searchById => 'pool:$id';
  String get searchByName => 'pool:$name';

  const Pool({
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

  const Note({
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

class User {
  /// From User
  final int id;

  /// From User
  final DateTime createdAt;

  /// From User
  final String name;

  /// From User
  final int level;

  /// From User
  final int baseUploadLimit;

  /// From User
  final int noteUpdateCount;

  /// From User
  final int postUpdateCount;

  /// From User
  final int postUploadCount;

  /// From User
  final bool isBanned;

  /// From User
  final bool canApprovePosts;

  /// From User
  final bool canUploadFree;

  /// From User
  final UserLevel levelString;

  /// From User
  final int? avatarId;

  const User({
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
    DateTime? createdAt,
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
    int? avatarId = -1,
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
        avatarId: avatarId == -1 ? this.avatarId : avatarId,
      );

  factory User.fromRawJson(String str) {
    var t = dc.json.decode(str);
    return (t is List) ? User.fromJson(t[0]) : User.fromJson(t);
  }

  String toRawJson() => dc.json.encode(toJson());

  User.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        createdAt = DateTime.parse(json["created_at"]),
        name = json["name"],
        level = json["level"],
        baseUploadLimit = json["base_upload_limit"],
        noteUpdateCount = json["note_update_count"],
        postUpdateCount = json["post_update_count"],
        postUploadCount = json["post_upload_count"],
        isBanned = json["is_banned"],
        canApprovePosts = json["can_approve_posts"],
        canUploadFree = json["can_upload_free"],
        levelString = UserLevel(json["level_string"]),
        avatarId = json["avatar_id"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
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

enum UserLevel {
  anonymous._default(0, 0, 9),
  blocked._default(10, 10, 11),
  member._default(11, 20, 21),
  privileged._default(21, 30, 31),
  formerStaff._default(31, 34, 35),
  janitor._default(35, 35, 36),
  moderator._default(36, 40, 41),
  admin._default(41, 50, 51);

  static const anonymousLevel = 0;
  static const blockedLevel = 10;
  static const memberLevel = 20;
  static const privilegedLevel = 30;
  static const formerStaffLevel = 34;
  static const janitorLevel = 35;
  static const moderatorLevel = 40;
  static const adminLevel = 50;
  final int min;
  final int value;
  final int max;
  @override
  String toString() => namePretty;
  String get jsonString => namePretty;
  String get namePretty => "${name[0].toUpperCase()}${name.substring(1)}";
  int get level => switch (this) {
        anonymous => anonymousLevel,
        blocked => blockedLevel,
        member => memberLevel,
        privileged => privilegedLevel,
        formerStaff => formerStaffLevel,
        janitor => janitorLevel,
        moderator => moderatorLevel,
        admin => adminLevel,
      };
  const UserLevel._default(this.min, this.value, this.max);
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
  factory UserLevel.fromInt(int json) => switch (json) {
        == anonymousLevel => anonymous,
        // int t when t > anonymous.min && t < anonymous.max => anonymous,
        == blockedLevel => blocked,
        // int t when t > blocked.min && t < blocked.max => blocked,
        == memberLevel => member,
        // int t when t > member.min && t < member.max => member,
        == privilegedLevel => privileged,
        // int t when t > privileged.min && t < privileged.max => privileged,
        == formerStaffLevel => formerStaff,
        // int t when t > formerStaff.min && t < formerStaff.max => formerStaff,
        == janitorLevel => janitor,
        // int t when t > janitor.min && t < janitor.max => janitor,
        == moderatorLevel => moderator,
        // int t when t > moderator.min && t < moderator.max => moderator,
        == adminLevel => admin,
        // int t when t > admin.min && t < admin.max => admin,
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
  /// From UserDetailed
  ///
  /// wiki_page_version_count
  final int wikiPageVersionCount;

  /// From UserDetailed
  ///
  /// artist_version_count
  final int artistVersionCount;

  /// From UserDetailed
  ///
  /// pool_version_count
  final int poolVersionCount;

  /// From UserDetailed
  ///
  /// forum_post_count
  final int forumPostCount;

  /// From UserDetailed
  ///
  /// comment_count
  final int commentCount;

  /// From UserDetailed
  ///
  /// flag_count
  final int flagCount;

  /// From UserDetailed
  ///
  /// positive_feedback_count
  final int positiveFeedbackCount;

  /// From UserDetailed
  ///
  /// neutral_feedback_count
  final int neutralFeedbackCount;

  /// From UserDetailed
  ///
  /// negative_feedback_count
  final int negativeFeedbackCount;

  /// From UserDetailed
  ///
  /// upload_limit
  final int uploadLimit;

  /// From UserDetailed
  ///
  /// profile_about
  final String profileAbout;

  /// From UserDetailed
  ///
  /// profile_artinfo
  final String profileArtInfo;

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
    required this.profileAbout,
    required this.profileArtInfo,
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

  @override
  String toRawJson() => dc.json.encode(toJson());

  UserDetailed.fromJson(Map<String, dynamic> json)
      : wikiPageVersionCount = json["wiki_page_version_count"],
        artistVersionCount = json["artist_version_count"],
        poolVersionCount = json["pool_version_count"],
        forumPostCount = json["forum_post_count"],
        commentCount = json["comment_count"],
        flagCount = json["flag_count"],
        positiveFeedbackCount = json["positive_feedback_count"],
        neutralFeedbackCount = json["neutral_feedback_count"],
        negativeFeedbackCount = json["negative_feedback_count"],
        uploadLimit = json["upload_limit"],
        profileAbout = json["profile_about"],
        profileArtInfo = json["profile_artinfo"],
        super.fromJson(json);
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
        "profile_about": profileAbout,
        "profile_artinfo": profileArtInfo,
      }..addAll(super.toJson());
}
/* mixin UserDetail on User {
  /// wiki_page_version_count
  late final int wikiPageVersionCount;

  /// artist_version_count
  late final int artistVersionCount;

  /// pool_version_count
  late final int poolVersionCount;

  /// forum_post_count
  late final int forumPostCount;

  /// comment_count
  late final int commentCount;

  /// flag_count
  late final int flagCount;

  /// positive_feedback_count
  late final int positiveFeedbackCount;

  /// neutral_feedback_count
  late final int neutralFeedbackCount;

  /// negative_feedback_count
  late final int negativeFeedbackCount;

  /// upload_limit
  late final int uploadLimit;

  ctor({
    required wikiPageVersionCount,
    required artistVersionCount,
    required poolVersionCount,
    required forumPostCount,
    required commentCount,
    required flagCount,
    required positiveFeedbackCount,
    required neutralFeedbackCount,
    required negativeFeedbackCount,
    required uploadLimit,
  }) {
    this.wikiPageVersionCount = wikiPageVersionCount;
    this.artistVersionCount = artistVersionCount;
    this.poolVersionCount = poolVersionCount;
    this.forumPostCount = forumPostCount;
    this.commentCount = commentCount;
    this.flagCount = flagCount;
    this.positiveFeedbackCount = positiveFeedbackCount;
    this.neutralFeedbackCount = neutralFeedbackCount;
    this.negativeFeedbackCount = negativeFeedbackCount;
    this.uploadLimit = uploadLimit;
  }
  @override
  UserDetail fromRawJson(String str) =>
      fromJsonUserDetail(dc.json.decode(str));

  @override
  String toRawJson() => dc.json.encode(toJson());

  static fromJson(Map<String, dynamic> json) {
        User
        wikiPageVersionCount = json["wiki_page_version_count"],
        artistVersionCount = json["artist_version_count"],
        poolVersionCount = json["pool_version_count"],
        forumPostCount = json["forum_post_count"],
        commentCount = json["comment_count"],
        flagCount = json["flag_count"],
        positiveFeedbackCount = json["positive_feedback_count"],
        neutralFeedbackCount = json["neutral_feedback_count"],
        negativeFeedbackCount = json["negative_feedback_count"],
        uploadLimit = json["upload_limit"],
       super.fromJson(json);
       }
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
      }..addAll(super.toJson());
} */

class UserLoggedIn extends User {
  /// From UserLoggedIn
  final bool blacklistUsers;

  /// From UserLoggedIn
  final bool descriptionCollapsedInitially;

  /// From UserLoggedIn
  final bool hideComments;

  /// From UserLoggedIn
  final bool showHiddenComments;

  /// From UserLoggedIn
  final bool showPostStatistics;

  /// From UserLoggedIn
  final bool receiveEmailNotifications;

  /// From UserLoggedIn
  final bool enableKeyboardNavigation;

  /// From UserLoggedIn
  final bool enablePrivacyMode;

  /// From UserLoggedIn
  final bool styleUsernames;

  /// From UserLoggedIn
  final bool enableAutoComplete;

  /// From UserLoggedIn
  final bool disableCroppedThumbnails;

  /// From UserLoggedIn
  final bool enableSafeMode;

  /// From UserLoggedIn
  final bool disableResponsiveMode;

  /// From UserLoggedIn
  final bool noFlagging;

  /// From UserLoggedIn
  final bool disableUserDmails;

  /// From UserLoggedIn
  final bool enableCompactUploader;

  /// From UserLoggedIn
  final bool replacementsBeta;

  /// From UserLoggedIn
  final DateTime updatedAt;

  /// From UserLoggedIn
  final String email;

  /// From UserLoggedIn
  final DateTime lastLoggedInAt;

  /// From UserLoggedIn
  final DateTime lastForumReadAt;

  /// From UserLoggedIn
  final String recentTags;

  /// From UserLoggedIn
  final int commentThreshold;

  /// From UserLoggedIn
  final String defaultImageSize;

  /// From UserLoggedIn
  final String favoriteTags;

  /// From UserLoggedIn
  final String blacklistedTags;

  /// From UserLoggedIn
  final String timeZone;

  /// From UserLoggedIn
  final int perPage;

  /// From UserLoggedIn
  final String customStyle;

  /// From UserLoggedIn
  final int favoriteCount;

  /// From UserLoggedIn
  final int apiRegenMultiplier;

  /// From UserLoggedIn
  final int apiBurstLimit;

  /// From UserLoggedIn
  final int remainingApiLimit;

  /// From UserLoggedIn
  final int statementTimeout;

  /// From UserLoggedIn
  ///
  /// Defaults to 80000.
  final int favoriteLimit;

  /// From UserLoggedIn
  ///
  /// Defaults to 40.
  final int tagQueryLimit;

  /// From UserLoggedIn
  final bool hasMail;

  UserLoggedIn({
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
    required this.blacklistUsers,
    required this.descriptionCollapsedInitially,
    required this.hideComments,
    required this.showHiddenComments,
    required this.showPostStatistics,
    required this.receiveEmailNotifications,
    required this.enableKeyboardNavigation,
    required this.enablePrivacyMode,
    required this.styleUsernames,
    required this.enableAutoComplete,
    required this.disableCroppedThumbnails,
    required this.enableSafeMode,
    required this.disableResponsiveMode,
    required this.noFlagging,
    required this.disableUserDmails,
    required this.enableCompactUploader,
    required this.replacementsBeta,
    required this.updatedAt,
    required this.email,
    required this.lastLoggedInAt,
    required this.lastForumReadAt,
    required this.recentTags,
    required this.commentThreshold,
    required this.defaultImageSize,
    required this.favoriteTags,
    required this.blacklistedTags,
    required this.timeZone,
    required this.perPage,
    required this.customStyle,
    required this.favoriteCount,
    required this.apiRegenMultiplier,
    required this.apiBurstLimit,
    required this.remainingApiLimit,
    required this.statementTimeout,
    required this.favoriteLimit,
    required this.tagQueryLimit,
    required this.hasMail,
  });

  @override
  UserLoggedIn copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    int? level,
    int? baseUploadLimit,
    int? postUploadCount,
    int? postUpdateCount,
    int? noteUpdateCount,
    bool? isBanned,
    bool? canApprovePosts,
    bool? canUploadFree,
    UserLevel? levelString,
    int? avatarId = -1,
    bool? blacklistUsers,
    bool? descriptionCollapsedInitially,
    bool? hideComments,
    bool? showHiddenComments,
    bool? showPostStatistics,
    bool? receiveEmailNotifications,
    bool? enableKeyboardNavigation,
    bool? enablePrivacyMode,
    bool? styleUsernames,
    bool? enableAutoComplete,
    bool? disableCroppedThumbnails,
    bool? enableSafeMode,
    bool? disableResponsiveMode,
    bool? noFlagging,
    bool? disableUserDmails,
    bool? enableCompactUploader,
    bool? replacementsBeta,
    DateTime? updatedAt,
    String? email,
    DateTime? lastLoggedInAt,
    DateTime? lastForumReadAt,
    String? recentTags,
    int? commentThreshold,
    String? defaultImageSize,
    String? favoriteTags,
    String? blacklistedTags,
    String? timeZone,
    int? perPage,
    String? customStyle,
    int? favoriteCount,
    int? apiRegenMultiplier,
    int? apiBurstLimit,
    int? remainingApiLimit,
    int? statementTimeout,
    int? favoriteLimit,
    int? tagQueryLimit,
    bool? hasMail,
  }) =>
      UserLoggedIn(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        level: level ?? this.level,
        baseUploadLimit: baseUploadLimit ?? this.baseUploadLimit,
        postUploadCount: postUploadCount ?? this.postUploadCount,
        postUpdateCount: postUpdateCount ?? this.postUpdateCount,
        noteUpdateCount: noteUpdateCount ?? this.noteUpdateCount,
        isBanned: isBanned ?? this.isBanned,
        canApprovePosts: canApprovePosts ?? this.canApprovePosts,
        canUploadFree: canUploadFree ?? this.canUploadFree,
        levelString: levelString ?? this.levelString,
        avatarId: avatarId == -1 ? this.avatarId : avatarId,
        blacklistUsers: blacklistUsers ?? this.blacklistUsers,
        descriptionCollapsedInitially:
            descriptionCollapsedInitially ?? this.descriptionCollapsedInitially,
        hideComments: hideComments ?? this.hideComments,
        showHiddenComments: showHiddenComments ?? this.showHiddenComments,
        showPostStatistics: showPostStatistics ?? this.showPostStatistics,
        receiveEmailNotifications:
            receiveEmailNotifications ?? this.receiveEmailNotifications,
        enableKeyboardNavigation:
            enableKeyboardNavigation ?? this.enableKeyboardNavigation,
        enablePrivacyMode: enablePrivacyMode ?? this.enablePrivacyMode,
        styleUsernames: styleUsernames ?? this.styleUsernames,
        enableAutoComplete: enableAutoComplete ?? this.enableAutoComplete,
        disableCroppedThumbnails:
            disableCroppedThumbnails ?? this.disableCroppedThumbnails,
        enableSafeMode: enableSafeMode ?? this.enableSafeMode,
        disableResponsiveMode:
            disableResponsiveMode ?? this.disableResponsiveMode,
        noFlagging: noFlagging ?? this.noFlagging,
        disableUserDmails: disableUserDmails ?? this.disableUserDmails,
        enableCompactUploader:
            enableCompactUploader ?? this.enableCompactUploader,
        replacementsBeta: replacementsBeta ?? this.replacementsBeta,
        updatedAt: updatedAt ?? this.updatedAt,
        email: email ?? this.email,
        lastLoggedInAt: lastLoggedInAt ?? this.lastLoggedInAt,
        lastForumReadAt: lastForumReadAt ?? this.lastForumReadAt,
        recentTags: recentTags ?? this.recentTags,
        commentThreshold: commentThreshold ?? this.commentThreshold,
        defaultImageSize: defaultImageSize ?? this.defaultImageSize,
        favoriteTags: favoriteTags ?? this.favoriteTags,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        timeZone: timeZone ?? this.timeZone,
        perPage: perPage ?? this.perPage,
        customStyle: customStyle ?? this.customStyle,
        favoriteCount: favoriteCount ?? this.favoriteCount,
        apiRegenMultiplier: apiRegenMultiplier ?? this.apiRegenMultiplier,
        apiBurstLimit: apiBurstLimit ?? this.apiBurstLimit,
        remainingApiLimit: remainingApiLimit ?? this.remainingApiLimit,
        statementTimeout: statementTimeout ?? this.statementTimeout,
        favoriteLimit: favoriteLimit ?? this.favoriteLimit,
        tagQueryLimit: tagQueryLimit ?? this.tagQueryLimit,
        hasMail: hasMail ?? this.hasMail,
      );

  factory UserLoggedIn.fromRawJson(String str) {
    var t = dc.json.decode(str);
    return (t is List) ? UserLoggedIn.fromJson(t[0]) : UserLoggedIn.fromJson(t);
  } // => UserLoggedIn.fromJson(dc.json.decode(str));

  @override
  String toRawJson() => dc.json.encode(toJson());

  UserLoggedIn.fromJson(Map<String, dynamic> json)
      : blacklistUsers = json["blacklist_users"],
        descriptionCollapsedInitially = json["description_collapsed_initially"],
        hideComments = json["hide_comments"],
        showHiddenComments = json["show_hidden_comments"],
        showPostStatistics = json["show_post_statistics"],
        receiveEmailNotifications = json["receive_email_notifications"],
        enableKeyboardNavigation = json["enable_keyboard_navigation"],
        enablePrivacyMode = json["enable_privacy_mode"],
        styleUsernames = json["style_usernames"],
        enableAutoComplete = json["enable_auto_complete"],
        disableCroppedThumbnails = json["disable_cropped_thumbnails"],
        enableSafeMode = json["enable_safe_mode"],
        disableResponsiveMode = json["disable_responsive_mode"],
        noFlagging = json["no_flagging"],
        disableUserDmails = json["disable_user_dmails"],
        enableCompactUploader = json["enable_compact_uploader"],
        replacementsBeta = json["replacements_beta"],
        updatedAt = DateTime.parse(json["updated_at"]),
        email = json["email"],
        lastLoggedInAt = DateTime.parse(json["last_logged_in_at"]),
        lastForumReadAt = DateTime.parse(json["last_forum_read_at"]),
        recentTags = json["recent_tags"],
        commentThreshold = json["comment_threshold"],
        defaultImageSize = json["default_image_size"],
        favoriteTags = json["favorite_tags"],
        blacklistedTags = json["blacklisted_tags"],
        timeZone = json["time_zone"],
        perPage = json["per_page"],
        customStyle = json["custom_style"],
        favoriteCount = json["favorite_count"],
        apiRegenMultiplier = json["api_regen_multiplier"],
        apiBurstLimit = json["api_burst_limit"],
        remainingApiLimit = json["remaining_api_limit"],
        statementTimeout = json["statement_timeout"],
        favoriteLimit = json["favorite_limit"],
        tagQueryLimit = json["tag_query_limit"],
        hasMail = json["has_mail"],
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
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
        "blacklist_users": blacklistUsers,
        "description_collapsed_initially": descriptionCollapsedInitially,
        "hide_comments": hideComments,
        "show_hidden_comments": showHiddenComments,
        "show_post_statistics": showPostStatistics,
        "receive_email_notifications": receiveEmailNotifications,
        "enable_keyboard_navigation": enableKeyboardNavigation,
        "enable_privacy_mode": enablePrivacyMode,
        "style_usernames": styleUsernames,
        "enable_auto_complete": enableAutoComplete,
        "disable_cropped_thumbnails": disableCroppedThumbnails,
        "enable_safe_mode": enableSafeMode,
        "disable_responsive_mode": disableResponsiveMode,
        "no_flagging": noFlagging,
        "disable_user_dmails": disableUserDmails,
        "enable_compact_uploader": enableCompactUploader,
        "replacements_beta": replacementsBeta,
        "updated_at": updatedAt.toIso8601String(),
        "email": email,
        "last_logged_in_at": lastLoggedInAt.toIso8601String(),
        "last_forum_read_at": lastForumReadAt.toIso8601String(),
        "recent_tags": recentTags,
        "comment_threshold": commentThreshold,
        "default_image_size": defaultImageSize,
        "favorite_tags": favoriteTags,
        "blacklisted_tags": blacklistedTags,
        "time_zone": timeZone,
        "per_page": perPage,
        "custom_style": customStyle,
        "favorite_count": favoriteCount,
        "api_regen_multiplier": apiRegenMultiplier,
        "api_burst_limit": apiBurstLimit,
        "remaining_api_limit": remainingApiLimit,
        "statement_timeout": statementTimeout,
        "favorite_limit": favoriteLimit,
        "tag_query_limit": tagQueryLimit,
        "has_mail": hasMail,
      };
}

class UserLoggedInDetail extends UserLoggedIn implements UserDetailed {
  /// From UserDetailed
  @override
  final int wikiPageVersionCount;

  /// From UserDetailed
  @override
  final int artistVersionCount;

  /// From UserDetailed
  @override
  final int poolVersionCount;

  /// From UserDetailed
  @override
  final int forumPostCount;

  /// From UserDetailed
  @override
  final int commentCount;

  /// From UserDetailed
  @override
  final int flagCount;

  /// From UserDetailed
  @override
  final int positiveFeedbackCount;

  /// From UserDetailed
  @override
  final int neutralFeedbackCount;

  /// From UserDetailed
  @override
  final int negativeFeedbackCount;

  /// From UserDetailed
  @override
  final int uploadLimit;

  /// From UserDetailed
  @override
  final String profileAbout;

  /// From UserDetailed
  @override
  final String profileArtInfo;

  UserLoggedInDetail({
    required this.wikiPageVersionCount,
    required this.artistVersionCount,
    required this.poolVersionCount,
    required this.forumPostCount,
    required this.commentCount,
    required this.flagCount,
    required super.favoriteCount,
    required this.positiveFeedbackCount,
    required this.neutralFeedbackCount,
    required this.negativeFeedbackCount,
    required this.uploadLimit,
    required this.profileAbout,
    required this.profileArtInfo,
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
    required super.blacklistUsers,
    required super.descriptionCollapsedInitially,
    required super.hideComments,
    required super.showHiddenComments,
    required super.showPostStatistics,
    required super.receiveEmailNotifications,
    required super.enableKeyboardNavigation,
    required super.enablePrivacyMode,
    required super.styleUsernames,
    required super.enableAutoComplete,
    required super.disableCroppedThumbnails,
    required super.enableSafeMode,
    required super.disableResponsiveMode,
    required super.noFlagging,
    required super.disableUserDmails,
    required super.enableCompactUploader,
    required super.replacementsBeta,
    required super.updatedAt,
    required super.email,
    required super.lastLoggedInAt,
    required super.lastForumReadAt,
    required super.recentTags,
    required super.commentThreshold,
    required super.defaultImageSize,
    required super.favoriteTags,
    required super.blacklistedTags,
    required super.timeZone,
    required super.perPage,
    required super.customStyle,
    required super.apiRegenMultiplier,
    required super.apiBurstLimit,
    required super.remainingApiLimit,
    required super.statementTimeout,
    required super.favoriteLimit,
    required super.tagQueryLimit,
    required super.hasMail,
  });

  @override
  UserLoggedInDetail copyWith({
    int? wikiPageVersionCount,
    int? artistVersionCount,
    int? poolVersionCount,
    int? forumPostCount,
    int? commentCount,
    int? flagCount,
    int? favoriteCount,
    int? positiveFeedbackCount,
    int? neutralFeedbackCount,
    int? negativeFeedbackCount,
    int? uploadLimit,
    String? profileAbout,
    String? profileArtInfo,
    int? id,
    DateTime? createdAt,
    String? name,
    int? level,
    int? baseUploadLimit,
    int? postUploadCount,
    int? postUpdateCount,
    int? noteUpdateCount,
    bool? isBanned,
    bool? canApprovePosts,
    bool? canUploadFree,
    UserLevel? levelString,
    int? avatarId = -1,
    bool? blacklistUsers,
    bool? descriptionCollapsedInitially,
    bool? hideComments,
    bool? showHiddenComments,
    bool? showPostStatistics,
    bool? receiveEmailNotifications,
    bool? enableKeyboardNavigation,
    bool? enablePrivacyMode,
    bool? styleUsernames,
    bool? enableAutoComplete,
    bool? disableCroppedThumbnails,
    bool? enableSafeMode,
    bool? disableResponsiveMode,
    bool? noFlagging,
    bool? disableUserDmails,
    bool? enableCompactUploader,
    bool? replacementsBeta,
    DateTime? updatedAt,
    String? email,
    DateTime? lastLoggedInAt,
    DateTime? lastForumReadAt,
    String? recentTags,
    int? commentThreshold,
    String? defaultImageSize,
    String? favoriteTags,
    String? blacklistedTags,
    String? timeZone,
    int? perPage,
    String? customStyle,
    int? apiRegenMultiplier,
    int? apiBurstLimit,
    int? remainingApiLimit,
    int? statementTimeout,
    int? favoriteLimit,
    int? tagQueryLimit,
    bool? hasMail,
  }) =>
      UserLoggedInDetail(
        wikiPageVersionCount: wikiPageVersionCount ?? this.wikiPageVersionCount,
        artistVersionCount: artistVersionCount ?? this.artistVersionCount,
        poolVersionCount: poolVersionCount ?? this.poolVersionCount,
        forumPostCount: forumPostCount ?? this.forumPostCount,
        commentCount: commentCount ?? this.commentCount,
        flagCount: flagCount ?? this.flagCount,
        favoriteCount: favoriteCount ?? this.favoriteCount,
        positiveFeedbackCount:
            positiveFeedbackCount ?? this.positiveFeedbackCount,
        neutralFeedbackCount: neutralFeedbackCount ?? this.neutralFeedbackCount,
        negativeFeedbackCount:
            negativeFeedbackCount ?? this.negativeFeedbackCount,
        uploadLimit: uploadLimit ?? this.uploadLimit,
        profileAbout: profileAbout ?? this.profileAbout,
        profileArtInfo: profileArtInfo ?? this.profileArtInfo,
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        level: level ?? this.level,
        baseUploadLimit: baseUploadLimit ?? this.baseUploadLimit,
        postUploadCount: postUploadCount ?? this.postUploadCount,
        postUpdateCount: postUpdateCount ?? this.postUpdateCount,
        noteUpdateCount: noteUpdateCount ?? this.noteUpdateCount,
        isBanned: isBanned ?? this.isBanned,
        canApprovePosts: canApprovePosts ?? this.canApprovePosts,
        canUploadFree: canUploadFree ?? this.canUploadFree,
        levelString: levelString ?? this.levelString,
        avatarId: avatarId == -1 ? this.avatarId : avatarId,
        blacklistUsers: blacklistUsers ?? this.blacklistUsers,
        descriptionCollapsedInitially:
            descriptionCollapsedInitially ?? this.descriptionCollapsedInitially,
        hideComments: hideComments ?? this.hideComments,
        showHiddenComments: showHiddenComments ?? this.showHiddenComments,
        showPostStatistics: showPostStatistics ?? this.showPostStatistics,
        receiveEmailNotifications:
            receiveEmailNotifications ?? this.receiveEmailNotifications,
        enableKeyboardNavigation:
            enableKeyboardNavigation ?? this.enableKeyboardNavigation,
        enablePrivacyMode: enablePrivacyMode ?? this.enablePrivacyMode,
        styleUsernames: styleUsernames ?? this.styleUsernames,
        enableAutoComplete: enableAutoComplete ?? this.enableAutoComplete,
        disableCroppedThumbnails:
            disableCroppedThumbnails ?? this.disableCroppedThumbnails,
        enableSafeMode: enableSafeMode ?? this.enableSafeMode,
        disableResponsiveMode:
            disableResponsiveMode ?? this.disableResponsiveMode,
        noFlagging: noFlagging ?? this.noFlagging,
        disableUserDmails: disableUserDmails ?? this.disableUserDmails,
        enableCompactUploader:
            enableCompactUploader ?? this.enableCompactUploader,
        replacementsBeta: replacementsBeta ?? this.replacementsBeta,
        updatedAt: updatedAt ?? this.updatedAt,
        email: email ?? this.email,
        lastLoggedInAt: lastLoggedInAt ?? this.lastLoggedInAt,
        lastForumReadAt: lastForumReadAt ?? this.lastForumReadAt,
        recentTags: recentTags ?? this.recentTags,
        commentThreshold: commentThreshold ?? this.commentThreshold,
        defaultImageSize: defaultImageSize ?? this.defaultImageSize,
        favoriteTags: favoriteTags ?? this.favoriteTags,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        timeZone: timeZone ?? this.timeZone,
        perPage: perPage ?? this.perPage,
        customStyle: customStyle ?? this.customStyle,
        apiRegenMultiplier: apiRegenMultiplier ?? this.apiRegenMultiplier,
        apiBurstLimit: apiBurstLimit ?? this.apiBurstLimit,
        remainingApiLimit: remainingApiLimit ?? this.remainingApiLimit,
        statementTimeout: statementTimeout ?? this.statementTimeout,
        favoriteLimit: favoriteLimit ?? this.favoriteLimit,
        tagQueryLimit: tagQueryLimit ?? this.tagQueryLimit,
        hasMail: hasMail ?? this.hasMail,
      );
  UserLoggedInDetail copyWithInstance(User? other) {
    var userD = other is UserDetailed ? other : null;
    var userL = other is UserLoggedIn ? other : null;
    return UserLoggedInDetail(
      wikiPageVersionCount: userD?.wikiPageVersionCount ?? wikiPageVersionCount,
      artistVersionCount: userD?.artistVersionCount ?? artistVersionCount,
      poolVersionCount: userD?.poolVersionCount ?? poolVersionCount,
      forumPostCount: userD?.forumPostCount ?? forumPostCount,
      commentCount: userD?.commentCount ?? commentCount,
      flagCount: userD?.flagCount ?? flagCount,
      favoriteCount: userL?.favoriteCount ?? favoriteCount,
      positiveFeedbackCount:
          userD?.positiveFeedbackCount ?? positiveFeedbackCount,
      neutralFeedbackCount: userD?.neutralFeedbackCount ?? neutralFeedbackCount,
      negativeFeedbackCount:
          userD?.negativeFeedbackCount ?? negativeFeedbackCount,
      uploadLimit: userD?.uploadLimit ?? uploadLimit,
      profileAbout: userD?.profileAbout ?? profileAbout,
      profileArtInfo: userD?.profileArtInfo ?? profileArtInfo,
      id: other?.id ?? id,
      createdAt: other?.createdAt ?? createdAt,
      name: other?.name ?? name,
      level: other?.level ?? level,
      baseUploadLimit: other?.baseUploadLimit ?? baseUploadLimit,
      postUploadCount: other?.postUploadCount ?? postUploadCount,
      postUpdateCount: other?.postUpdateCount ?? postUpdateCount,
      noteUpdateCount: other?.noteUpdateCount ?? noteUpdateCount,
      isBanned: other?.isBanned ?? isBanned,
      canApprovePosts: other?.canApprovePosts ?? canApprovePosts,
      canUploadFree: other?.canUploadFree ?? canUploadFree,
      levelString: other?.levelString ?? levelString,
      avatarId: other == null ? avatarId : other!.avatarId,
      blacklistUsers: userL?.blacklistUsers ?? blacklistUsers,
      descriptionCollapsedInitially:
          userL?.descriptionCollapsedInitially ?? descriptionCollapsedInitially,
      hideComments: userL?.hideComments ?? hideComments,
      showHiddenComments: userL?.showHiddenComments ?? showHiddenComments,
      showPostStatistics: userL?.showPostStatistics ?? showPostStatistics,
      receiveEmailNotifications:
          userL?.receiveEmailNotifications ?? receiveEmailNotifications,
      enableKeyboardNavigation:
          userL?.enableKeyboardNavigation ?? enableKeyboardNavigation,
      enablePrivacyMode: userL?.enablePrivacyMode ?? enablePrivacyMode,
      styleUsernames: userL?.styleUsernames ?? styleUsernames,
      enableAutoComplete: userL?.enableAutoComplete ?? enableAutoComplete,
      disableCroppedThumbnails:
          userL?.disableCroppedThumbnails ?? disableCroppedThumbnails,
      enableSafeMode: userL?.enableSafeMode ?? enableSafeMode,
      disableResponsiveMode:
          userL?.disableResponsiveMode ?? disableResponsiveMode,
      noFlagging: userL?.noFlagging ?? noFlagging,
      disableUserDmails: userL?.disableUserDmails ?? disableUserDmails,
      enableCompactUploader:
          userL?.enableCompactUploader ?? enableCompactUploader,
      replacementsBeta: userL?.replacementsBeta ?? replacementsBeta,
      updatedAt: userL?.updatedAt ?? updatedAt,
      email: userL?.email ?? email,
      lastLoggedInAt: userL?.lastLoggedInAt ?? lastLoggedInAt,
      lastForumReadAt: userL?.lastForumReadAt ?? lastForumReadAt,
      recentTags: userL?.recentTags ?? recentTags,
      commentThreshold: userL?.commentThreshold ?? commentThreshold,
      defaultImageSize: userL?.defaultImageSize ?? defaultImageSize,
      favoriteTags: userL?.favoriteTags ?? favoriteTags,
      blacklistedTags: userL?.blacklistedTags ?? blacklistedTags,
      timeZone: userL?.timeZone ?? timeZone,
      perPage: userL?.perPage ?? perPage,
      customStyle: userL?.customStyle ?? customStyle,
      apiRegenMultiplier: userL?.apiRegenMultiplier ?? apiRegenMultiplier,
      apiBurstLimit: userL?.apiBurstLimit ?? apiBurstLimit,
      remainingApiLimit: userL?.remainingApiLimit ?? remainingApiLimit,
      statementTimeout: userL?.statementTimeout ?? statementTimeout,
      favoriteLimit: userL?.favoriteLimit ?? favoriteLimit,
      tagQueryLimit: userL?.tagQueryLimit ?? tagQueryLimit,
      hasMail: userL?.hasMail ?? hasMail,
    );
  }

  factory UserLoggedInDetail.fromRawJson(String str) =>
      UserLoggedInDetail.fromJson(dc.json.decode(str));

  @override
  String toRawJson() => dc.json.encode(toJson());

  UserLoggedInDetail.fromJson(Map<String, dynamic> json)
      : wikiPageVersionCount = json["wiki_page_version_count"],
        artistVersionCount = json["artist_version_count"],
        poolVersionCount = json["pool_version_count"],
        forumPostCount = json["forum_post_count"],
        commentCount = json["comment_count"],
        flagCount = json["flag_count"],
        positiveFeedbackCount = json["positive_feedback_count"],
        neutralFeedbackCount = json["neutral_feedback_count"],
        negativeFeedbackCount = json["negative_feedback_count"],
        uploadLimit = json["upload_limit"],
        profileAbout = json["profile_about"],
        profileArtInfo = json["profile_artinfo"],
        super.fromJson(
            json) /* (
          favoriteCount: json["favorite_count"],
          id: json["id"],
          createdAt: DateTime.parse(json["created_at"]),
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
          blacklistUsers: json["blacklist_users"],
          descriptionCollapsedInitially:
              json["description_collapsed_initially"],
          hideComments: json["hide_comments"],
          showHiddenComments: json["show_hidden_comments"],
          showPostStatistics: json["show_post_statistics"],
          receiveEmailNotifications: json["receive_email_notifications"],
          enableKeyboardNavigation: json["enable_keyboard_navigation"],
          enablePrivacyMode: json["enable_privacy_mode"],
          styleUsernames: json["style_usernames"],
          enableAutoComplete: json["enable_auto_complete"],
          disableCroppedThumbnails: json["disable_cropped_thumbnails"],
          enableSafeMode: json["enable_safe_mode"],
          disableResponsiveMode: json["disable_responsive_mode"],
          noFlagging: json["no_flagging"],
          disableUserDmails: json["disable_user_dmails"],
          enableCompactUploader: json["enable_compact_uploader"],
          replacementsBeta: json["replacements_beta"],
          updatedAt: DateTime.parse(json["updated_at"]),
          email: json["email"],
          lastLoggedInAt: DateTime.parse(json["last_logged_in_at"]),
          lastForumReadAt: DateTime.parse(json["last_forum_read_at"]),
          recentTags: json["recent_tags"],
          commentThreshold: json["comment_threshold"],
          defaultImageSize: json["default_image_size"],
          favoriteTags: json["favorite_tags"],
          blacklistedTags: json["blacklisted_tags"],
          timeZone: json["time_zone"],
          perPage: json["per_page"],
          customStyle: json["custom_style"],
          apiRegenMultiplier: json["api_regen_multiplier"],
          apiBurstLimit: json["api_burst_limit"],
          remainingApiLimit: json["remaining_api_limit"],
          statementTimeout: json["statement_timeout"],
          favoriteLimit: json["favorite_limit"],
          tagQueryLimit: json["tag_query_limit"],
          hasMail: json["has_mail"],
        ) */
  ;

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
        "profile_about": profileAbout,
        "profile_artinfo": profileArtInfo,
      }..addAll(super.toJson());
}

Type findUserModelType(Map<String, dynamic> json) =>
    json["wiki_page_version_count"] != null
        ? json["api_burst_limit"] != null
            ? UserLoggedInDetail
            : UserDetailed
        : json["api_burst_limit"] != null
            ? UserLoggedIn
            : User;

/// https://e621.net/post_sets.json?35356
class PostSet {
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

  String get searchById => 'set:$id';
  String get searchByShortname => 'set:$shortname';

  const PostSet({
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

  PostSet copyWith({
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
      PostSet(
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

  factory PostSet.fromRawJson(String str) =>
      PostSet.fromJson(dc.json.decode(str));

  String toRawJson() => dc.json.encode(toJson());

  factory PostSet.fromJson(Map<String, dynamic> json) => PostSet(
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

class Post {
  // #region Json Fields
  /// The ID number of the post.
  final int id;

  /// The time the post was created in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  final DateTime createdAt;

  /// The time the post was last updated in the format of YYYY-MM-DDTHH:MM:SS.MS+00:00.
  final DateTime updatedAt;

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
  final List<int> pools;

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

  factory Post.fromRawJson(String json) {
    var t = dc.jsonDecode(json);
    try {
      return Post.fromJson(t);
    } catch (e) {
      return Post.fromJson(t["post"]);
    }
  }
  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"] as int,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
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
        pools: (json["pools"] as List).cast<int>(),
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
    List<int>? pools,
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
  factory File.fromJson(Map<String, dynamic> json) => File._useParentFromJson(
        ext: json["ext"] as String,
        size: json["size"] as int,
        md5: json["md5"] as String,
        json: json,
      );
  @override
  File copyWith({
    String? ext,
    int? size,
    String? md5,
    String? url,
    int? width,
    int? height,
  }) =>
      File(
        ext: ext ?? this.ext,
        size: size ?? this.size,
        md5: md5 ?? this.md5,
        height: height ?? this.height,
        url: url ?? this.url,
        width: width ?? this.width,
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
  Preview copyWith({
    String? url,
    int? width,
    int? height,
  }) =>
      Preview(
        height: height ?? this.height,
        url: url ?? this.url,
        width: width ?? this.width,
      );
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
  factory Score.fromJsonRaw(String json) => Score.fromJson(dc.jsonDecode(json));
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

  Score copyWith({
    int? up,
    int? down,
    int? total,
  }) =>
      Score(
        up: up ?? this.up,
        down: down ?? this.down,
        total: total ?? this.total,
      );
}

/// Result of successful vote call.
@immutable
class VoteResult {
  /// The number of times voted up.
  final int up;

  /// A negative number representing the number of times voted down.
  final int down;

  /// The total score (up + down).
  final int score;

  /// Our score is 1 (for upvoted), 0 (for no vote), or -1 (for downvoted).
  final int ourScore;

  const VoteResult({
    required this.up,
    required this.down,
    required this.score,
    required this.ourScore,
  });
  factory VoteResult.fromJsonRaw(String json) =>
      VoteResult.fromJson(dc.jsonDecode(json));
  factory VoteResult.fromJson(Map<String, dynamic> json) => VoteResult(
        up: json["up"] as int,
        down: json["down"] as int,
        score: json["score"] as int,
        ourScore: json["our_score"] as int,
      );

  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "score": score,
        "our_score": ourScore,
      };

  VoteResult copyWith({
    int? up,
    int? down,
    int? score,
    int? ourScore,
  }) =>
      VoteResult(
        up: up ?? this.up,
        down: down ?? this.down,
        score: score ?? this.score,
        ourScore: ourScore ?? this.ourScore,
      );
}

@immutable
class UpdatedScore extends Score implements VoteResult {
  /// The total score (up + down).
  @override
  int get score => total;

  /// Our score is 1 (for upvoted), 0 (for no vote), or -1 (for downvoted).
  @override
  final int ourScore;

  bool get isUpvoted => ourScore > 0;
  bool get isDownvoted => ourScore < 0;
  bool get isVotedOn => ourScore != 0;

  /// `true` if the user upvoted this post, `false` if the user downvoted this post, `null` if the user didn't vote on this post.
  bool? get voteState => switch (ourScore) {
        > 0 => true,
        < 0 => false,
        == 0 => null,
        _ => null,
      };

  const UpdatedScore.inherited({
    required super.up,
    required super.down,
    required super.total,
    required this.ourScore,
  });
  const UpdatedScore({
    required int up,
    required int down,
    required int score,
    required this.ourScore,
  }) : super(up: up, down: down, total: score);
  factory UpdatedScore.fromJsonRaw(String json) =>
      UpdatedScore.fromJson(dc.jsonDecode(json));
  UpdatedScore.fromJson(Map<String, dynamic> json)
      : this(
          up: json["up"] as int,
          down: json["down"] as int,
          score: json["score"] as int,
          ourScore: json["our_score"] as int,
        );

  @override
  Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
        "score": score,
        "total": total,
        "our_score": ourScore,
      };

  @override
  UpdatedScore copyWith({
    int? up,
    int? down,
    int? score,
    int? total,
    int? ourScore,
  }) =>
      UpdatedScore(
        up: up ?? this.up,
        down: down ?? this.down,
        score: score ?? total ?? this.score,
        ourScore: ourScore ?? this.ourScore,
      );
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
  final List<int> children;

  bool get hasParent => parentId != null;

  const PostRelationships({
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
        children: (json["children"] as List).cast<int>(),
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
enum TagCategory {
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
