import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:j_util/src/types.dart' show LateFinal;

typedef ReduceConditional<T, U> = bool Function(
    U accumulator, T elem, int index, Iterable<T> list);
typedef Reducer<T, U> = U Function(
    U accumulator, T elem, int index, Iterable<T> list);
typedef ConditionalReducer<T, U> = (U, bool) Function(
    U accumulator, T elem, int index, Iterable<T> list);
typedef Mapper<T, U> = U Function(T elem, int index, Iterable<T> list);
typedef MapperSparse<T, U> = U Function(T elem, Iterable<T> list);

class IterableInjector<From, To> extends Iterable<To> {
  final Iterable<From> _baseIterable;
  final Mapper<From, To> _mapper;

  IterableInjector({
    required Iterable<From> baseIterable,
    required Mapper<From, To> mapper,
  })  : _baseIterable = baseIterable,
        _mapper = mapper;
  @override
  Iterator<To> get iterator =>
      IteratorInjector(baseIterable: _baseIterable, mapper: _mapper);
}

class IteratorInjector<From, To> implements Iterator<To> {
  final Iterable<From> _baseIterable;
  Iterator<From>? _currentIteratorStore;
  Iterator<From> get _currentIterator =>
      _currentIteratorStore ??= _baseIterable.iterator;
  final Mapper<From, To> mapper;

  IteratorInjector({required Iterable<From> baseIterable, required this.mapper})
      : _baseIterable = baseIterable;
  int _index = -1;
  To? _current;
  @override
  To get current =>
      _current ??= mapper(_currentIterator.current, _index, _baseIterable);

  @override
  bool moveNext() {
    this._index++;
    return _currentIterator.moveNext();
  }
}

abstract interface class IComparable<T extends Comparable<T>>
    implements Comparable<T> {
  num get coarseness;
  @override
  int compareTo(T other, {num coarseness = double.nan});
  int compareToStrict(T other) => compareTo(other, coarseness: 0);
  static int compare(IComparable a, IComparable b) =>
      a.compareTo(b, coarseness: double.nan);
}

class CustomPriorityQueue<T> {
  late final List<T> queue; // = [];
  // final Late<List<T>> _queueToList = Late();
  // List<T> get squashedList => _queueToList.isAssigned
  //     ? _queueToList.item
  //     : (_queueToList.item = queue.fold(
  //         <T>[], (previousValue, element) => previousValue..addAll(element)));

  CustomPriorityQueue(
    List<T> collection,
    Comparator<T> comparator, [
    bool mutateProvided = false,
  ]) {
    queue = (mutateProvided ? collection : collection.sublist(0))
      ..sort(comparator);
    // // queue.add([collection.first]);
    // for (var element in collection) {
    //   if (element == queue[0][0]) continue;
    //   var i = queue.length ~/ 2;
    //   var placed = false;
    //   // TODO: Show-off recursive skills
    //   while (!placed) {
    //     var comp = element.compareTo(queue[i][0]);
    //     switch (comp) {
    //       case < 0:
    //         if (i == 0) {
    //           queue.insert(0, [element]);
    //           placed = true;
    //         } else {
    //           var compNext = element.compareTo(queue[i - 1][0]);
    //           if (compNext == 0) {
    //             queue[i - 1].add(element);
    //             placed = true;
    //           } else if (compNext > 0) {
    //             queue[i].add(element);
    //             placed = true;
    //           } else {
    //             i ~/= 2;
    //           }
    //         }
    //         break;
    //       case > 0:
    //         if (i == queue.length - 1) {
    //           queue.add([element]);
    //           placed = true;
    //         } else {
    //           var compNext = element.compareTo(queue[i + 1][0]);
    //           if (compNext == 0) {
    //             queue[i + 1].add(element);
    //             placed = true;
    //           } else if (compNext < 0) {
    //             queue[i].add(element);
    //             placed = true;
    //           } else if (i == queue.length - 2) {
    //             i = queue.length - 1;
    //             break;
    //           } else {
    //             i = (i + queue.length /*  - 1 */) ~/ 2;
    //           }
    //         }
    //         break;
    //       case == 0:
    //       default:
    //         queue[i].add(element);
    //         placed = true;
    //         break;
    //     }
    //   }
    // }
    // // this.queue = List.from(queue, growable: false);
  }
  // TODO: IMPLEMENT
  // static void getSortedByPriority<T>(List<T> collection) {
  //   collection
  // }
}

