import 'package:j_util/src/j_util_base.dart' show defaultIndent;
import 'package:j_util/src/types.dart' show Platform, TimeInterval;

// #region Numerics
extension NumExtensions on num {
  static int get maxInteger => Platform.isWeb
      ? double.maxFinite.toInt()
      : double.maxFinite.toInt() /* 0x7FFFFFFFFFFFFFFF */;
  static int get minInteger => Platform.isWeb
      ? -double.maxFinite.toInt()
      : -double.maxFinite.toInt() /* -0x8000000000000000 */;
  static const int maxPreciseWebInt = 0x20000000000000;

  /// Converts to a Duration assuming this number represents a number of milliseconds.
  Duration fromMillisecondsToDuration(
          {bool discardMicroseconds = true, bool representsSeconds = false}) =>
      discardMicroseconds
          ? Duration(
              milliseconds: (representsSeconds ? this * 1000 : this).truncate())
          : Duration(
              microseconds: (representsSeconds ? this * 1000000 : this * 1000)
                  .truncate());
  num removeMicroseconds({
    TimeInterval represents = TimeInterval.milliseconds,
  }) =>
      switch (represents) {
        TimeInterval.microseconds =>
          (this / Duration.microsecondsPerMillisecond).truncate() *
              Duration.microsecondsPerMillisecond,
        TimeInterval.milliseconds => truncate(),
        TimeInterval.seconds =>
          (this * Duration.millisecondsPerSecond).truncate() /
              Duration.millisecondsPerSecond,
        TimeInterval.minutes =>
          (this * Duration.millisecondsPerMinute).truncate() /
              Duration.millisecondsPerMinute,
        TimeInterval.hours => (this * Duration.millisecondsPerHour).truncate() /
            Duration.millisecondsPerHour,
        TimeInterval.days => (this * Duration.millisecondsPerDay).truncate() /
            Duration.millisecondsPerDay,
      };

  /// Converts to a Duration.
  Duration toDuration({
    bool discardMicroseconds = true,
    TimeInterval represents = TimeInterval.milliseconds,
  }) =>
      Duration(
          microseconds: (switch (represents) {
                    TimeInterval.microseconds => truncate(),
                    TimeInterval.milliseconds =>
                      (this * Duration.microsecondsPerMillisecond).truncate(),
                    TimeInterval.seconds =>
                      (this * Duration.microsecondsPerSecond).truncate(),
                    TimeInterval.minutes =>
                      (this * Duration.microsecondsPerMinute).truncate(),
                    TimeInterval.hours =>
                      (this * Duration.microsecondsPerHour).truncate(),
                    TimeInterval.days =>
                      (this * Duration.microsecondsPerDay).truncate(),
                  } *
                  (discardMicroseconds ? 1 / 1000 : 1))
              .truncate());

  String constructTimeStringFromInt(int time, {bool fillZeros = true}) =>
      Duration(milliseconds: time).toFormattedString(fillZeros: fillZeros);
}

extension DoubleExtensions on double {
  String toTimeString({
    TimeInterval represents = TimeInterval.seconds,
    bool discardMicroseconds = true,
    bool fillZeros = true,
  }) =>
      toDuration(
        represents: represents,
        discardMicroseconds: discardMicroseconds,
      ).toFormattedString(
        fillZeros: fillZeros,
        discardMicroseconds: discardMicroseconds,
      );
}

extension IntExtensions on int {
  String toTimeString({
    TimeInterval represents = TimeInterval.milliseconds,
    bool discardMicroseconds = true,
    bool fillZeros = true,
  }) =>
      toDuration(
        represents: represents,
        discardMicroseconds: discardMicroseconds,
      ).toFormattedString(
        fillZeros: fillZeros,
        discardMicroseconds: discardMicroseconds,
      );
}

extension DurationExtensions on Duration {
  static Duration get max =>
      const Duration(microseconds: NumExtensions.maxPreciseWebInt);
  static const Duration maxDuration =
      Duration(microseconds: NumExtensions.maxPreciseWebInt);
  static Duration fromJson(Map<String, dynamic> json) =>
      Duration(microseconds: json["_duration"] as int);
  int toInt() => inMilliseconds;
  double toDouble() => inMilliseconds.toDouble();
  Duration operator /(int rhs) => Duration(microseconds: inMicroseconds ~/ rhs);

  Map<String, dynamic> toJson() => <String, dynamic>{
        '_duration': inMicroseconds,
      };

  // TODO: Test
  String toFormattedString({
    bool fillZeros = true,
    bool discardMicroseconds = true,
    bool discardMilliseconds = true,
  }) {
    var t = toString();
    t = switch ((discardMilliseconds, discardMicroseconds)) {
      (true, _) => t.substring(0, t.length - 7),
      (_, true) => t.substring(0, t.length - 3),
      (_, false) => t,
    };
    if (!fillZeros) {
      return RegExpExt.removeZerosFromTime.allMatches(t).toList().reversed.fold(
            t,
            (accumulator, elem) => t.replaceRange(elem.start, elem.end, ""),
          );
    }
    return t;
  }
}

