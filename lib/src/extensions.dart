import 'dart:convert';

import 'package:j_util/src/j_util_base.dart';
import 'package:j_util/src/types.dart';

import 'collections.dart';

// #region Iterable
extension ListIterators<T> on List<T> {
  /// Unlike the built-in [List.map] this:
  /// 1. Completes synchronously
  /// 1. Allows the current index and the list as a whole to affect the outcome
  /// 1. Returns a [List] instead of an [Iterable]
  List<U> mapAsList<U>(
    U Function(T e, int index, List<T> list) mapper, [
    bool growable = true,
  ]) {
    // final r = <U>[];
    // for (int i = 0; i < length; i++) {
    //   r.add(mapper(this[i], i, this));
    // }
    // return r;
    return List<U>.generate(
      length,
      (index) => mapper(this[index], index, this),
      growable: growable,
    );
  }

  U reduceToType<U>(
      U Function(U accumulator, T elem, int index, List<T> list) reducer,
      U initialValue) {
    for (int i = 0; i < length; i++) {
      initialValue = reducer(initialValue, this[i], i, this);
    }
    return initialValue;
  }

  bool get isFixedLength {
    try {
      add(removeLast());
      return true;
    } catch (e) {
      return false;
    }
  }

  ///
  /// [failSilently] handles non-growable lists.
  ///
  /// If [mutate] and:
  ///
  /// * [failSilently] -> create new list, mutate this list and new list, return copy.
  /// * ![failSilently] -> don't create new list, mutate and return this list, no error handling.
  ///
  /// Else JS behavior; create new list, mutate only new list, return new list.
  List<T> filter(
    bool Function(T e, int i, List<T> l) compareFunction, {
    bool mutate = false,
    bool failSilently = false,
  }) {
    bool? isMutable;
    final r = mutate && !failSilently ? this : <T>[];
    for (int i = 0; i < length; i++) {
      if (compareFunction(this[i], i, this)) {
        mutate && !failSilently ? () : r.add(this[i]);
      } else if (mutate &&
          (!failSilently || (isMutable ??= this.isFixedLength))) {
        removeAt(i);
        i--;
      }
    }
    return r;
  }

  List<int> indicesWhere(
    Mapper<T, bool> condition, [
    int start = 0,
    int end = -1,
  ]) {
    if (end == -1) end = length;
    var r = <int>[];
    for (var i = start; i < length; i++) {
      if (condition(this[i], i, this)) r.add(i);
    }
    return r;
  }
}

extension Iterators<T> on Iterable<T> {
  List<U> mapAsList<U>(Mapper<T, U> mapper) {
    final r = <U>[];
    final iterator = this.iterator;
    for (int i = 0; i < length && iterator.moveNext(); i++) {
      r.add(mapper(iterator.current, i, this));
    }
    return r;
  }

  Iterable<U> mapTo<U>(Mapper<T, U> mapper) =>
      IterableInjector(baseIterable: this, mapper: mapper);

  U reduceToType<U>(
    Reducer<T, U> reducer,
    U initialValue, {
    ReduceConditional<T, U>? breakIfTrue,
  }) {
    final iterator = this.iterator;
    for (int i = 0; i < length && iterator.moveNext(); i++) {
      if (breakIfTrue?.call(initialValue, iterator.current, i, this) ?? false) {
        break;
      }
      initialValue = reducer(initialValue, iterator.current, i, this);
    }
    return initialValue;
  }

  U reduceUntilTrue<U>(
    ConditionalReducer<T, U> reducer,
    U initialValue,
  ) {
    final iterator = this.iterator;
    for (int i = 0; i < length && iterator.moveNext(); i++) {
      if (((initialValue, _) = reducer(initialValue, iterator.current, i, this))
          .$2) break;
    }
    return initialValue;
  }
}
// #endregion Iterable

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
        _ => throw UnsupportedError(
            "TimeInterval.${represents.name} not supported",
          ),
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
                    _ => throw UnsupportedError(
                        "TimeInterval.${represents.name} not supported",
                      ),
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
  }) {
    var t = toString();
    t = discardMicroseconds ? t.substring(0, t.length - 3) : t;
    if (!fillZeros) {
      return RegExpExt.removeZerosFromTime
          .allMatches(t)
          .toList()
          .reversed
          .reduceToType(
              (accumulator, elem, index, list) =>
                  t.replaceRange(elem.start, elem.end, ""),
              t);
    }
    return t;
  }
}