class PriorityQueue<T extends Comparable<T>> {
  late final List<T> queue; // = [];
  // final Late<List<T>> _queueToList = Late();
  // List<T> get squashedList => _queueToList.isAssigned
  //     ? _queueToList.item
  //     : (_queueToList.item = queue.fold(
  //         <T>[], (previousValue, element) => previousValue..addAll(element)));

  PriorityQueue(List<T> collection, [bool mutateProvided = false]) {
    queue = (mutateProvided ? collection : collection.sublist(0))..sort();
    // // queue.add([collection.first]);
    // for (var element in collection) {
    //   if (element == queue[0]) continue;
    //   this.insert(element);
    // }
    // // this.queue = List.from(queue, growable: false);
  }

  /// [indexBetween] is always greater than [indexOn] unless the desired index
  /// is past [start], in which case [indexOn] will be [start] and
  /// [indexBetween] will be [start] - 1. [indexOn] will always be a valid
  /// index in [collection], even before [indFound] is called and (potentially)
  /// modifies [collection]. If and only if the search wanted to expand past
  /// [end], the desired index will be [indexBetween], which will = [end], and
  /// [indexOn] will be [end] - 1, indicating the last valid index
  /// pre-[indFound] modification to [collection], and [indexBetween] indicates
  /// it wanted to expand beyond.
  static void _defaultInsertion<T>({
    required List<T> collection,
    required T item,
    required int index,
    int? indexBetween,
    int? start,
    int? end,
  }) {
    start ??= 0;
    end ??= collection.length;
    assert((indexBetween != null
            ? indexBetween != index &&
                (indexBetween > index || indexBetween <= start)
            : true) &&
        index >= start &&
        index < end);
    if (indexBetween == collection.length) {
      collection.add(item);
    } else {
      collection.insert(index, item);
    }
  }

  /// [indexBetween] is always greater than [indexOn] unless the desired index
  /// is past [start], in which case [indexOn] will be [start] and
  /// [indexBetween] will be [start] - 1. [indexOn] will always be a valid
  /// index in [collection], even before [indFound] is called and (potentially)
  /// modifies [collection]. If and only if the search wanted to expand past
  /// [end], the desired index will be [indexBetween], which will = [end], and
  /// [indexOn] will be [end] - 1, indicating the last valid index
  /// pre-[indFound] modification to [collection], and [indexBetween] indicates
  /// it wanted to expand beyond.
  static ({int indexOn, int? indexBetween})
      binarySearch<T extends Comparable<T>>({
    required List<T> collection,
    required T item,
    Function<T>({
      required List<T> collection,
      required T item,
      required int index,
      int? indexBetween,
      int? start,
      int? end,
    })? indFound,
    int start = 0,
    int? end,
  }) =>
          customBinarySearch(
            collection: collection,
            item: item,
            comparator: (a, b) => a.compareTo(b),
            indFound: indFound,
            start: start,
            end: end ?? collection.length,
          );

