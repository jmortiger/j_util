import 'package:j_util/j_util.dart' as util;
import 'package:j_util/src/extensions.dart';
import 'package:j_util/platform_finder.dart' as pf;

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

  IterableInjector(
      {required Iterable<From> baseIterable, required Mapper<From, To> mapper})
      : _baseIterable = baseIterable,
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

mixin PrettyPrintEnum on Enum {
  String get namePretty => name.toSentenceCaseFromCamel();
  String get nameUpper => name.toUpperCase();
  String get nameConstant => name.toConstantCase();
  String get nameSnake => name.toSnakeCaseFromCamelCase();
}

enum TimeInterval {
  microseconds,
  milliseconds,
  seconds,
  minutes,
  hours,
  days,
}

enum PrettyPrintPrefixStyle {
  doNotApplyPrefix,
  applyPrefixToAllLinesButFirst,
  applyPrefixToAllLines,
}

enum Platform {
  android,
  fuchsia,
  iOS,
  linux,
  macOS,
  windows,
  web,
  ;

  static Platform getPlatform() => pf.getPlatform();
  static final _platform = pf.getPlatform();
  static bool get isAndroid => _platform == Platform.android;
  static bool get isFuchsia => _platform == Platform.fuchsia;
  static bool get isIOS => _platform == Platform.iOS;
  static bool get isLinux => _platform == Platform.linux;
  static bool get isMacOS => _platform == Platform.macOS;
  static bool get isWindows => _platform == Platform.windows;
  static bool get isWeb => _platform == Platform.web;
}

/// Handles safely accessing and initializing an asynchronously created asset
/// that's otherwise constant.
///
/// TODO: Test
/// TODO: Extend with optional event-based assignment triggering.
class LazyInitializer<T> {
  final Future<T> Function() initializer;
  final T? defaultValue;

  /// The true item. Accessing before assignment will
  /// throw a [LateInitializationError].
  late final T _item;

  /// Accesses the true item. Accessing before assignment will
  /// throw a [LateInitializationError].
  T get item => _item;

  /// Synchronously accesses and returns the item, immediately
  /// asynchronously setting the item with [initializer] and
  /// returning [defaultValue] if that fails.
  T? get itemSafe {
    return _itemSafe() ??
        (() {
          initializer().then((value) => _item = value);
          return defaultValue;
        })();
  }

  LazyInitializer(this.initializer, {this.defaultValue});

  T? _itemSafe() {
    try {
      return _item;
    } catch (e) {
      return null;
    }
  }

  /// Synchronously accesses and returns the item, immediately asynchronously
  /// accessing and setting the item with [initializer] if that fails.
  Future<T> getItem() async => _itemSafe() ?? (_item = await initializer());
}

// TODO: Create a store that lazily converts an iterable to a list as it's iterated through.

///
///
/// TODO: Test
/// TODO: Extension w/ default val and initializer
class Late<T> {
  /// The true item. Accessing before assignment will
  /// throw a [LateInitializationError].
  late final T _item;

  bool _isAssigned = false;
  bool get isAssigned => _isAssigned;

  /// Accesses the true item. Accessing before assignment will
  /// throw a [LateInitializationError].
  T get item => _item;

  /// Sets the true item. Safely assigns the item once,
  /// gracefully fails afterwards.
  set item(T value) {
    if (!_isAssigned) {
      _item = value;
      _isAssigned = true;
    } else {} // TODO: Warn
  }

  T? get itemSafe => _isAssigned ? _item : null;

  T operator +(T value) {
    item = value;
    return item;
  }

  T? operator ~() {
    return itemSafe;
  }
}

/* ReturnType Function() */
class Generator<ReturnType, Signature extends Function> {
  final Signature generator;
  final ReturnType Function(Signature generatorFunction)? dispatcher;

  Generator({required this.generator, this.dispatcher});

  ReturnType generate(
          ReturnType Function(Signature generatorFunction)? dispatcher) =>
      (dispatcher ??
              this.dispatcher ??
              (throw ArgumentError.value(
                dispatcher,
                "dispatcher",
                "Both internal dispatcher and parameter "
                    "dispatcher are null; cannot fire generator: ",
              )))
          .call(generator);
}

// TODO: Finish
class StringFormatArchive {
  // final Set<String> templateParameters;
  // final List<String> fragments;
  // Set<String> getTemplateParameters(String s, RegExp? templateFormat) =>
  //     <String>{}..addAll((templateFormat ?? util.matchAsteriskBoundConstantName)
  //         .allMatches(s)
  //         .mapTo((elem, index, list) => elem.group(1) ?? ""));
  // List<String> getFragments(String s, RegExp? templateFormat) =>
  //     (templateFormat ?? util.matchAsteriskBoundConstantName)
  //         .allMatches(s)
  //         .mapAsList((elem, index, list) =>  elem.group(1) ?? "");
}

class PriorityQueue<T extends Comparable<T>>/*  extends Iterable<T> */ {
  // @override
  // // TODO: implement iterator
  // Iterator<T> get iterator => throw UnimplementedError();

  final List<List<T>> queue = [];

  PriorityQueue(List<T> collection) {
    // collection.sort(/* (a, b) => b.compareTo(a) */);
    // var queue = <List<T>>[];
    queue.add([collection.first]);
    for (var element in collection) {
      if (element == queue[0][0]) continue;
      var i = queue.length ~/ 2;
      var placed = false;
      // TODO: Show-off recursive skillz
      while (!placed) {
        var comp = queue[i][0].compareTo(element);
        switch (comp) {
          case < 0:
            if (i == 0) {
              queue.insert(i, [element]);
              placed = true;
            } else {
              i ~/= i;
            }
            break;
          case > 0:
            if (i == queue.length - 2) {
              i = queue.length - 1;
              break;
            } else if (i == queue.length - 1) {
              queue.add([element]);
              placed = true;
            } else {
              i = (i + queue.length /*  - 1 */) ~/ 2;
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
