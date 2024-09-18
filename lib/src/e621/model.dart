import 'dart:convert' as dc;
import 'general_enums.dart';

mixin BaseModel {
  Map<String, dynamic> toJson();

  String toRawJson() => dc.json.encode(toJson());
}
typedef RecordPool = ({
  int id,
  String name,
  DateTime createdAt,
  DateTime updatedAt,
  int creatorId,
  String description,
  bool isActive,
  PoolCategory category,
  List<int> postIds,
  String creatorName,
  int postCount,
});

abstract class Pool with BaseModel {
  const Pool();

  /// The ID of the pool.
  int get id;

  /// The name of the pool.
  String get name;

  /// The time the pool was created in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  DateTime get createdAt;

  /// The time the pool was updated in the format of `YYYY-MM-DDTHH:MM:SS.MS+00:00`.
  DateTime get updatedAt;

  /// The ID of the user that created the pool.
  int get creatorId;

  /// The description of the pool.
  String get description;

  /// If the pool is active and still getting posts added. (True/False)
  bool get isActive;

  /// Can be “series” or “collection”.
  PoolCategory get category;

  /// An array group of posts in the pool.
  List<int> get postIds;

  /// The name of the user that created the pool.
  String get creatorName;

  /// The amount of posts in the pool.
  int get postCount;

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "creator_id": creatorId,
        "description": description,
        "is_active": isActive,
        "category": category.toJson(),
        "post_ids": postIds, //List<dynamic>.from(postIds.map((x) => x)),
        "creator_name": creatorName,
        "post_count": postCount,
      };
  static RecordPool deserialize(dynamic json) {
    if (json.runtimeType == String) json = dc.jsonDecode(json);
    return (
      id: json["id"],
      name: json["name"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      creatorId: json["creator_id"],
      description: json["description"],
      isActive: json["is_active"],
      category: PoolCategory.fromJson(json["category"]),
      postIds: (json["post_ids"] as List).cast<int>(),
      creatorName: json["creator_name"],
      postCount: json["post_count"],
    );
  }
}

abstract class User with BaseModel {
  /// From User
  int get id;

  /// From User
  DateTime get createdAt;

  /// From User
  String get name;

  /// From User
  int get level;

  /// From User
  int get baseUploadLimit;

  /// From User
  int get noteUpdateCount;

  /// From User
  int get postUpdateCount;

  /// From User
  int get postUploadCount;

  /// From User
  bool get isBanned;

  /// From User
  bool get canApprovePosts;

  /// From User
  bool get canUploadFree;

  /// From User
  UserLevel get levelString;

  /// From User
  int? get avatarId;

  const User();
  @override
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

abstract class UserDetailed extends User {
  /// From UserDetailed
  int get wikiPageVersionCount;

  /// From UserDetailed
  int get artistVersionCount;

  /// From UserDetailed
  int get poolVersionCount;

  /// From UserDetailed
  int get forumPostCount;

  /// From UserDetailed
  int get commentCount;

  /// From UserDetailed
  int get flagCount;

  /// From UserDetailed
  int get positiveFeedbackCount;

  /// From UserDetailed
  int get neutralFeedbackCount;

  /// From UserDetailed
  int get negativeFeedbackCount;

  /// From UserDetailed
  int get uploadLimit;

  /// From UserDetailed
  String get profileAbout;

  /// From UserDetailed
  String get profileArtInfo;

  const UserDetailed();

  @override
  String toRawJson() => dc.json.encode(toJson());

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

abstract class UserLoggedIn extends User {
  /// From UserLoggedIn
  bool get blacklistUsers;

  /// From UserLoggedIn
  bool get descriptionCollapsedInitially;

  /// From UserLoggedIn
  bool get hideComments;

  /// From UserLoggedIn
  bool get showHiddenComments;

  /// From UserLoggedIn
  bool get showPostStatistics;

  /// From UserLoggedIn
  bool get receiveEmailNotifications;

  /// From UserLoggedIn
  bool get enableKeyboardNavigation;

  /// From UserLoggedIn
  bool get enablePrivacyMode;

  /// From UserLoggedIn
  bool get styleUsernames;

  /// From UserLoggedIn
  bool get enableAutoComplete;

  /// From UserLoggedIn
  bool get disableCroppedThumbnails;

  /// From UserLoggedIn
  bool get enableSafeMode;

  /// From UserLoggedIn
  bool get disableResponsiveMode;

  /// From UserLoggedIn
  bool get noFlagging;

  /// From UserLoggedIn
  bool get disableUserDmails;

  /// From UserLoggedIn
  bool get enableCompactUploader;

  /// From UserLoggedIn
  bool get replacementsBeta;

  /// From UserLoggedIn
  DateTime get updatedAt;

  /// From UserLoggedIn
  String get email;

  /// From UserLoggedIn
  DateTime get lastLoggedInAt;

  /// From UserLoggedIn
  DateTime get lastForumReadAt;

  /// From UserLoggedIn
  String get recentTags;

  /// From UserLoggedIn
  int get commentThreshold;

  /// From UserLoggedIn
  String get defaultImageSize;

  /// From UserLoggedIn
  String get favoriteTags;

  /// From UserLoggedIn
  String get blacklistedTags;

  /// From UserLoggedIn
  String get timeZone;

  /// From UserLoggedIn
  int get perPage;

  /// From UserLoggedIn
  String get customStyle;

  /// From UserLoggedIn
  int get favoriteCount;

  /// From UserLoggedIn
  int get apiRegenMultiplier;

  /// From UserLoggedIn
  int get apiBurstLimit;

  /// From UserLoggedIn
  int get remainingApiLimit;

  /// From UserLoggedIn
  int get statementTimeout;

  /// From UserLoggedIn
  ///
  /// Defaults to 80000.
  int get favoriteLimit;

  /// From UserLoggedIn
  ///
  /// Defaults to 40.
  int get tagQueryLimit;

  /// From UserLoggedIn
  bool get hasMail;

  const UserLoggedIn();

  @override
  Map<String, dynamic> toJson() => {
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
      }..addAll(super.toJson());
}
