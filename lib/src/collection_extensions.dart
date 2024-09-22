import 'package:j_util/src/collections.dart';
import 'package:j_util/src/j_util_base.dart' show defaultIndent;
import 'package:j_util/src/types.dart' show PrettyPrintPrefixStyle;

// #region From j_util/src/extensions.dart
extension ListIterators<T> on List<T> {
  /// Unlike the built-in [List.map] this:
  /// 1. Completes synchronously
  /// 1. Allows the current index and the list as a whole to affect the outcome
  /// 1. Returns a [List] instead of an [Iterable]
  List<U> mapAsList<U>(
    U Function(T e, int index, List<T> list) mapper, {
    bool growable = true,
  }) =>
      List<U>.generate(
        length,
        (index) => mapper(this[index], index, this),
        growable: growable,
      );

  void mutate(
    T Function(T e, int i, List<T> l) mapper, [
    bool growable = true,
  ]) {
    for (int i = 0; i < length; i++) {
      this[i] = mapper(this[i], i, this);
    }
    // return this;
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

  /// [failSilently] handles non-growable lists.
  ///
  /// If [mutate] and:
  ///
  /// * [failSilently] -> create new list, mutate this list and new list, return copy.
  /// * ![failSilently] -> don't create new list, mutate and return this list, no error handling.
  ///
  /// Else JS behavior; create new list, mutate only new list, return new list.
  @Deprecated("whereList better fits naming conventions.")
  List<T> filter(
    bool Function(T e, int i, List<T> l) compareFunction, {
    bool mutate = false,
    bool failSilently = false,
  }) =>
      whereList(compareFunction, mutate: mutate, failSilently: failSilently);

  /// [failSilently] handles non-growable lists.
  ///
  /// If [mutate] and:
  ///
  /// * [failSilently] -> create new list, mutate this list and new list, return copy.
  /// * ![failSilently] -> don't create new list, mutate and return this list, no error handling.
  ///
  /// Else JS behavior; create new list, mutate only new list, return new list.
  List<T> whereList(
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

extension Iterators<E> on Iterable<E> {
  /// Unlike the built-in [Iterable.map] this:
  /// 1. Completes synchronously
  /// 1. Allows the current index and the list as a whole to affect the outcome
  /// 1. Returns a [List] instead of an [Iterable]
  /// 1. Allows execution to be short-circuited.
  List<U> mapAsList<U>(
    Mapper<E, U> mapper, {
    bool growable = true,
  }) =>
      List<U>.generate(
        length,
        (index) => mapper(elementAt(index), index, this),
        growable: growable,
      );

  /// Unlike the built-in [Iterable.map] this:
  /// 1. Completes synchronously
  /// 1. Allows the current index and the iterable as a whole to affect the outcome
  /// 1. Returns a [List] instead of an [Iterable]
  /// 1. Allows execution to be short-circuited.
  List<U> mapFull<U>(
    Mapper<E, U> mapper, {
    Mapper<E, bool>? breakIfTrue,
  }) {
    final r = <U>[];
    final iterator = this.iterator;
    for (int i = 0;
        i < length &&
            iterator.moveNext() &&
            (breakIfTrue?.call(iterator.current, i, this) ?? true);
        i++) {
      r.add(mapper(iterator.current, i, this));
    }
    return r;
  }

  /// Lazy equivalent to [mapAsList].
  Iterable<U> mapTo<U>(Mapper<E, U> mapper) =>
      IterableInjector(baseIterable: this, mapper: mapper);
  @Deprecated("Use foldTo; better matches naming conventions")
  U reduceToType<U>(
    Reducer<E, U> reducer,
    U initialValue, {
    ReduceConditional<E, U>? breakIfTrue,
  }) =>
      foldTo(initialValue, reducer, breakIfTrue: breakIfTrue);

  /// Analog for [fold] with ability to short-circuit execution and depend on
  /// the index and the iterable.
  U foldTo<U>(
    U initialValue,
    Reducer<E, U> combine, {
    ReduceConditional<E, U>? breakIfTrue,
  }) {
    final iterator = this.iterator;
    for (int i = 0; i < length && iterator.moveNext(); i++) {
      if (breakIfTrue?.call(initialValue, iterator.current, i, this) ?? false) {
        break;
      }
      initialValue = combine(initialValue, iterator.current, i, this);
    }
    return initialValue;
  }

  U reduceUntilTrue<U>(
    ConditionalReducer<E, U> reducer,
    U initialValue,
  ) {
    final iterator = this.iterator;
    for (int i = 0; i < length && iterator.moveNext(); i++) {
      if (((initialValue, _) = reducer(initialValue, iterator.current, i, this))
          .$2) break;
    }
    return initialValue;
  }

  U iterateUntilTrueLazy<U>(
    (U, bool) Function(
            U accumulator, int index, Iterable<E> list, Iterator<E> iterator)
        reducer,
    U initialValue,
  ) {
    final iterator = this.iterator;
    for (int i = 0; i < length && iterator.moveNext(); i++) {
      if (((initialValue, _) = reducer(initialValue, i, this, iterator)).$2) {
        break;
      }
    }
    return initialValue;
  }

  Iterable<E> whereFull(bool Function(E e, int i, Iterable<E> l) test) =>
      FilterIterableInjector(baseIterable: this, mapper: test);
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

// #endregion From j_util/src/extensions.dart
extension StringFold on Iterable<String> {
  // TODO: Profile performance.
  /// String folding w/o leading nor trailing [delimiter] and the prefix [prefix], and discarding empty strings if [excludeEmpty] is true.
  String foldToStringFull({
    String delimiter = " ",
    String prefix = "",
    bool excludeEmpty = false,
  }) =>
      fold(
          "",
          (acc, e) => !excludeEmpty || e.isNotEmpty
              ? (acc.isNotEmpty ? "$acc$delimiter$prefix$e" : "$prefix$e")
              : acc);

  /// String folding w/o leading nor trailing [delimiter] and the prefix [prefix]
  String foldToString({String delimiter = " ", String prefix = ""}) => fold(
      "", (acc, e) => acc.isNotEmpty ? "$acc$delimiter$prefix$e" : "$prefix$e");
  // String foldToString1({String delimiter = " ", String prefix = ""}) =>
  //     skip(1).fold("$prefix${elementAtOrNull(0) ?? ""}",
  //         (acc, e) => "$acc$delimiter$prefix$e");
  // fold("", (acc, e) => "$acc$delimiter$e");
  /// String folding w/o leading nor trailing [delimiter] and the prefix [prefix]
  // String foldToStringWithPrefix({String delimiter = " ", String prefix = ""}) =>
  //     fold("", (acc, e) => acc.isNotEmpty ? "$acc$delimiter$prefix$e" : "$prefix$e");
}
