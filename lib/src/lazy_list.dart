// import 'dart:collection';
// import 'dart:math';

// import 'package:flutter/foundation.dart';
// import 'package:j_util/src/types.dart' show LateFinal;

// import 'collection_extensions.dart';

/* mixin TaggedLazyIterable<T> on Iterable<T> implements TaggedIterable<T> {
  @override
  bool get isLazy => true;
  @override
  get iterator =>
      TaggedIteratorWrapper(isLazy: isLazy, wrapped: super.iterator);
}
mixin TaggedNonLazyIterable<T> on Iterable<T> implements TaggedIterable<T> {
  @override
  bool get isLazy => true;
  @override
  get iterator =>
      TaggedIteratorWrapper(isLazy: isLazy, wrapped: super.iterator);
}

abstract interface class TaggedIterable<T> implements Iterable<T> {
  bool get isLazy;
  @override
  TaggedIterator<T> get iterator;
}

abstract interface class TaggedIterator<T> implements Iterator<T> {
  bool get isLazy;
}

class TaggedIteratorWrapper<T> implements TaggedIterator<T> {
  @override
  final bool isLazy;
  final Iterator<T> wrapped;

  TaggedIteratorWrapper({required this.isLazy, required this.wrapped});

  @override
  // TODO: implement current
  T get current => wrapped.current;

  @override
  bool moveNext() => wrapped.moveNext();
}

class _TaggedCombinedIterator<T> implements TaggedIterator<T> {
  @override
  bool get isLazy =>
      _nextIterator.isLazy ||
      (!_currentIteratorDone && _currentIterator.isLazy);
  final TaggedIterator<T> _currentIterator;
  bool _currentIteratorDone = false;
  final TaggedIterator<T> _nextIterator;
  bool _nextIteratorDone = false;

  _TaggedCombinedIterator({
    required TaggedIterator<T> currentIterator,
    required TaggedIterator<T> nextIterator,
  })  : _currentIterator = currentIterator,
        _nextIterator = nextIterator;
  @override
  T get current =>
      _currentIteratorDone ? _currentIterator.current : _nextIterator.current;

  @override
  bool moveNext() {
    if (!_currentIteratorDone) {
      _currentIteratorDone = _currentIterator.moveNext();
    }
    if (_currentIteratorDone && !_nextIteratorDone) {
      _nextIteratorDone = _nextIterator.moveNext();
    }
    return _currentIteratorDone || _nextIteratorDone;
  }
} */

// abstract class _TaggedCombinedIterable<T> implements TaggedIterable<T> {
//   @override
//   bool get isLazy;
//   final List<TaggedIterable<T>> _iterables;

//   _TaggedCombinedIterable({required List<TaggedIterable<T>> iterables})
//       : _iterables = iterables;
// }

// typedef Precondition<T> = bool Function(LazyList<T>);
// typedef PreAdvance<T> = bool Function(int index, LazyList<T> lazyList);
// typedef PostAdvance<T> = bool Function(
//     T element, int index, LazyList<T> lazyList);