extension DateTimeExtensions on DateTime {
  // TODO: Implement formatting
  // String toIso8601Substring({
  //   bool includeYear = false,
  //   bool includeMonth = false,
  //   bool includeDay = false,
  //   bool includeHour = false,
  //   bool includeMinute = false,
  //   bool includeSecond = false,
  //   bool includeMillisecond = false,
  //   bool includeMicrosecond = false,
  //   bool forceIncludeMicrosecond = false,
  // }) {
  //   var t = toIso8601String();
  //   var start = 0, end = t.length;
  //   if (!includeYear) start = 5;
  //   if (!includeYear) start = 5;

  // }
  @Deprecated("Use toIso8601DateString instead")
  String toISO8601DateString() => toIso8601DateString();
  String toIso8601DateString() => toIso8601String().substring(0, 10);

  ///
  ///
  /// W for weekday, D for days, M for months, Y for years.
  ///
  /// Lowercase means textual representation (e.g. mmm -> May|Mar).
  ///
  /// A single char means discard trailing 0's (e.g. D -> 5|23).
  ///
  /// TODO: Test
  String toFormattedDateString({
    String format = "YYYY-MM-DD",
  }) {
    var t = toIso8601String().substring(0, 10);
    if (format == "YYYY-MM-DD") return t;
    format = format.replaceAll("YYYY", t.substring(0, 4));
    format = format.replaceAll("YY", t.substring(2, 4));
    format = format.replaceAll("MM", t.substring(5, 7));
    format = format.replaceAll("M", (t[5] == "0") ? t.substring(5, 7) : t[6]);
    for (var match in RegExp(r"m+").allMatches(format)) {
      var s = matchMonth(month), delta = match.end - match.start;
      s = s.length >= delta ? s.substring(0, delta) : s;
      format.replaceRange(match.start, match.end, s);
    }
    format = format.replaceAll("DD", t.substring(8, 10));
    format = format.replaceAll("D", (t[5] == "0") ? t.substring(8, 10) : t[9]);
    for (var match in RegExp(r"w+").allMatches(format)) {
      var s = matchMonth(month), delta = match.end - match.start;
      s = s.length >= delta ? s.substring(0, delta) : s;
      format.replaceRange(match.start, match.end, s);
    }
    return format;
  }

  static String matchMonth(int m) => switch (m) {
        DateTime.january => "January",
        DateTime.february => "February",
        DateTime.march => "March",
        DateTime.april => "April",
        DateTime.may => "May",
        DateTime.june => "June",
        DateTime.july => "July",
        DateTime.august => "August",
        DateTime.september => "September",
        DateTime.october => "October",
        DateTime.november => "November",
        DateTime.december => "December",
        _ => throw UnsupportedError("$m not supported"),
      };

  static String matchWeekday(int w) => switch (w) {
        DateTime.sunday => "Sunday",
        DateTime.monday => "Monday",
        DateTime.tuesday => "Tuesday",
        DateTime.wednesday => "Wednesday",
        DateTime.thursday => "Thursday",
        DateTime.friday => "Friday",
        DateTime.saturday => "Saturday",
        _ => throw UnsupportedError("$w not supported"),
      };
}
// #endregion Numerics

// #region Strings & Printing
extension StringExtensions on String {
  /// TODO: UNIMPLEMENTED
  String toConstantCase() {
    throw UnimplementedError("String.toConstantCase() not implemented");
  }

  String toSentenceCaseFromCamel() {
    var result = replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), r" ");
    var finalResult = result[0].toUpperCase() + result.substring(1);
    return finalResult;
  }

  String toSnakeCaseFromCamelCase() => RegExpExt.camelCase.allMatches(this).fold(
      "",
      (accumulator, elem) =>
          "$accumulator${(elem.group(1)?.toLowerCase() ?? "")}_${(elem.group(2)?.toLowerCase() ?? "")}${(elem.group(3)?.toLowerCase() ?? "")}");
  // /// Will throw an error if T doesn't have a `fromJson` named constructor.
  // T decodeRawJson<T>() => (T as dynamic).fromJson(json.decode(this));
}

extension PrettyPrint on Object? {
  String toStringPrettyPrinter({String indent = defaultIndent}) =>
      toString().replaceAll("\n", "\n$indent");
}

extension RegExpExt on RegExp {
  static RegExp get removeZerosFromTime => RegExp(
      r'(^0+:|^0+(?=[1-9]+:)|(?<=:)(?<!.*[1-9].*)0{2}:|(?<=:)(?<!.*[1-9].*)0{1}|(?<=\.\d*?[1-9]*?)(?<!\.)0+(?!\d+$))');

