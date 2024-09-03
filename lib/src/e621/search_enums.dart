// import 'package:j_util/j_util_full.dart' show PrettyPrintEnum;
import 'general_enums.dart';

enum SetOrder with ApiQueryParameter/* , PrettyPrintEnum */ {
  name._default("name"),
  shortname._default("shortname"),
  postCount._default("post_count"),
  createdAt._default("created_at"),
  updatedAt._default("updated_at");

  @override
  final String query;

  @override
  String toString() => query;
  // String get jsonString => nameSnake;
  @Deprecated("Use query")
  String get jsonString => query;
  const SetOrder._default(this.query);
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
}

enum PoolOrder with ApiQueryParameter/* , PrettyPrintEnum */ {
  name._default("name"),
  postCount._default("post_count"),
  createdAt._default("created_at"),
  updatedAt._default("updated_at");

  @override
  final String query;

  @override
  String toString() => query;
  // String get jsonString => nameSnake;
  @Deprecated("Use query")
  String get jsonString => query;
  const PoolOrder._default(this.query);
  // static PoolOrder fromJsonString(String json) => switch (json) {
  // factory PoolOrder.fromJsonString(String json) => switch (json) {
  factory PoolOrder(String json) => switch (json) {
        "name" => name,
        "post_count" => postCount,
        "created_at" => createdAt,
        "updated_at" => updatedAt,
        _ => throw ArgumentError.value(
            json,
            "json",
            'must be a value of '
                '"name", '
                '"post_count", '
                '"created_at", '
                'or "updated_at".',
          ),
      };
}

enum UserOrder with ApiQueryParameter/* , PrettyPrintEnum */ {
  joinDate._default("date"),
  name._default("name"),
  postUploadCount._default("post_upload_count"),
  noteCount._default("note_count"),
  postUpdateCount._default("post_update_count");

  @override
  final String query;

  @override
  String toString() => query;
  // String get jsonString => nameSnake;
  @Deprecated("Use query")
  String get jsonString => query;
  const UserOrder._default(this.query);
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
}

enum PopularTimeScale with ApiQueryParameter {
  day,
  week,
  month;

  @override
  String get query => name;
}