/* class LazyList<T> implements List<T>, TaggedIterable<T> {
  @override
  bool get isLazy => !isComplete;
  final Iterable<T> _lazyCollection;
  /* final  */ Iterator<T> _iterator;
  final List<T> _list;
  final int? projectedLength;

  @override
  // TODO: ensure performance
  TaggedIterator<T> get iterator {
    if (isComplete) {
      return TaggedIteratorWrapper(isLazy: false, wrapped: _list.iterator);
    }
    return _TaggedCombinedIterator(
        currentIterator:
            TaggedIteratorWrapper(isLazy: false, wrapped: _list.iterator),
        nextIterator: TaggedIteratorWrapper(
          isLazy: true,
          wrapped: _lazyCollection.iterateUntilTrueLazy(
              (accumulator, index, list, it) => (it, index + 1 == _list.length),
              null)!,
        ));
  }

  LazyList({
    required Iterable<T> lazyCollection,
    /* required Iterator<T> iterator, */
    this.projectedLength,
  })  : _lazyCollection = lazyCollection,
        _iterator = lazyCollection.iterator,
        _list = <T>[];

  /// The [iterator] must be at the last element of [preDoneElements].
  LazyList.partiallyDone({
    required Iterable<T> lazyCollection,
    required Iterator<T> iterator,
    required List<T> preDoneElements,
    this.projectedLength,
  })  : _lazyCollection = lazyCollection,
        _iterator = iterator,
        _list = preDoneElements; // ?? <T>[];
  int get count => _list.length;
  bool _isComplete = false;
  bool get isComplete => _isComplete;
  @override
  T get first => _list.firstOrNull ?? _advanceTo(0, false)!;

  @override
  set first(T value) {
    _advanceTo(0);
    _list.first = value;
  }

  /// {@template will}
  /// Will complete the iteration.
  /// {@endtemplate}
  ///
  /// The last element.
  ///
  /// Throws a [StateError] if this is empty. Otherwise may iterate through the elements and returns the last one seen. Some iterables may have more efficient ways to find the last element (for example a list can directly access the last element, without iterating through the previous ones).
  ///
  /// {@macro copy}
  @override
  T get last => _isComplete ? _list.last : complete();

  /// {@macro will}
  @override
  set last(T value) {
    if (!_isComplete) complete();
    _list.last = value;
  }

  /// {@macro will}
  T complete() {
    if (_isComplete) return _list.last;
    _advanceUntil(conditionPreAdvance: null);
    return _list.last;
  }

  /// {@template may}
  /// May complete the iteration.
  /// {@endtemplate}
  T? _advanceTo(int index, [bool failGracefully = false]) {
    if (count <= index) {
      _advanceUntil(
        conditionPreAdvance: (i, _) => i <= index,
        // precondition: (l) => l.count <= index,
      );
    }
    return !failGracefully || count > index ? _list[index] : null;
  }

  /// {@macro may}
  /* T */ void _advanceUntil({
    required PreAdvance<T>? conditionPreAdvance,
    PostAdvance<T>? conditionPostAdvance,
    // Precondition<T>? precondition,
  }) {
    if (/* precondition?.call(this) ?? true &&  */ !_isComplete) {
      for (var i = _list.length;
          (conditionPreAdvance?.call(i, this) ?? true) &&
              !(_isComplete = !_iterator.moveNext());
          i++) {
        _list.add(_iterator.current);
        if (!(conditionPostAdvance?.call(_iterator.current, i, this) ?? true)) {
          break;
        }
      }
    }
  }

  /// The number of objects in this list.
  ///
  /// The valid indices for a list are `0` through `length - 1`.
  ///
  /// ```
  /// final numbers = <int>[1, 2, 3];
  /// print(numbers.length); // 3
  /// ```
  /// {@template copy}
  ///
  /// Copied from `List`.
  ///
  /// {@endtemplate}
  ///
  /// {@macro will}
  /// This will essentially cause
  /// a decomposition to a normal [List]
  @override
  int get length => _isComplete
      ? _list.length
      : (() {
          complete();
          return _list.length;
        })();
  void _enforceCompletion() => (!_isComplete) ? complete() : "";

  /// {@macro will}
  @override
  set length(int newLength) {
    _enforceCompletion();
    _list.length = newLength;
  }

  /// TODO: Implement in a way that doesn't finish the iteration.
  ///
  /// {@macro will}
  ///
  /// Returns the concatenation of this list and [other].
  ///
  /// Returns a new list containing the elements of this list followed by the elements of [other].
  ///
  /// The default behavior is to return a normal growable list. Some list types may choose to return a list of the same type as themselves (see [Uint8List.+]);
  ///
  /// {@macro copy}
  @override
  List<T> operator +(List<T> other) {
    if (isComplete && other is! LazyList) return _list + other;
    if (isComplete && other is LazyList) {
      return LazyList.partiallyDone(
          lazyCollection: other,
          iterator: other.iterator,
          preDoneElements: _list);
    } else if (!isComplete) {
      // _iterator = _TaggedCombinedIterator(currentIterator: (TaggedIteratorWrapper(isLazy: true, wrapped: _iterator)), nextIterator: TaggedIteratorWrapper(wrapped: other.iterator, isLazy: false));
      _enforceCompletion();
      return _list + other;
    }
    _enforceCompletion();
    return _list + other;
  }

  /// The object at the given [index] in the list.
  ///
  /// The [index] must be a valid index of this list, which means that index must be non-negative and less than [length].
  ///
  /// {@macro copy}
  ///
  /// {@macro may}
  @override
  T operator [](int index) => _advanceTo(index)!;

  /// Sets the value at the given [index] in the list to [value].
  ///
  /// The [index] must be a valid index of this list, which means that index must be non-negative and less than [length].
  ///
  /// {@macro copy}
  ///
  /// {@macro may}
  @override
  void operator []=(int index, T value) {
    _advanceTo(index);
    _list[index] = value;
  }

  // TODO: Implement in a way that doesn't finish the iteration.
  @override
  void add(T value) {
    _enforceCompletion();
    _list.add(value);
  }

  // TODO: Implement in a way that doesn't finish the iteration.
  @override
  void addAll(Iterable<T> iterable) {
    _enforceCompletion();
    _list.addAll(iterable);
  }

  @override
  bool any(bool Function(T element) test) {
    _enforceCompletion();
    return _list.any(test);
  }

  @override
  Map<int, T> asMap() {
    _enforceCompletion();
    return _list.asMap();
  }

  @override
  List<R> cast<R>() {
    _enforceCompletion();
    return _list.cast<R>();
  }

  @override
  void clear() {
    _isComplete = true;
    _list.clear();
  }

  @override
  bool contains(Object? element) {
    var t = _list.contains(element);
    if (t) return t;
    while (!isComplete) {
      t = _advanceTo(count) == element;
      if (t) return t;
    }
    return t;
  }

  @override
  T elementAt(int index /* , [bool failGracefully = true] */) =>
      index < _list.length ? _list[index] : _advanceTo(index)!;

  @override
  bool every(bool Function(T element) test) {
    _enforceCompletion();
    return _list.every(test);
  }

  // TODO: Implement in a way that doesn't finish the iteration.
  @override
  Iterable<U> expand<U>(Iterable<U> Function(T element) toElements) {
    _enforceCompletion();
    return _list.expand(toElements);
  }

  @override
  void fillRange(int start, int end,
      [T? fillValue, bool failGracefully = true]) {
    if (fillValue == null && null is T) {
      throw ArgumentError.value(fillValue, "fillValue",
          "$T is not nullable, so a non-null value is required");
    }
    if (end <= start) {
      throw ArgumentError.value(
          "start($start) must be less than or equal to end ($end)");
    }
    if (start < 0) {
      throw ArgumentError.value(start, "start", "must be greater than 0");
    }
    _advanceTo(end + 1, failGracefully);
    if (end <= count) {
      _list.fillRange(start, end);
    } else {
      failGracefully
          ? _list.fillRange(start, count)
          : throw StateError("Not enough values");
    }
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    late T ret;
    bool wasSet = false;
    _advanceUntil(
        conditionPreAdvance: null,
        conditionPostAdvance: (element, index, lazyList) {
          if (test(element)) {
            ret = element;
            return wasSet = true;
          }
          return wasSet = false;
        });
    if (!wasSet) {
      return orElse?.call() ?? (throw StateError("test was never satisfied"));
    }
    return ret;
  }

  @override
  U fold<U>(U initialValue, U Function(U previousValue, T element) combine) {
    _enforceCompletion();
    return _list.fold(initialValue, combine);
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    // TODO: implement followedBy
    throw UnimplementedError();
  }

  @override
  void forEach(void Function(T element) action) {
    _enforceCompletion();
    _list.forEach(action);
  }

  @override
  Iterable<T> getRange(int start, int end) {
    // TODO: implement getRange
    throw UnimplementedError();
  }

  @override
  int indexOf(T element, [int start = 0]) {
    // TODO: implement indexOf
    throw UnimplementedError();
  }

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    // TODO: implement indexWhere
    throw UnimplementedError();
  }

  @override
  void insert(int index, T element) {
    // TODO: implement insert
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    // TODO: implement insertAll
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    // TODO: implement lastIndexOf
    throw UnimplementedError();
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    // TODO: implement lastIndexWhere
    throw UnimplementedError();
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  Iterable<U> map<U>(U Function(T e) toElement) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  bool remove(Object? value) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  T removeAt(int index) {
    // TODO: implement removeAt
    throw UnimplementedError();
  }

  @override
  T removeLast() {
    // TODO: implement removeLast
    throw UnimplementedError();
  }

  @override
  void removeRange(int start, int end) {
    // TODO: implement removeRange
  }

  @override
  void removeWhere(bool Function(T element) test) {
    // TODO: implement removeWhere
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) {
    // TODO: implement replaceRange
  }

  @override
  void retainWhere(bool Function(T element) test) {
    // TODO: implement retainWhere
  }

  @override
  // TODO: implement reversed
  Iterable<T> get reversed => throw UnimplementedError();

  @override
  void setAll(int index, Iterable<T> iterable) {
    // TODO: implement setAll
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    // TODO: implement setRange
  }

  @override
  void shuffle([Random? random]) {
    // TODO: implement shuffle
  }

  @override
  // TODO: implement single
  T get single => throw UnimplementedError();

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Iterable<T> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    // TODO: implement sort
  }

  @override
  List<T> sublist(int start, [int? end]) {
    // TODO: implement sublist
    throw UnimplementedError();
  }

  @override
  Iterable<T> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  List<T> toList({bool growable = true}) {
    _enforceCompletion();
    return _list.toList();
  }

  @override
  Set<T> toSet() {
    _enforceCompletion();
    return _list.toSet();
  }

  @override
  Iterable<T> where(bool Function(T element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  Iterable<U> whereType<U>() {
    // TODO: implement whereType
    throw UnimplementedError();
  }
} */
