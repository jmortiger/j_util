import 'dart:async';

import 'package:j_util/j_util.dart' as util;
import 'package:j_util/src/extensions.dart';
import 'package:j_util/platform_finder.dart' as pf;

typedef VoidFunction = void Function();

mixin PrettyPrintEnum on Enum {
  /// Camel case to sentence formatting; `lowerCamelCase` -> Lower Camel Case
  String get namePretty => name.toSentenceCaseFromCamel();

  /// Capitalize everything; just it's `name.toUpperCase()`
  String get nameUpper => name.toUpperCase();

  /// TODO: UNIMPLEMENTED
  String get nameConstant => name.toConstantCase();
  String get nameSnake => name.toSnakeCaseFromCamelCase();
}

/// TODO: Make BitFlag enums easier
// mixin Flag<T extends Enum> on Enum {
//   Map<T, int> get flagMap;
//   static const int pendingFlag = 1; //int.parse("000001", radix: 2);
//   static const int flaggedFlag = 2; //int.parse("000010", radix: 2);
//   static const int noteLockedFlag = 4; //int.parse("000100", radix: 2);
//   static const int statusLockedFlag = 8; //int.parse("001000", radix: 2);
//   static const int ratingLockedFlag = 16; //int.parse("010000", radix: 2);
//   static const int deletedFlag = 32; //int.parse("100000", radix: 2);
//   int getFlag(T f);
//   bool hasFlag(int f) =>
//       (PostFlags.getFlag(this) & f) == PostFlags.getFlag(this);
// }
// TEMPLATE
// enum PostFlags {
//   /// int.parse("000001", radix: 2);
//   pending(bit: 1),

//   /// int.parse("000010", radix: 2);
//   flagged(bit: 2),

//   /// int.parse("000100", radix: 2);
//   noteLocked(bit: 4),

//   /// int.parse("001000", radix: 2);
//   statusLocked(bit: 8),

//   /// int.parse("010000", radix: 2);
//   ratingLocked(bit: 16),

//   /// int.parse("100000", radix: 2);
//   deleted(bit: 32);

//   final int bit;
//   const PostFlags({required this.bit});

//   /// int.parse("000001", radix: 2);
//   static const int pendingFlag = 1;

//   /// int.parse("000010", radix: 2);
//   static const int flaggedFlag = 2;

//   /// int.parse("000100", radix: 2);
//   static const int noteLockedFlag = 4;

//   /// int.parse("001000", radix: 2);
//   static const int statusLockedFlag = 8;

//   /// int.parse("010000", radix: 2);
//   static const int ratingLockedFlag = 16;

//   /// int.parse("100000", radix: 2);
//   static const int deletedFlag = 32;
//   static int toInt(PostFlags f) => f.bit;
//   static List<PostFlags> getFlags(int f) {
//     var l = <PostFlags>[];
//     if (f & pending.bit == pending.bit) l.add(pending);
//     if (f & flagged.bit == flagged.bit) l.add(flagged);
//     if (f & noteLocked.bit == noteLocked.bit) l.add(noteLocked);
//     if (f & statusLocked.bit == statusLocked.bit) l.add(statusLocked);
//     if (f & ratingLocked.bit == ratingLocked.bit) l.add(ratingLocked);
//     if (f & deleted.bit == deleted.bit) l.add(deleted);
//     return l;
//   }

//   bool hasFlag(int f) => (PostFlags.toInt(this) & f) == PostFlags.toInt(this);
// }

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
  static bool get isDesktop => switch (_platform) {
        android || fuchsia || iOS => false,
        linux || macOS || windows || web => true,
      };
  static bool get isDesktopNative => switch (_platform) {
        android || fuchsia || iOS || web => false,
        linux || macOS || windows => true,
      };
}

/// Handles safely accessing and initializing an asynchronously created asset
/// that's otherwise constant.
///
/// As this doesn't check to prevent the initializer from running multiple times,
/// this is unsuited for time-consuming operations or frequently-checked
/// variables. For those cases, use [LazyInitializer] instead. This has a slight
/// boost to performance.
///
/// TODO: Test cases
/// TODO: Extend with optional event-based assignment triggering.
@Deprecated("Use LazySingleInitializer")
class LazyUnsafeInitializer<T> {
  final Future<T> Function() initializer;
  final T? defaultValue;

  bool _isAssigned = false;
  bool get isAssigned => _isAssigned;

  /// The true item.
  /// {@template lateError}
  /// Accessing before assignment will throw a [LateInitializationError].
  /// {@endtemplate}
  late final T _item;