  /// [indexBetween] is always greater than [indexOn] unless the desired index
  /// is past [start], in which case [indexOn] will be [start] and
  /// [indexBetween] will be [start] - 1. [indexOn] will always be a valid
  /// index in [collection], even before [indFound] is called and (potentially)
  /// modifies [collection]. If and only if the search wanted to expand past
  /// [end], the desired index will be [indexBetween], which will = [end], and
  /// [indexOn] will be [end] - 1, indicating the last valid index
  /// pre-[indFound] modification to [collection], and [indexBetween] indicates
  /// it wanted to expand beyond.
  static ({int indexOn, int? indexBetween}) customBinarySearch<T>({
    required List<T> collection,
    required T item,
    Function<T>({
      required List<T> collection,
      required T item,
      required int index,
      int? indexBetween,
      int? start,
      int? end,
    })? indFound /*  = _defaultInsertion */,
    int start = 0,
    int? end,
    required Comparator<T> comparator,
  }) {
    end ??= collection.length;
    var i = end + start ~/ 2;
    var placed = false;
    // TODO: Show-off recursive skills
    while (!placed) {
      var comp = comparator(item, collection[i]);
      switch (comp) {
        case < 0:
          if (i == start) {
            indFound?.call(
              collection: collection,
              item: item,
              index: start,
              indexBetween: -1,
              start: start,
              end: end,
            );
            return (indexOn: start, indexBetween: -1);
          } else {
            var indNext = i - 1;
            switch (comparator(item, collection[indNext])) {
              case == 0:
                indFound?.call(
                  collection: collection,
                  item: item,
                  index: indNext,
                  start: start,
                  end: end,
                );
                return (indexOn: indNext, indexBetween: null);
              case > 0:
                indFound?.call(
                  collection: collection,
                  item: item,
                  index: i,
                  indexBetween: indNext,
                  start: start,
                  end: end,
                );
                return (indexOn: i, indexBetween: indNext);
              // case < 0:
              default:
                if (indNext == start) {
                  indFound?.call(
                    collection: collection,
                    item: item,
                    index: start,
                    indexBetween: -1,
                    start: start,
                    end: end,
                  );
                  return (indexOn: start, indexBetween: -1);
                }
                i = indNext ~/ 2;
                break;
            }
          }
          break;
        case > 0:
          if (i == end - 1) {
            indFound?.call(
              collection: collection,
              item: item,
              index: i,
              indexBetween: end,
              start: start,
              end: end,
            );
            return (indexOn: i, indexBetween: end);
          } else {
            var indNext = i + 1;
            switch (comparator(item, collection[indNext])) {
              case == 0:
                indFound?.call(
                  collection: collection,
                  item: item,
                  index: indNext,
                  start: start,
                  end: end,
                );
                return (indexOn: indNext, indexBetween: null);
              case < 0:
                indFound?.call(
                  collection: collection,
                  item: item,
                  index: i,
                  indexBetween: indNext,
                  start: start,
                  end: end,
                );
                return (indexOn: i, indexBetween: indNext);
              // case > 0:
              default:
                if (indNext == end - 1) {
                  indFound?.call(
                    collection: collection,
                    item: item,
                    index: indNext,
                    indexBetween: indNext + 1,
                    start: start,
                    end: end,
                  );
                  return (indexOn: indNext, indexBetween: indNext + 1);
                }
                i = (indNext + end) ~/ 2;
                break;
            }
          }
          break;
        // case == 0:
        default:
          indFound?.call(
            collection: collection,
            item: item,
            index: i,
            start: start,
            end: end,
          );
          return (indexOn: i, indexBetween: null);
      }
    }
  }

  // static int customInsertSortedList<T>({
  //   required List<T> collection,
  //   required List<T> items,
  //   Function<T>({
  //     required List<T> collection,
  //     required T item,
  //     required int index,
  //     int? indexBetween,
  //     int? start,
  //     int? end,
  //   })? indFound = _defaultInsertion,
  //   int start = 0,
  //   int? end,
  //   required Comparator<T> comparator,
  // }) {
  //   end ??= collection.length;
  //   if (end - start == 1) {
  //     return customInsertInto(
  //       collection: collection,
  //       item: items[start],
  //       comparator: comparator,
  //       end: end,
  //       start: start,
  //       indFound: indFound,
  //     );
  //   } else {
  //     var (indexOn:low, indexBetween:high) = customBinarySearch(
  //       collection: collection,
  //       item: collection.removeAt(end - 1),
  //       comparator: comparator,
  //       end: end,
  //       start: start,
  //       indFound: indFound,
  //     );
  //     // TODO: FINISH. Use start and end
  //   }
  //   binarySearch(
  //     collection: collection,
  //     item: items,
  //     start: start,
  //     end: end,
  //     indFound: indFound,
  //   );
  // }

  /// [indexBetween] is always greater than [index] unless the desired index
  /// is past [start], in which case [index] will be [start] and
  /// [indexBetween] will be [start] - 1. [index] will always be a valid
  /// index in [collection], even before [indFound] is called and (potentially)
  /// modifies [collection]. If and only if the search wanted to expand past
  /// [end], the desired index will be [indexBetween], which will = [end], and
  /// [index] will be [end] - 1, indicating the last valid index
  /// pre-[indFound] modification to [collection], and [indexBetween] indicates
  /// it wanted to expand beyond.
  static int insertInto<T extends Comparable<T>>({
    required List<T> collection,
    required T item,
    // Function<T>({
    //   required List<T> collection,
    //   required T item,
    //   required int index,
    //   int? indexBetween,
    //   int? start,
    //   int? end,
    // })? indFound/*  = _defaultInsertion */,
    int start = 0,
    int? end,
  }) =>
      customInsertInto(
        collection: collection,
        item: item,
        comparator: (a, b) => a.compareTo(b),
        indFound: _defaultInsertion,
        start: start,
        end: end ?? collection.length,
      );

