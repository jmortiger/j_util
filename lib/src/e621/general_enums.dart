mixin ApiQueryParameter on Enum {
  String get query;
}

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
