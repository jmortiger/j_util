import 'package:j_util/src/j_util_base.dart';
import 'package:j_util/src/types.dart';

// #region Iterable
extension ListIterators<T> on List<T> {
  List<U> mapAsList<U>(U Function(T e, int index, List<T> list) mapper) {
    final r = <U>[];
    for (int i = 0; i < length; i++) {
      r.add(mapper(this[i], i, this));
    }
    return r;
  }

  List<T> addChain(T item) {
    add(item);
    return this;
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
  List<T> filter(bool Function(T e, int i, List<T> l) compareFunction,
      {bool mutate = false, bool failSilently = false}) {
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
  static int get maxInteger =>
      Platform.isWeb ? double.maxFinite.toInt() : 0x7FFFFFFFFFFFFFFF;
  static int get minInteger =>
      Platform.isWeb ? -double.maxFinite.toInt() : -0x8000000000000000;
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
        _ => throw UnsupportedError("type not supported"),
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
                    _ => throw UnsupportedError("type not supported"),
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
      return removeZerosFromTimeString
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

  String toSnakeCaseFromCamelCase() => matchSnakeCase.allMatches(this).reduceToType(
      (accumulator, elem, index, list) =>
          "$accumulator${(elem.group(1)?.toLowerCase() ?? "")}_${(elem.group(2)?.toLowerCase() ?? "")}${(elem.group(3)?.toLowerCase() ?? "")}",
      "");
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

// #endregion Strings & Printing