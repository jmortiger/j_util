import 'package:j_util/j_util.dart' as util;
import 'package:j_util/src/extensions.dart';
import 'package:j_util/platform_finder.dart' as pf;

typedef VoidFunction = void Function();

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