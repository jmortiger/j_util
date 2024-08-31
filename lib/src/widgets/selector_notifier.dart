import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

typedef Builder<S> = Widget Function(
    BuildContext context, S value, Widget? child);
typedef ShouldRebuild<S> = bool Function(S prior, S curr);

/// https://pub.dev/documentation/provider/latest/provider/Selector-class.html
class SelectorNotifier0<S> extends StatefulWidget {
  final S Function(BuildContext context) selector;
  final Builder<S> builder;
  final ShouldRebuild<S> shouldRebuild;
  final Widget? child;
  const SelectorNotifier0({
    super.key,
    required this.selector,
    required this.builder,
    ShouldRebuild<S>? shouldRebuild,
    this.child,
  }) : shouldRebuild = shouldRebuild ?? defaultShouldRebuild;
  void addListener(void Function() listener) {}
  void removeListener(void Function() listener) {}

  static bool defaultShouldRebuild<S>(S prior, S current) =>
      !const DeepCollectionEquality().equals(prior, current);

  @override
  State<SelectorNotifier0<S>> createState() => _SelectorNotifier0State<S>();
}

class _SelectorNotifier0State<S> extends State<SelectorNotifier0<S>> {
  late S currSelection;
  @override
  void initState() {
    super.initState();
    widget.addListener(onChange);
    // currSelection = widget.selector(context/* , value */);
  }

  @override
  void dispose() {
    widget.removeListener(onChange);
    super.dispose();
  }

  void onChange() {
    final newV = widget.selector(context /* , value */);
    if (widget.shouldRebuild(currSelection, newV)) {
      setState(() {
        currSelection = newV;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // currSelection = widget.selector(context/* , value */);
    try {
      return widget.builder(context, currSelection, widget.child);
    } catch (e) {
      currSelection = widget.selector(context /* , value */);
      return widget.builder(context, currSelection, widget.child);
    }
  }
}

class SelectorNotifier<N extends ChangeNotifier, S>
    extends SelectorNotifier0<S> {
  final N value;
  SelectorNotifier({
    super.key,
    required S Function(BuildContext context, N value) selector,
    required super.builder,
    super.shouldRebuild,
    super.child,
    required this.value,
  }) : super(selector: ((BuildContext context) => selector(context, value)));
  @override
  void addListener(void Function() listener) => value.addListener(listener);
  @override
  void removeListener(void Function() listener) =>
      value.removeListener(listener);

  @override
  State<SelectorNotifier0<S>> createState() => _SelectorNotifier0State<S>();
}

class SelectorNotifier2<N1 extends ChangeNotifier, N2 extends ChangeNotifier, S>
    extends SelectorNotifier0<S> {
  final N1 value1;
  final N2 value2;
  SelectorNotifier2({
    super.key,
    required S Function(BuildContext context, N1 value1, N2 value2) selector,
    required super.builder,
    super.shouldRebuild,
    super.child,
    required this.value1,
    required this.value2,
  }) : super(
            selector: ((BuildContext context) =>
                selector(context, value1, value2)));
  @override
  void addListener(void Function() listener) {
    value1.addListener(listener);
    value2.addListener(listener);
  }

  @override
  void removeListener(void Function() listener) {
    value1.removeListener(listener);
    value2.removeListener(listener);
  }

  @override
  State<SelectorNotifier0<S>> createState() => _SelectorNotifier0State<S>();
}

class SelectorNotifierCollection<N extends Iterable<ChangeNotifier>, S>
    extends SelectorNotifier0<S> {
  final N values;
  SelectorNotifierCollection({
    super.key,
    required S Function(BuildContext context, N values) selector,
    required super.builder,
    super.shouldRebuild,
    super.child,
    required this.values,
  }) : super(selector: ((BuildContext context) => selector(context, values)));
  @override
  void addListener(void Function() listener) =>
      values.forEach((v) => v.addListener(listener));
  @override
  void removeListener(void Function() listener) =>
      values.forEach((v) => v.removeListener(listener));

  @override
  State<SelectorNotifier0<S>> createState() => _SelectorNotifier0State<S>();
}
