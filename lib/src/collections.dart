import 'package:j_util/src/types.dart' show Late;

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

class PriorityQueue<T extends Comparable<T>> /*  extends Iterable<T> */ {
  // @override
  // // TODO: implement iterator
  // Iterator<T> get iterator => throw UnimplementedError();

  final List<List<T>> queue = [];
  final Late<List<T>> _queueToList = Late();
  List<T> get squashedList => _queueToList.isAssigned
      ? _queueToList.item
      : (_queueToList.item = queue.fold(
          <T>[], (previousValue, element) => previousValue..addAll(element)));

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