  /// If a match is found, matches the whole input in segments. Matches
  /// everything preceding the first uppercase letter (that isn't preceded
  /// by whitespace or an underscore `_`) to the second to last character
  /// before the next uppercase letter. To convert to `CONSTANT_CASE`, use
  /// [String.toUpperCase] on each group and prepend group 2 with `_`. To
  /// convert to `snake_case`, use [String.toLowerCase] on each group and
  /// prepend group 2 with `_`.
  ///
  /// e.g. `CamelCaseMeBro` -> match 1: `CamelCas` (group 1: `Camel`, 2: `C`, 3: `as`), match 2: `eM` (group 1: `e`, 2: `M`, 3: empty), match 3: `eBro` (group 1: `e`, 2: `B`, 3: `ro`)
  static RegExp get camelCase =>
      RegExp(r'((?:.*?[^_\s]))([A-Z])((?:.*?(?=.[A-Z]|[\s])))');

  /// Matches \*THIS_STUFF\*, captures THIS_STUFF in group 1
  static RegExp get asteriskBoundConstant =>
      RegExp(asteriskBoundConstantString);
  static const asteriskBoundConstantString =
      r'\*(' "$constantCaseString" r')\*';
  static const constantCaseString = r'[A-Z_]+';

  /// Matches \*THIS_STUFF\*, captures \*THIS_STUFF\* in group 1
  static RegExp get asteriskBoundConstantNameAndAsterisks =>
      RegExp(r'(\*(?:' '$constantCaseString' r')\*)');

  /// Matches the space between camel cased words (exempting the start of a
  /// string/line).
  static RegExp get camelCaseWordBorders => RegExp(r'(?<!^)(?=[A-Z])');
  // TODO: Deprecated; Remove

  // #region TODO: Deprecated; Remove
  /// A string containing all whitespace characters.
  ///
  /// {@template WhitespaceList}
  /// Contains:
  /// * Line Separator (LS, `\u2028`)
  /// * New Line/Line Feed (LF, `\n`)(U+000A)
  /// * Carriage Return (CR, `\r`)(U+000D)
  /// * Line Tabulation/Vertical Tab (VT, `\u000B`)
  /// * Form Feed (FF, `\f`)(U+000C)
  /// * Paragraph Separator/¶ (PS, `\u2029`)
  /// * Next Line (NEL, `\u0085`)
  /// * Space (SP, `\u0020`)
  /// * (Horizontal) Tab (`\t`, `\u0009`)
  /// {@endtemplate}
  ///
  /// The \s class seems to match all but Next Line (NEL, `\u0085`).
  @Deprecated(
      r"The `\s` class seems to match all but Next Line (NEL, `\u0085`). Therefore, this is being deprecated in favor of `\s` or, if necessary, `[\s\u0085]`.")
  static const whitespaceCharacters = r'\u2028\n\r\u000B\f\u2029\u0085 	';

  /// {@macro WhitespaceList}
  @Deprecated(
      r"The `\s` class seems to match all but Next Line (NEL, `\u0085`). Therefore, this is being deprecated in favor of `[\s]` or, if necessary, `[\s\u0085]`.")
  static const whitespacePattern = '[$whitespaceCharacters]';

  /// {@macro WhitespaceList}
  @Deprecated(
      r"The `\s` class seems to match all but Next Line (NEL, `\u0085`). Therefore, this is being deprecated in favor of `[\s]` or, if necessary, `[\s\u0085]`.")
  static RegExp get whitespace => RegExp(whitespacePattern);

  @Deprecated("This was made due to confusion over RegExp errors. Use the "
      "([a-z]+) pattern directly instead for better configurability. This is "
      "being deprecated to trim bloat.")
  static RegExp get lowercase => RegExp(r'([a-z]+)');
  @Deprecated(
      "This was made due to confusion over RegExp errors. Use the [a-z] pattern instead.")
  static const lowercaseLetters = "abcdefghijklmnopqrstuzwxyz";
  @Deprecated(
      "This was made due to confusion over RegExp errors. Use the [A-Z] pattern instead.")
  static const uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUZWXYZ";
  @Deprecated(
      "This was made due to confusion over RegExp errors. Use the [a-zA-Z] pattern instead.")
  static const letters = "$lowercaseLetters$uppercaseLetters";
  @Deprecated(
      "This was made due to confusion over RegExp errors. Use the [0-9] pattern instead.")
  static const numbers = "0123456789";
  @Deprecated(
      "This was made due to confusion over RegExp errors. Use the [a-zA-Z0-9] pattern instead.")
  static const alphanumericCharacters =
      "$lowercaseLetters$uppercaseLetters$numbers";
  // #endregion TODO: Deprecated; Remove
}

// extension RegExpMatchExt on RegExpMatch {
//   /// A convenience wrapper for [namedGroup].
//   String? tryNamedGroup(String name) =>
//       groupNames.contains(name) ? namedGroup(name) : null;
// }
// #endregion Strings & Printing