  /// Accesses the true item.
  /// {@macro lateError}
  @Deprecated(r"Use $")
  T get item => _item;

  /// Accesses the true item.
  /// {@macro lateError}
  T get $ => _item;

  /// Synchronously accesses and returns the item, immediately
  /// asynchronously setting the item with [initializer] and
  /// returning [defaultValue] if that fails.
  @Deprecated(r"Use $Safe")
  T? get itemSafe => $Safe;

  /// Synchronously accesses and returns the item, immediately
  /// asynchronously setting the item with [initializer] and
  /// returning [defaultValue] if that fails.
  T? get $Safe {
    return _isAssigned
        ? _item
        : (() {
            initializer().then((value) {
              if (!_isAssigned) {
                _isAssigned = true;
                _item = value;
              } else {
                print(
                  "LazyUnsafeInitializer<$T> was initialized before initializer completed.",
                );
              }
            }).ignore();
            return defaultValue;
          })();
  }

  LazyUnsafeInitializer(this.initializer, {this.defaultValue});
  LazyUnsafeInitializer.immediate(this.initializer, {this.defaultValue}) {
    getItem();
  }

  /// Synchronously accesses and returns the item, immediately asynchronously
  /// accessing and setting the item with [initializer] if that fails.
  Future<T> getItem() async => _isAssigned
      ? _item
      : await (initializer()
        ..then((v) {
          if (!_isAssigned) {
            _isAssigned = true;
            return _item = v;
          } else {
            print(
              "LazyUnsafeInitializer<$T> was initialized before initializer completed.",
            );
            return _item;
          }
        }).ignore());
}

/// Handles safely accessing and initializing an asynchronously created asset
/// that's otherwise constant. This ensures the initializer won't be triggered
/// multiple times if there's a long time between the initial firing and the
/// value's return.
///
/// TODO: Test
/// TODO: Extend with optional event-based assignment triggering.
class LazyInitializer<T> {
  final Future<T> Function() initializer;
  final T? defaultValue;

  bool _isAssigned = false;
  bool get isAssigned => _isAssigned;

  Future<T>? _future;
  bool get isAssigning => _future != null;

  /// The true item.
  /// {@template lateError}
  /// Accessing before assignment will throw a [LateInitializationError].
  /// {@endtemplate}
  late final T _item;

  /// Accesses the true item.
  /// {@macro lateError}
  @Deprecated(r"Use $")
  T get item => _item;

  /// Accesses the true item.
  /// {@macro lateError}
  T get $ => _item;

  /// Synchronously accesses and returns the item, immediately
  /// asynchronously setting the item with [initializer] and
  /// returning [defaultValue] if that fails.
  @Deprecated(r"Use $Safe")
  T? get itemSafe => $Safe;

  /// Synchronously accesses and returns the item, immediately
  /// asynchronously setting the item with [initializer] and
  /// returning [defaultValue] if that fails.
  T? get $Safe {
    return _isAssigned
        ? _item
        : !isAssigning
            ? (() {
                _future = initializer()..then(_myThen).ignore();
                return defaultValue;
              })()
            : defaultValue;
  }

  LazyInitializer(this.initializer, {this.defaultValue});
  LazyInitializer.immediate(this.initializer, {this.defaultValue}) {
    getItem();
  }

  /// Synchronously accesses and returns the item, immediately asynchronously
  /// accessing and setting the item with [initializer] if that fails.
  FutureOr<T> getItem() => _isAssigned
      ? _item
      : (isAssigning
          ? _future!
          : (_future = (initializer()..then(_myThen).ignore()))) as FutureOr<T>;

  /// Same as [getItem], but always returns a future.
  Future<T> getItemAsync() async => _isAssigned
      ? _item
      : isAssigning
          ? await _future!
          : await (_future = (initializer()..then(_myThen).ignore())) ?? _item;

  T _myThen(T v) {
    _future = null;
    if (!_isAssigned) {
      _isAssigned = true;
      return _item = v;
    } else {
      print(
        "LazySingleInitializer<$T> was initialized before initializer completed.",
      );
      return _item;
    }
  }
}

///
///
/// TODO: Test
/// TODO: Extension w/ default val and initializer
@Deprecated(
    "Use LateFinal. Will be replaced with the non-final LateInstance field soon.")
typedef Late<T> = LateFinal<T>;

///
///
/// TODO: Test
/// TODO: Extension w/ default val and initializer
class LateFinal<T> {
  /// The true item.
  /// {@macro lateError}
  late final T _item;

  bool _isAssigned = false;
  bool get isAssigned => _isAssigned;