  /// [indexBetween] is always greater than [index] unless the desired index
  /// is past [start], in which case [index] will be [start] and
  /// [indexBetween] will be [start] - 1. [index] will always be a valid
  /// index in [collection], even before [indFound] is called and (potentially)
  /// modifies [collection]. If and only if the search wanted to expand past
  /// [end], the desired index will be [indexBetween], which will = [end], and
  /// [index] will be [end] - 1, indicating the last valid index
  /// pre-[indFound] modification to [collection], and [indexBetween] indicates
  /// it wanted to expand beyond.
  static int customInsertInto<T>({
    required List<T> collection,
    required T item,
    Function<T>({
      required List<T> collection,
      required T item,
      required int index,
      int? indexBetween,
      int? start,
      int? end,
    })? indFound = _defaultInsertion,
    int start = 0,
    int? end,
    required Comparator<T> comparator,
  }) =>
      switch (customBinarySearch(
        collection: collection,
        item: item,
        comparator: comparator,
        indFound: indFound,
        start: start,
        end: end ?? collection.length,
      )) {
        // TODO: Does the first fire?
        (indexOn: int _, :int indexBetween)
            when indexBetween == (end ?? collection.length - 1) =>
          indexBetween,
        (indexOn: int _, :int? indexBetween)
            when indexBetween == (end ?? collection.length - 1) =>
          indexBetween!,
        (:int indexOn, indexBetween: int? _) => indexOn,
      };

  /// The return value will always a valid index in the post-insertion [collection].
  int insert(T element, {int start = 0, int? end}) => PriorityQueue.insertInto(
        collection: queue,
        item: element,
        start: start,
        end: end ?? queue.length,
      );
  // TODO: IMPLEMENT
  // static void getSortedByPriority<T>(List<T> collection) {
  //   collection
  // }
}

class _PriorityQueue<T extends Comparable<T>> /*  extends Iterable<T> */ {
  // @override
  // // TODO: implement iterator
  // Iterator<T> get iterator => throw UnimplementedError();

  final List<List<T>> queue = [];
  final LateFinal<List<T>> _queueToList = LateFinal();
  List<T> get squashedList => _queueToList.isAssigned
      ? _queueToList.$
      : (_queueToList.$ = queue.fold(
          <T>[], (previousValue, element) => previousValue..addAll(element)));

  _PriorityQueue(List<T> collection) {
    // collection.sort(/* (a, b) => b.compareTo(a) */);
    // var queue = <List<T>>[];
    queue.add([collection.first]);
    for (var element in collection) {
      if (element == queue[0][0]) continue;
      var i = queue.length ~/ 2;
      var placed = false;
      // TODO: Show-off recursive skills
      while (!placed) {
        var comp = element.compareTo(queue[i][0]);
        switch (comp) {
          case < 0:
            if (i == 0) {
              queue.insert(0, [element]);
              placed = true;
            } else {
              var compNext = element.compareTo(queue[i - 1][0]);
              if (compNext == 0) {
                queue[i - 1].add(element);
                placed = true;
              } else if (compNext > 0) {
                queue[i].add(element);
                placed = true;
              } else {
                i ~/= 2;
              }
            }
            break;
          case > 0:
            if (i == queue.length - 1) {
              queue.add([element]);
              placed = true;
            } else {
              var compNext = element.compareTo(queue[i + 1][0]);
              if (compNext == 0) {
                queue[i + 1].add(element);
                placed = true;
              } else if (compNext < 0) {
                queue[i].add(element);
                placed = true;
              } else if (i == queue.length - 2) {
                i = queue.length - 1;
                break;
              } else {
                i = (i + queue.length /*  - 1 */) ~/ 2;
              }
            }
            break;
          case == 0:
          default:
            queue[i].add(element);
            placed = true;
            break;
        }
      }
    }
    // this.queue = List.from(queue, growable: false);
  }
  // TODO: IMPLEMENT
  // static void getSortedByPriority<T>(List<T> collection) {
  //   collection
  // }
}

