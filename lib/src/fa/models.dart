import 'dart:convert';

class Post {
  final int id;
  final String title;
  final Author author;
  final DateTime date;
  final List<String> tags;
  final String category;
  final String species;
  final String gender;
  final String rating;
  final String type;
  final Stats stats;
  final String description;
  final String footer;
  final List<String> mentions;
  final String folder;
  final List<UserFolder> userFolders;
  final String fileUrl;
  final String thumbnailUrl;
  final List<Comment> comments;
  final int prev;
  final int next;
  final bool favorite;
  final String favoriteToggleLink;

  Post({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.tags,
    required this.category,
    required this.species,
    required this.gender,
    required this.rating,
    required this.type,
    required this.stats,
    required this.description,
    required this.footer,
    required this.mentions,
    required this.folder,
    required this.userFolders,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.comments,
    required this.prev,
    required this.next,
    required this.favorite,
    required this.favoriteToggleLink,
  });

  Post copyWith({
    int? id,
    String? title,
    Author? author,
    DateTime? date,
    List<String>? tags,
    String? category,
    String? species,
    String? gender,
    String? rating,
    String? type,
    Stats? stats,
    String? description,
    String? footer,
    List<String>? mentions,
    String? folder,
    List<UserFolder>? userFolders,
    String? fileUrl,
    String? thumbnailUrl,
    List<Comment>? comments,
    int? prev,
    int? next,
    bool? favorite,
    String? favoriteToggleLink,
  }) =>
      Post(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        date: date ?? this.date,
        tags: tags ?? this.tags,
        category: category ?? this.category,
        species: species ?? this.species,
        gender: gender ?? this.gender,
        rating: rating ?? this.rating,
        type: type ?? this.type,
        stats: stats ?? this.stats,
        description: description ?? this.description,
        footer: footer ?? this.footer,
        mentions: mentions ?? this.mentions,
        folder: folder ?? this.folder,
        userFolders: userFolders ?? this.userFolders,
        fileUrl: fileUrl ?? this.fileUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        comments: comments ?? this.comments,
        prev: prev ?? this.prev,
        next: next ?? this.next,
        favorite: favorite ?? this.favorite,
        favoriteToggleLink: favoriteToggleLink ?? this.favoriteToggleLink,
      );

  factory Post.fromRawJson(String str) => Post.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        title: json["title"],
        author: Author.fromJson(json["author"]),
        date: DateTime.parse(json["date"]),
        tags: List<String>.from(json["tags"].map((x) => x)),
        category: json["category"],
        species: json["species"],
        gender: json["gender"],
        rating: json["rating"],
        type: json["type"],
        stats: Stats.fromJson(json["stats"]),
        description: json["description"],
        footer: json["footer"],
        mentions: List<String>.from(json["mentions"].map((x) => x)),
        folder: json["folder"],
        userFolders: List<UserFolder>.from(
            json["user_folders"].map((x) => UserFolder.fromJson(x))),
        fileUrl: json["file_url"],
        thumbnailUrl: json["thumbnail_url"],
        comments: List<Comment>.from(
            json["comments"].map((x) => Comment.fromJson(x))),
        prev: json["prev"],
        next: json["next"],
        favorite: json["favorite"],
        favoriteToggleLink: json["favorite_toggle_link"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "author": author.toJson(),
        "date": date.toIso8601String(),
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "category": category,
        "species": species,
        "gender": gender,
        "rating": rating,
        "type": type,
        "stats": stats.toJson(),
        "description": description,
        "footer": footer,
        "mentions": List<dynamic>.from(mentions.map((x) => x)),
        "folder": folder,
        "user_folders": List<dynamic>.from(userFolders.map((x) => x.toJson())),
        "file_url": fileUrl,
        "thumbnail_url": thumbnailUrl,
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
        "prev": prev,
        "next": next,
        "favorite": favorite,
        "favorite_toggle_link": favoriteToggleLink,
      };
}

class Author {
  final String name;
  final String status;
  final String title;
  final String avatarUrl;
  final DateTime joinDate;

  Author({
    required this.name,
    required this.status,
    required this.title,
    required this.avatarUrl,
    required this.joinDate,
  });

  Author copyWith({
    String? name,
    String? status,
    String? title,
    String? avatarUrl,
    DateTime? joinDate,
  }) =>
      Author(
        name: name ?? this.name,
        status: status ?? this.status,
        title: title ?? this.title,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        joinDate: joinDate ?? this.joinDate,
      );