  /// Accesses the true item.
  /// {@macro lateError}
  @Deprecated(r"Use $")
  T get item => _item;

  /// Accesses the true item.
  /// {@macro lateError}
  T get $ => _item;

  /// Sets the true item. Safely assigns the item once,
  /// gracefully fails afterwards.
  @Deprecated(r"Use $")
  set item(T value) => $ = value;

  /// Sets the true item. Safely assigns the item once,
  /// gracefully fails afterwards.
  set $(T value) {
    if (!_isAssigned) {
      _item = value;
      _isAssigned = true;
    } else {} // TODO: Warn
  }

  @Deprecated(r"Use $Safe")
  T? get itemSafe => _isAssigned ? _item : null;

  /// If the given value is null or [item] has been assigned, will not set value,
  /// even if [T] is a nullable type.
  @Deprecated(r"Use $Safe")
  set itemSafe(T? valOrNull) => (valOrNull != null) ? (item = valOrNull) : null;

  T? get $Safe => _isAssigned ? _item : null;

  /// If the given value is null or [$] has been assigned, will not set value,
  /// even if [T] is a nullable type.
  set $Safe(T? valOrNull) => (valOrNull != null) ? ($ = valOrNull) : null;

  T operator +(T value) {
    $ = value;
    return $;
  }

  T? operator ~() {
    return $Safe;
  }
}

///
///
/// TODO: Test
/// TODO: Extension w/ default val and initializer
class LateInstance<T> {
  /// The true item.
  /// {@macro lateError}
  late T _item;

  bool _isAssigned = false;
  bool get isAssigned => _isAssigned;

  /// Accesses the true item.
  /// {@macro lateError}
  @Deprecated(r"Use $")
  T get item => _item;

  /// Accesses the true item.
  /// {@macro lateError}
  T get $ => _item;

  /// Sets the true item. Safely assigns the item
  /// and sets the [isAssigned] flag.
  @Deprecated(r"Use $")
  set item(T value) {
    _item = value;
    _isAssigned = true;
  }

  /// Sets the true item. Safely assigns the item
  /// and sets the [isAssigned] flag.
  set $(T value) {
    _item = value;
    _isAssigned = true;
  }

  @Deprecated(r"Use $Safe")
  T? get itemSafe => $Safe;

  /// If the given value is null, will not set value,
  /// even if [T] is a nullable type.
  @Deprecated(r"Use $Safe")
  set itemSafe(T? valOrNull) =>
      (valOrNull != null) ? (_item = valOrNull) : null;

  T? get $Safe => _isAssigned ? _item : null;

  /// If the given value is null, will not set value,
  /// even if [T] is a nullable type.
  set $Safe(T? valOrNull) => (valOrNull != null) ? (_item = valOrNull) : null;

  @Deprecated(r"Use $")
  T operator +(T value) {
    $ = value;
    return $;
  }

  @Deprecated(r"Use $Safe")
  T? operator ~() {
    return $Safe;
  }
}

/* ReturnType Function() */
/// Allows users to take advantage of scoping to define a generator function to
/// perform an action or return a variable and at a later time/in a
/// different scope, inject the dependencies the first function requires
/// with a dispatcher function.
class Generator<ReturnType, Signature extends Function> {
  /// The main function.
  ///
  /// [Signature] must return [ReturnType].
  final Signature generator;

  /// The function used to inject [generator]'s dependencies when required.
  ///
  /// If this is null, a call to [generate] must include a non-null dispatcher.
  final ReturnType Function(Signature generatorFunction)? dispatcher;

  Generator({required this.generator, this.dispatcher});