class CoarsePriorityQueue<T extends IComparable<T>>
    implements _PriorityQueue<T> {
  // CoarsePriorityQueue(super.collection);
  @override
  final List<List<T>> queue = [];
  @override
  final LateFinal<List<T>> _queueToList = LateFinal();
  @override
  List<T> get squashedList => _queueToList.isAssigned
      ? _queueToList.$
      : (_queueToList.$ = queue.fold(
          <T>[], (previousValue, element) => previousValue..addAll(element)));

  CoarsePriorityQueue(List<T> collection) /*  : super(collection) */ {
    // collection.sort(/* (a, b) => b.compareTo(a) */);
    // var queue = <List<T>>[];
    queue.add([collection.first]);
    for (var element in collection) {
      if (element == queue[0][0]) continue;
      var i = queue.length ~/ 2;
      var placed = false;
      // TODO: Show-off recursive skills
      while (!placed) {
        var comp = element.compareTo(queue[i][0]);
        switch (comp) {
          case < 0:
            if (i == 0) {
              queue.insert(0, [element]);
              placed = true;
            } else {
              var compNext = element.compareTo(queue[i - 1][0]);
              if (compNext == 0) {
                queue[i - 1].add(element);
                placed = true;
              } else if (compNext > 0) {
                queue[i].add(element);
                placed = true;
              } else {
                i ~/= 2;
              }
            }
            break;
          case > 0:
            if (i == queue.length - 1) {
              queue.add([element]);
              placed = true;
            } else {
              var compNext = element.compareTo(queue[i + 1][0]);
              if (compNext == 0) {
                queue[i + 1].add(element);
                placed = true;
              } else if (compNext < 0) {
                queue[i].add(element);
                placed = true;
              } else if (i == queue.length - 2) {
                i = queue.length - 1;
                break;
              } else {
                i = (i + queue.length /*  - 1 */) ~/ 2;
              }
            }
            break;
          case == 0:
          default:
            queue[i].add(element);
            placed = true;
            break;
        }
      }
    }
    // this.queue = List.from(queue, growable: false);
  }
  // TODO: IMPLEMENT
  // static void getSortedByPriority<T>(List<T> collection) {
  //   collection
  // }
}

class SetNotifier<T> extends ChangeNotifier with SetMixin<T> {
  final Set<T> _backing;

  /// Creates an empty Set.
  SetNotifier() : _backing = <T>{};

  /// Creates a Set that contains all elements.
  SetNotifier.from(Iterable elements) : _backing = Set.from(elements);

  /// Creates an empty identity Set.
  SetNotifier.identity() : _backing = Set.identity();

  /// Creates a Set from elements.
  SetNotifier.of(Iterable<T> elements) : _backing = Set.of(elements);

  /// Creates an unmodifiable Set from elements.
  SetNotifier.unmodifiable(Iterable<T> elements)
      : _backing = Set.unmodifiable(elements);
  @override
  bool add(T value, [bool notifyRegardless = false]) {
    var t = _backing.add(value);
    if (t || notifyRegardless) {
      notifyListeners();
    }
    return t;
  }

  @override
  bool contains(Object? element) => _backing.contains(element);

  @override
  void clear() {
    _backing.clear();
    notifyListeners();
  }

  @override
  Iterator<T> get iterator => _backing.iterator;

  @override
  int get length => _backing.length;

  @override
  T? lookup(Object? element) => _backing.lookup(element);

  @override
  bool remove(Object? value, [bool notifyRegardless = false]) {
    var t = _backing.remove(value);
    if (t || notifyRegardless) {
      notifyListeners();
    }
    return t;
  }

  @override
  Set<T> toSet() {
    return _backing.toSet();
  }
}

class ListNotifier<T> extends ChangeNotifier with ListMixin<T> {
  final List<T> _backing;