  factory Author.fromRawJson(String str) => Author.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        name: json["name"],
        status: json["status"],
        title: json["title"],
        avatarUrl: json["avatar_url"],
        joinDate: DateTime.parse(json["join_date"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
        "title": title,
        "avatar_url": avatarUrl,
        "join_date": joinDate.toIso8601String(),
      };
}

class Comment {
  final int id;
  final Author author;
  final DateTime date;
  final String text;
  final List<String> replies;
  final int replyTo;
  final bool edited;
  final bool hidden;

  Comment({
    required this.id,
    required this.author,
    required this.date,
    required this.text,
    required this.replies,
    required this.replyTo,
    required this.edited,
    required this.hidden,
  });

  Comment copyWith({
    int? id,
    Author? author,
    DateTime? date,
    String? text,
    List<String>? replies,
    int? replyTo,
    bool? edited,
    bool? hidden,
  }) =>
      Comment(
        id: id ?? this.id,
        author: author ?? this.author,
        date: date ?? this.date,
        text: text ?? this.text,
        replies: replies ?? this.replies,
        replyTo: replyTo ?? this.replyTo,
        edited: edited ?? this.edited,
        hidden: hidden ?? this.hidden,
      );

  factory Comment.fromRawJson(String str) => Comment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        author: Author.fromJson(json["author"]),
        date: DateTime.parse(json["date"]),
        text: json["text"],
        replies: List<String>.from(json["replies"].map((x) => x)),
        replyTo: json["reply_to"],
        edited: json["edited"],
        hidden: json["hidden"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "author": author.toJson(),
        "date": date.toIso8601String(),
        "text": text,
        "replies": List<dynamic>.from(replies.map((x) => x)),
        "reply_to": replyTo,
        "edited": edited,
        "hidden": hidden,
      };
}

class Stats {
  final int views;
  final int comments;
  final int favorites;

  Stats({
    required this.views,
    required this.comments,
    required this.favorites,
  });

  Stats copyWith({
    int? views,
    int? comments,
    int? favorites,
  }) =>
      Stats(
        views: views ?? this.views,
        comments: comments ?? this.comments,
        favorites: favorites ?? this.favorites,
      );

  factory Stats.fromRawJson(String str) => Stats.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        views: json["views"],
        comments: json["comments"],
        favorites: json["favorites"],
      );

  Map<String, dynamic> toJson() => {
        "views": views,
        "comments": comments,
        "favorites": favorites,
      };
}

class UserFolder {
  final String name;
  final String url;
  final String group;

  UserFolder({
    required this.name,
    required this.url,
    required this.group,
  });

  UserFolder copyWith({
    String? name,
    String? url,
    String? group,
  }) =>
      UserFolder(
        name: name ?? this.name,
        url: url ?? this.url,
        group: group ?? this.group,
      );

  factory UserFolder.fromRawJson(String str) =>
      UserFolder.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserFolder.fromJson(Map<String, dynamic> json) => UserFolder(
        name: json["name"],
        url: json["url"],
        group: json["group"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
        "group": group,
      };
}

class ErrorResponse {
  final String detail;

  ErrorResponse({required this.detail});
  ErrorResponse copyWith({
    String? detail,
  }) =>
      ErrorResponse(
        detail: detail ?? this.detail,
      );

  factory ErrorResponse.fromRawJson(String str) =>
      ErrorResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        detail: json["detail"],
      );

  Map<String, dynamic> toJson() => {
        "detail": detail,
      };
}

/// 422 `/submission/{submission_id}/`
class ValidationError {
  final List<Detail> detail;

  ValidationError({
    required this.detail,
  });

  ValidationError copyWith({
    List<Detail>? detail,
  }) =>
      ValidationError(
        detail: detail ?? this.detail,
      );

  factory ValidationError.fromRawJson(String str) =>
      ValidationError.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      ValidationError(
        detail:
            List<Detail>.from(json["detail"].map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "detail": List<dynamic>.from(detail.map((x) => x.toJson())),
      };
}

class Detail {
  final List<dynamic> loc;
  final String msg;
  final String type;

  Detail({
    required this.loc,
    required this.msg,
    required this.type,
  });

  Detail copyWith({
    List<dynamic>? loc,
    String? msg,
    String? type,
  }) =>
      Detail(
        loc: loc ?? this.loc,
        msg: msg ?? this.msg,
        type: type ?? this.type,
      );

  factory Detail.fromRawJson(String str) => Detail.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        loc: List<dynamic>.from(json["loc"].map((x) => x)),
        msg: json["msg"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "loc": List<dynamic>.from(loc.map((x) => x)),
        "msg": msg,
        "type": type,
      };
}
