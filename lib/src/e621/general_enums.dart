import 'package:j_util/src/e621/search_enums.dart';

enum PoolCategory with ApiQueryParameter {
  collection,
  series;

  @override
  String get query => name;

  dynamic toJson() => name;
  static PoolCategory fromJson(dynamic json) => _fromJsonString(json);
  static PoolCategory fromJsonNonStrict(dynamic json) =>
      _fromJsonString(json.toString().toLowerCase());

  String toJsonString() => name;
  @Deprecated("Use PoolCategory.fromJson")
  static PoolCategory fromJsonString(String name) => _fromJsonString(name);
  static PoolCategory _fromJsonString(String name) => switch (name) {
        "collection" => collection,
        "series" => series,
        _ => throw UnsupportedError(
            "Value $name not supported, must be `collection` or `series`.",
          ),
      };
  @Deprecated("Use PoolCategory.fromJsonNonStrict")
  static PoolCategory fromJsonStringNonStrict(String name) =>
      _fromJsonString(name.toLowerCase());
  String toParamString() => name;
  static PoolCategory fromParamString(String name) => _fromJsonString(name);
}
