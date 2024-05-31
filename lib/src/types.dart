import 'package:j_util/src/extensions.dart';

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
  String get namePretty   => name.toSentenceCaseFromCamel();
  String get nameUpper    => name.toUpperCase();
  String get nameConstant => name.toConstantCase();
  String get nameSnake    => name.toSnakeCaseFromCamelCase();
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