  /// Fires [generator] using either [dispatcher] or [Generator.dispatcher] to
  /// inject any necessary dependencies, and returns the output of [generator]
  /// through the dispatcher.
  ///
  /// If [Generator.dispatcher] is null, [dispatcher] must be non-null.
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

// mixin SingletonRegistry<
//     T /* extends SingletonRegistrant<T> */ > /*  on SingletonRegistrant<T> */ {
//   static final Map<Type, Function> _instanceInitializer = {};
//   static final Map<Type, dynamic> _instances = {};
//   static bool registerInitializer<T>(T Function() initializer) {
//     if (_instanceInitializer.containsKey(T)) return false;
//     _instanceInitializer[T] = initializer;
//     return true;
//   }

//   // final T Function() initializer;
//   bool registerMyInitializer(T Function() initializer) {
//     if (_instanceInitializer.containsKey(T)) return false;
//     _instanceInitializer[T] = initializer;
//     return true;
//   }

//   T get instance => (_instances[T] != null)
//       ? _instances[T]
//       : _instances[T] = _instanceInitializer[T]!();
//   static T getInstanceOf<T>() => (_instances[T] != null)
//       ? _instances[T]
//       : _instances[T] = _instanceInitializer[T]!();
// }

// abstract interface class SingletonRegistrant<T extends SingletonRegistrant<T>> {
//   final T Function() initializer;
//   bool check() => initializer != null;
//   bool doubleCheck();
//   SingletonRegistrant({required this.initializer});
// }

// class foo extends SingletonRegistrant<foo> {
//   foo({super.initializer = foo.new});
//   @override
//   bool doubleCheck() => initializer != null;
// }

// abstract interface class ISingleton<T extends ISingleton<T>> {
//   late final instanceField;
//   get instance;
// }

mixin UniqueIdGenerator<T> {
  static const validCharacters =
      "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0123456789_;:[{]}*<>";
  static final Set<String> ids = {};
  static bool tryAddId(String proposedId) {
    if (ids.contains(ids)) return false;
    ids.add(proposedId);
    return true;
  }

  static String _generateNewProposedId(String prior) => prior.codeUnits
      .map((e) => validCharacters[e % validCharacters.length])
      .fold("", (acc, e) => "$acc$e");

  static String getNewId([String proposedId = ""]) => _getNewId(1, proposedId);

  static String _getNewId(int depth, [String proposedId = ""]) {
    if (proposedId != "" && tryAddId(proposedId)) return proposedId;
    if (depth >= 100) throw StateError("Failed to find new id");
    return _getNewId(++depth, _generateNewProposedId(proposedId));
  }
}

/// Wraps a [FutureOr] and cleanly handles error logging and type resolution.
class ValueAsync<V> {
  final FutureOr<V> value;
  final _value = LateInstance<V>();
  ({Object error, StackTrace? stackTrace})? _errorData;
  ({Object error, StackTrace? stackTrace})? get errorData => _errorData;
  clearErrorData() => _errorData = null;
  // Object? _error;
  // StackTrace? _stackTrace;
  // Object? _error;
  // StackTrace? _stackTrace;
  // set errorData(({Object error, StackTrace? stackTrace}) d) => (
  //       error: _error,
  //       stackTrace: _stackTrace,
  //     );
  // ({Object error, StackTrace? stackTrace}) get errorData => (
  //       error: _error,
  //       stackTrace: _stackTrace,
  //     );
  bool get isValue => value is V;
  bool get isFuture => value is Future<V>;
  bool get isComplete => _value.isAssigned;
  Future<V>? get futureSafe => value as Future<V>?;
  Future<V> get future => value as Future<V>;
  V? get $Safe => _value.$Safe;
  V get $ => _value.$;
  set $(V v) => _value.$ = v;

  /// If [trySilenceErrors] is true, will try to suppress errors
  /// in default error catcher. Otherwise, rethrows.
  /// TODO: make value unnamed parameter
  ValueAsync({
    void Function(V value)? then,
    required this.value,
    FutureOr<V> Function(Object? error, StackTrace s)? onError,
    Function? catchError,
    bool trySilenceErrors = false,
  }) {
    if (isFuture) {
      final future = this.future;
      if (onError != null) future.onError(onError);
      future.catchError(catchError ?? makeDefaultCatchError(trySilenceErrors));
      future.then((v) => _value.$ = v);
    } else {
      _initIsNotFuture();
    }
  }
  ValueAsync.resolveError({
    void Function(V value)? then,
    required this.value,
    FutureOr<V> Function(Object? error, StackTrace s)? onError,
    Function? catchError,
  }) {
    if (isFuture) {
      final future = this.future;
      if (catchError != null) {
        future.catchError(catchError);
      } else if (onError == null) {
        throw ArgumentError.value(
          "Either onError or catchError must be defined.",
        );
      }
      if (onError != null) future.onError(onError);
      future.then((v) => _value.$ = v);
    } else {
      _initIsNotFuture();
    }
  }
  ValueAsync.onError({
    void Function(V value)? then,
    required this.value,
    required FutureOr<V> Function(Object? error, StackTrace s) onError,
    // Function? catchError,
    // bool trySilenceErrors = false,
  }) {
    if (isFuture) {
      final future = this.future;
      future.onError(onError);
      // future.catchError(catchError ?? makeDefaultCatchError(trySilenceErrors));
      future.then((v) => _value.$ = v);
    } else {
      _initIsNotFuture();
    }
  }