extension DateTimeExtensions on DateTime {
  // TODO: Implement formatting
  // String toISO8601Substring({
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
  String toISO8601DateString() => toIso8601String().substring(0, 10);

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

  String toSnakeCaseFromCamelCase() =>
      RegExpExt.camelCase.allMatches(this).reduceToType(
          (accumulator, elem, index, list) =>
              "$accumulator${(elem.group(1)?.toLowerCase() ?? "")}_${(elem.group(2)?.toLowerCase() ?? "")}${(elem.group(3)?.toLowerCase() ?? "")}",
          "");
  /// Will throw an error if T doesn't have a `fromJson` named constructor.
  T decodeRawJson<T>() => (T as dynamic).fromJson(json.decode(this));
}

extension PrettyPrint on Object? {
  String toStringPrettyPrinter({String indent = defaultIndent}) =>
      toString().replaceAll("\n", "\n$indent");
}

extension PrettyPrintCollection on Iterable {
  // TODO: Test
  String toStringIterable({
    String elementDelimiter = ", ",
    bool lineBreakCollectionStart = false,
    String indent = defaultIndent,
    PrettyPrintPrefixStyle prefixStyle =
        PrettyPrintPrefixStyle.applyPrefixToAllLinesButFirst,
    String prefix = "",
  }) =>
      "[${lineBreakCollectionStart ? "\n" : ""}${mapAsList((e, index, list) => "${switch (prefixStyle) {
            PrettyPrintPrefixStyle.doNotApplyPrefix => "",
            PrettyPrintPrefixStyle.applyPrefixToAllLines => prefix,
            PrettyPrintPrefixStyle.applyPrefixToAllLinesButFirst =>
              index != 0 ? prefix : "",
          }}${e.toString().replaceAll("\n", "\n$indent")}${index < list.length - 1 ? "$elementDelimiter${lineBreakCollectionStart && elementDelimiter.contains("\n") ? indent : ""}" : ""}").reduce((value, element) => value + element)}${lineBreakCollectionStart ? "\n" : ""}]";
}

extension RegExpExt on RegExp {
  static final whitespace = RegExp(r'[\u2028\n\r\u000B\f\u2029\u0085]');
  static final removeZerosFromTime = RegExp(
      r'(^0+:|^0+(?=[123456789]+:)|(?<=:)(?<!.*[123456789].*)0{2}:|(?<=:)(?<!.*[123456789].*)0{1}|(?<=\.\d*?[123456789]*?)(?<!\.)0+(?!\d+$))');

  /// If a match is found, matches the whole input in segments. Matches
  /// everything preceding the first uppercase letter (that isn't preceded
  /// by whitespace or an underscore `_`) to the second to last character
  /// before the next uppercase letter. To convert to `CONSTANT_CASE`, use
  /// [String.toUpperCase] on each group and prepend group 2 with `_`. To
  /// convert to `snake_case`, use [String.toLowerCase] on each group and
  /// prepend group 2 with `_`.
  ///
  /// e.g. `CamelCaseMeBro` -> match 1: `CamelCas` (group 1: `Camel`, 2: `C`, 3: `as`), match 2: `eM` (group 1: `e`, 2: `M`, 3: empty), match 3: `eBro` (group 1: `e`, 2: `B`, 3: `ro`)
  static final camelCase = RegExp(
      r'((?:.*?[^_\u2028\n\r\u000B\f\u2029\u0085]))([A-Z])((?:.*?(?=.[A-Z]|[\u2028\n\r\u000B\f\u2029\u0085])))');

  /// Matches \*THIS_STUFF\*, captures THIS_STUFF in group 1
  static final asteriskBoundConstant = RegExp(asteriskBoundConstantString);
  static const asteriskBoundConstantString =
      r'\*(' + constantCaseString + r')\*';
  static const constantCaseString = r'[A-Z_]+';

  /// Matches \*THIS_STUFF\*, captures \*THIS_STUFF\* in group 1
  static final asteriskBoundConstantNameAndAsterisks =
      RegExp(r'(\*(?:[A-Z_]+)\*)');

  /// Matches the space between camel cased words (exempting the start of a
  /// string/line).
  static final camelCaseWordBorders = RegExp(r'(?<!^)(?=[A-Z])');

  static final lowercase = RegExp(r'([a-z]+)');
}

// #endregion Strings & Printing
