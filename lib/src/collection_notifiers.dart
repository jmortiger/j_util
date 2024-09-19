import 'dart:collection';
import 'package:flutter/foundation.dart';

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