  /// If [cacheErrors] is true, then the errors will be stored
  /// in [ValueAsync.errorData] before executing [catchError].
  ValueAsync.catchError({
    void Function(V value)? then,
    required this.value,
    required Function catchError,
    FutureOr<V> Function(Object? error, StackTrace s)? onError,
    bool cacheErrors = true,
  }) {
    if (isFuture) {
      final future = this.future;
      if (onError != null) future.onError(onError);
      future.catchError(!cacheErrors
          ? catchError
          : (e, s) {
              // _error = e;
              // _stackTrace = s;
              _errorData = (error: e, stackTrace: s);
              return catchError(e, s);
            });
      future.then((v) => _value.$ = v);
    } else {
      _initIsNotFuture();
    }
  }
  void _initIsNotFuture() {
    if (isValue) {
      _value.$ = value as V;
    }
  }

  /// If [trySilenceErrors] is true, will try to suppress errors
  /// in default error catcher. Otherwise, rethrows.
  Function makeDefaultCatchError([bool trySilenceErrors = false]) => (e, s) {
        // _error = e;
        // _stackTrace = s;
        _errorData = (error: e, stackTrace: s);
        return trySilenceErrors ? e : Error.throwWithStackTrace(e, s);
      };

  /// If [trySilenceErrors] is true, will try to suppress errors
  /// in default error catcher. Otherwise, rethrows.
  static Future<V> resolve<V, T>({
    T Function(V value)? then,
    required FutureOr<V> value,
    FutureOr<V> Function(Object? error, StackTrace s)? onError,
    Function? catchError,
    bool trySilenceErrors = false,
  }) async {
    if (value is Future<V>) {
      if (onError != null) value.onError(onError);
      value.catchError(catchError ??
          (e, s) {
            return trySilenceErrors ? e : Error.throwWithStackTrace(e, s);
          });
      return value..then((v) => then?.call(v));
    } else {
      then?.call(value);
      return value;
    }
  }

  static Future<V> resolveResolveError<V, T>({
    T Function(V value)? then,
    required FutureOr<V> value,
    FutureOr<V> Function(Object? error, StackTrace s)? onError,
    Function? catchError,
  }) async {
    if (value is Future<V>) {
      if (catchError != null) {
        value.catchError(catchError);
      } else if (onError == null) {
        throw ArgumentError.value(
          "Either onError or catchError must be defined.",
        );
      }
      if (onError != null) value.onError(onError);
      return value..then((v) => then?.call(v));
    } else {
      then?.call(value);
      return value;
    }
  }

  static Future<V> resolveOnError<V, T>({
    T Function(V value)? then,
    required FutureOr<V> value,
    required FutureOr<V> Function(Object? error, StackTrace s) onError,
    // Function? catchError,
    // bool trySilenceErrors = false,
  }) async {
    if (value is Future<V>) {
      value.onError(onError);
      // future.catchError(catchError ?? makeDefaultCatchError(trySilenceErrors));
      return value..then((v) => then?.call(v));
    } else {
      then?.call(value);
      return value;
    }
  }

  /// If [cacheErrors] is true, then the errors will be stored
  /// in [ValueAsync.errorData] before executing [catchError].
  static Future<V> resolveCatchError<V, T>({
    T Function(V value)? then,
    required FutureOr<V> value,
    required Function catchError,
    FutureOr<V> Function(Object? error, StackTrace s)? onError,
    bool cacheErrors = true,
  }) async {
    if (value is Future<V>) {
      if (onError != null) value.onError(onError);
      value.catchError(!cacheErrors ? catchError : (e, s) => catchError(e, s));
      return value..then((v) => then?.call(v));
    } else {
      then?.call(value);
      return value;
    }
  }
}

mixin ValueAsyncMixin<V> implements ValueAsync<V> {
  final _inst = LateFinal<ValueAsync<V>>();
  ValueAsync<V> get inst => _inst.$;
  @override
  bool get isValue => inst.isValue;
  @override
  bool get isFuture => inst.isFuture;
  @override
  bool get isComplete => inst.isComplete;
  @override
  Future<V>? get futureSafe => inst.futureSafe;
  @override
  Future<V> get future => inst.future;
  @override
  V? get $Safe => inst.$Safe;
  @override
  V get $ => inst.$;
  @override
  set $(V v) => inst.$;

  @override
  clearErrorData() => inst.clearErrorData();

  @override
  ({Object error, StackTrace? stackTrace})? get errorData => inst.errorData;

  @override
  Function makeDefaultCatchError([bool trySilenceErrors = false]) =>
      inst.makeDefaultCatchError(trySilenceErrors);

  @override
  FutureOr<V> get value => inst.value;
}