  ListNotifier() : _backing = <T>[];
  // ListNotifier.empty({bool growable = false}) : this.empty1(growable);
  ListNotifier.empty([bool growable = false])
      : _backing = List.empty(growable: growable);
  ListNotifier.filled(int length, T fill, [bool growable = false])
      : _backing = List.filled(length, fill, growable: growable);
  ListNotifier.from(Iterable<T> elements, [bool growable = true])
      : _backing = List.from(elements, growable: growable);
  ListNotifier.generate(int length, T Function(int) generator,
      [bool growable = true])
      : _backing = List.generate(length, generator, growable: growable);
  ListNotifier.of(Iterable<T> elements, [bool growable = true])
      : _backing = List.of(elements, growable: growable);

  @override
  int get length => _backing.length;
  @override
  set length(int v) {
    _backing.length = v;
    notifyListeners();
  }

  @override
  T operator [](int index) => _backing[index];

  @override
  void operator []=(int index, T value) {
    _backing[index] = value;
    notifyListeners();
  }

  /// Default requires nullable type
  @override
  void add(T element) {
    _backing.add(element);
  }
}

extension ListToNotifier<T> on List<T> {
  ListNotifier<T> toNotifier() => ListNotifier.of(this);
}

class MapNotifier<K, V> extends ChangeNotifier with MapMixin<K, V> {
  final Map<K, V> _map;

  MapNotifier() : _map = <K, V>{};
  MapNotifier.from(Map map) : _map = Map<K, V>.from(map);
  MapNotifier.fromEntries(Iterable<MapEntry<K, V>> entries)
      : _map = Map<K, V>.fromEntries(entries);
  MapNotifier.fromIterable(
    Iterable iterable, {
    K Function(dynamic element)? key,
    V Function(dynamic element)? value,
  }) : _map = Map<K, V>.fromIterable(iterable, key: key, value: value);
  MapNotifier.fromIterables(Iterable<K> keys, Iterable<V> values)
      : _map = Map<K, V>.fromIterables(keys, values);
  MapNotifier.identity() : _map = Map<K, V>.identity();
  MapNotifier.of(Map<K, V> map) : _map = Map<K, V>.of(map);
  MapNotifier.unmodifiable(Map map) : _map = Map<K, V>.unmodifiable(map);

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) {
    _map[key] = value;
    notifyListeners();
  }

  @override
  void clear() {
    _map.clear();
    notifyListeners();
  }

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key, [bool checkForKey = true]) {
    V? doIt() {
      final r = _map.remove(key);
      notifyListeners();
      return r;
    }

    if (checkForKey) {
      return _map.containsKey(key) ? doIt() : null;
    }
    return doIt();
  }
}

@Deprecated("Use Precondition")
typedef MyPrecondition<T> = Precondition<T>;
typedef Precondition<T> = bool Function(LazyList<T>);
@Deprecated("Use PreAdvance")
typedef MyPreAdvance<T> = PreAdvance<T>;
typedef PreAdvance<T> = bool Function(int index, LazyList<T> lazyList);
@Deprecated("Use PostAdvance")
typedef MyPostAdvance<T> = PostAdvance<T>;
typedef PostAdvance<T> = bool Function(
    T element, int index, LazyList<T> lazyList);

@Deprecated("Use LazyList")
typedef MyLazyList<T> = LazyList<T>;

class LazyList<T> with ListMixin<T> {
  LazyList({
    required Iterable<T> lazyCollection,
    /* required Iterator<T> iterator, */
    this.projectedLength,
  })  : //_lazyCollection = lazyCollection,
        _iterator = lazyCollection.iterator,
        _list = <T>[];

  /* /// The [iterator] must be at the last element of [preDoneElements].
  LazyList.partiallyDone({
    required Iterable<T> lazyCollection,
    required Iterator<T> iterator,
    required List<T> preDoneElements,
    this.projectedLength,
  })  : _lazyCollection = lazyCollection,
        _iterator = iterator,
        _list = preDoneElements; // ?? <T>[];

  final Iterable<T> _lazyCollection; */
  bool get isLazy => !isComplete;
  /* final  */ Iterator<T> _iterator;
  final List<T> _list;
  final int? projectedLength;
  bool _isComplete = false;
  bool get isComplete => _isComplete;
  int get count => _list.length;
  @override
  T get first => _list.firstOrNull ?? _advanceTo(0, false)!;

  @override
  set first(T value) {
    _advanceTo(0);
    _list.first = value;
  }

  /// {@macro will}
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

  /// {@macro may}
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
  /// {@macro copy}
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
}
