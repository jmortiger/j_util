import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WPullTab extends StatefulWidget {
  final AnchorAlignmentOrdinal anchorAlignment;
  final Duration duration;
  final List<Widget>? children;
  final List<Widget> Function(BuildContext context)? builder;
  final void Function(bool isOpen)? onToggle;

  /// This icon won't receive interactions while in the opened state.
  final Widget openIcon;
  final Widget closeIcon;

  final bool initialOpen;
  final double distance;
  final double? verticalBounds;
  final double? horizontalBounds;
  final String disabledTooltip;
  final bool useDefaultHeroTag;
  final Object? heroTag;
  final Color? color;
  final Color? disabledColor;
  const WPullTab({
    super.key,
    this.anchorAlignment = AnchorAlignmentOrdinal.bottom,
    this.duration = const Duration(milliseconds: 250),
    required List<Widget> this.children,
    this.openIcon = const Icon(Icons.create),
    this.closeIcon = const Icon(Icons.close),
    this.initialOpen = false,
    required this.distance,
    this.disabledTooltip = "",
    this.useDefaultHeroTag = true,
    this.heroTag,
    this.onToggle,
    this.color,
    this.disabledColor,
    this.verticalBounds,
    this.horizontalBounds,
  }) : builder = null;
  const WPullTab.builder({
    super.key,
    this.anchorAlignment = AnchorAlignmentOrdinal.bottom,
    this.duration = const Duration(milliseconds: 250),
    required List<Widget> Function(BuildContext context) this.builder,
    this.openIcon = const Icon(Icons.create),
    this.closeIcon = const Icon(Icons.close),
    this.initialOpen = false,
    required this.distance,
    required this.disabledTooltip,
    required this.useDefaultHeroTag,
    this.heroTag,
    this.onToggle,
    this.color,
    this.disabledColor,
    this.verticalBounds,
    this.horizontalBounds,
  }) : children = null;

  @override
  State<WPullTab> createState() => _WPullTabState();
}

class _WPullTabState extends State<WPullTab>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  List<Widget> get children =>
      (widget.builder?.call(context) ?? widget.children)!;
  @override
  void initState() {
    super.initState();
    _expanded = widget.initialOpen;
    _controller = AnimationController(
      value: _expanded ? 1.0 : 0.0,
      duration: widget.duration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onToggle?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final close = _buildTapToClose(),
        buttons = _buildButtons(context),
        open = _buildTapToOpen(buttons.isNotEmpty);
    return buttons.isNotEmpty
        ? OverflowBox(
            alignment: widget.anchorAlignment.alignment,
            fit: OverflowBoxFit.deferToChild,
            // fit: OverflowBoxFit.max,
            maxHeight:
                widget.verticalBounds ?? MediaQuery.sizeOf(context).height,
            maxWidth:
                widget.horizontalBounds ?? MediaQuery.sizeOf(context).width,
            minHeight: widget.anchorAlignment.isVertical
                ? widget.verticalBounds ?? MediaQuery.sizeOf(context).height
                : null,
            minWidth: widget.anchorAlignment.isHorizontal
                ? widget.horizontalBounds ?? MediaQuery.sizeOf(context).width
                : null,
            child: Stack(
              fit: StackFit.passthrough,
              alignment: widget.anchorAlignment.alignment,
              // clipBehavior: Clip.hardEdge,
              children: [
                _WRibbon(
                  // startingDistance: 56,
                  // startingDistance: widget.distance / (children.length + 1),
                  distance: widget.distance,
                  progress: _expandAnimation,
                  duration: widget.duration,
                  color: widget.color,
                  anchorAlignment: widget.anchorAlignment,
                  child: _expanded ? close : open,
                ),
                close,
                ...buttons,
                open,
              ],
            ),
          )
        : IconButton(
            tooltip: widget.disabledTooltip,
            onPressed: null,
            icon: widget.openIcon,
            disabledColor: widget.disabledColor,
          );
  }

  Widget _buildTapToClose() {
    return SizedBox(
      // width: widget.distance / (children.length + 1),
      // height: widget.distance / (children.length + 1),
      // width: 56,
      // height: 56,
      child: Padding(
        padding: const EdgeInsets.all(0), //8
        child: Align(
          heightFactor: widget.anchorAlignment.isVertical ? null : 1,
          widthFactor: widget.anchorAlignment.isHorizontal ? null : 1,
          alignment: widget.anchorAlignment.alignment,
          child: Material(
            color: widget.color,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: widget.openIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final children = <Widget>[];
    final widgetChildren = this.children;
    final count = widgetChildren.length;
    final step = widget.distance / (count + 1);
    for (var i = 0, displacement = step; i < count; i++, displacement += step) {
      children.add(
        SlidingActionButton.axisBased(
          anchor: widget.anchorAlignment,
          maxDistance: displacement,
          progress: _expandAnimation,
          child: widgetChildren[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpen([bool enabled = true]) {
    return IgnorePointer(
      ignoring: enabled,
      child: AnimatedOpacity(
        opacity: _expanded ? 0.0 : 1.0,
        curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
        duration: widget.duration,
        child: AnimatedContainer(
          transformAlignment: Alignment.center,
          transform: Matrix4.diagonal3Values(
            _expanded ? 0.7 : 1.0,
            _expanded ? 0.7 : 1.0,
            1.0,
          ),
          duration: widget.duration,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          child: Align(
            heightFactor: widget.anchorAlignment.isVertical ? null : 1,
            widthFactor: widget.anchorAlignment.isHorizontal ? null : 1,
            alignment: widget.anchorAlignment.alignment,
            child: Padding(
              padding: const EdgeInsets.all(0), //8
              child: IconButton(
                onPressed: enabled ? _toggle : null,
                icon: !_expanded ? widget.openIcon : widget.closeIcon,
                // focusColor: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WRibbon extends StatelessWidget {
  final Animation<double> progress;
  // final double? directionInDegrees;
  final Duration duration;
  final Color? color;
  final AnchorAlignmentOrdinal anchorAlignment;
  final double distance;
  final double startingDistance;
  final Widget? child;
  const _WRibbon({
    super.key,
    required this.progress,
    required this.duration,
    this.color,
    required this.anchorAlignment,
    required double distance,
    this.startingDistance = 0,
    this.child,
  }) : distance = distance - startingDistance;
  double get currentDistance => progress.value * distance + startingDistance;
  @override
  Widget build(BuildContext context) {
    final ribbon = Material(
      shape: StadiumBorder(),
      color: color,
      animationDuration: duration,
      child: child,
    );
    return AnimatedBuilder(
      animation: progress,
      builder: (_, child) => switch (anchorAlignment) {
        AnchorAlignmentOrdinal.top => Positioned(
            top: 0,
            height: currentDistance,
            right: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.bottom => Positioned(
            bottom: 0,
            height: currentDistance,
            right: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.left => Positioned(
            bottom: 0,
            width: currentDistance,
            top: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.right => Positioned(
            bottom: 0,
            width: currentDistance,
            top: 0,
            right: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.topLeft => Positioned(
            height: currentDistance * anchorAlignment.yComponent,
            width: currentDistance * anchorAlignment.xComponent,
            top: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.bottomLeft => Positioned(
            height: currentDistance * anchorAlignment.yComponent,
            width: currentDistance * anchorAlignment.xComponent,
            bottom: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.bottomRight => Positioned(
            height: currentDistance * anchorAlignment.yComponent,
            width: currentDistance * anchorAlignment.xComponent,
            bottom: 0,
            right: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.topRight => Positioned(
            height: currentDistance * anchorAlignment.yComponent,
            width: currentDistance * anchorAlignment.xComponent,
            top: 0,
            right: 0,
            child: child!,
          ),
      },
      child: ribbon,
    );
  }
}

@immutable
class SlidingActionButton extends StatelessWidget {
  const SlidingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    this.anchor,
    this.ignoredStates = const {
      AnimationStatus.dismissed,
      AnimationStatus.forward,
      AnimationStatus.reverse,
    },
    required this.child,
  });
  const SlidingActionButton.axisBased({
    this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.anchor,
    this.ignoredStates = const {
      AnimationStatus.dismissed,
      AnimationStatus.forward,
      AnimationStatus.reverse,
    },
    required this.child,
  });

  final double? directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  /// When [progress] is in one of these states, the
  /// button will be wrapped in an [IgnorePointer].
  final Set<AnimationStatus> ignoredStates;

  final AnchorAlignment? anchor;
  AnchorAlignment get anchorFromValues =>
      anchor ?? AnchorAlignment.fromDirectionDegrees(directionInDegrees!);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final anchorFromValues = this.anchorFromValues,
            r1 = Transform.rotate(
              angle: (1.0 - progress.value) * math.pi / 2,
              child: child!,
            ),
            root = ignoredStates.contains(progress.status)
                ? IgnorePointer(child: r1)
                : r1,
            offset = directionInDegrees == null
                ? Offset(anchor!.xComponent * progress.value * maxDistance,
                    anchor!.yComponent * progress.value * maxDistance)
                : anchorFromValues.xComponent ==
                        anchorFromValues.xComponent.toInt()
                    ? Offset(
                        anchorFromValues.xComponent *
                            progress.value *
                            maxDistance,
                        anchorFromValues.yComponent *
                            progress.value *
                            maxDistance)
                    : Offset.fromDirection(
                        directionInDegrees! * (math.pi / 180.0),
                        progress.value * maxDistance,
                      );
        if (anchorFromValues is AnchorAlignmentOrdinal) {
          return switch (anchorFromValues) {
            AnchorAlignmentOrdinal.top => Positioned(
                // right: /* 4.0 +  */offset.dx,
                top: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            AnchorAlignmentOrdinal.bottom => Positioned(
                // right: /* 4.0 +  */offset.dx,
                bottom: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            AnchorAlignmentOrdinal.left => Positioned(
                left: /* 4.0 +  */ offset.dx,
                // top: /* 4.0 +  */offset.dy,
                child: root,
              ),
            AnchorAlignmentOrdinal.right => Positioned(
                right: /* 4.0 +  */ offset.dx,
                // top: /* 4.0 +  */offset.dy,
                child: root,
              ),
            AnchorAlignmentOrdinal.topLeft => Positioned(
                left: /* 4.0 +  */ offset.dx,
                top: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            AnchorAlignmentOrdinal.bottomLeft => Positioned(
                left: /* 4.0 +  */ offset.dx,
                bottom: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            AnchorAlignmentOrdinal.bottomRight => Positioned(
                right: /* 4.0 +  */ offset.dx,
                bottom: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            AnchorAlignmentOrdinal.topRight => Positioned(
                right: /* 4.0 +  */ offset.dx,
                top: /* 4.0 +  */ offset.dy,
                child: root,
              )
          };
        } else {
          return switch (anchorFromValues.quadrantsContaining) {
            Quadrants.oneAndTwo => Positioned(
                // right: /* 4.0 +  */offset.dx,
                top: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            Quadrants.threeAndFour => Positioned(
                // right: /* 4.0 +  */offset.dx,
                bottom: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            Quadrants.twoAndThree => Positioned(
                left: /* 4.0 +  */ offset.dx,
                // top: /* 4.0 +  */offset.dy,
                child: root,
              ),
            Quadrants.fourAndOne => Positioned(
                right: /* 4.0 +  */ offset.dx,
                // top: /* 4.0 +  */offset.dy,
                child: root,
              ),
            Quadrants.two => Positioned(
                left: /* 4.0 +  */ offset.dx,
                top: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            Quadrants.three => Positioned(
                left: /* 4.0 +  */ offset.dx,
                bottom: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            Quadrants.four => Positioned(
                right: /* 4.0 +  */ offset.dx,
                bottom: /* 4.0 +  */ offset.dy,
                child: root,
              ),
            Quadrants.one => Positioned(
                right: /* 4.0 +  */ offset.dx,
                top: /* 4.0 +  */ offset.dy,
                child: root,
              )
          };
        }
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

enum AnchorAlignmentCardinal with AnchorAlignment {
  top(270),
  bottom(90),
  left(0),
  right(180);

  @override
  Alignment get alignment => switch (this) {
        top => Alignment.topCenter,
        bottom => Alignment.bottomCenter,
        right => Alignment.centerRight,
        left => Alignment.centerLeft,
      };
  @override
  bool get isHorizontal => switch (this) {
        top => false,
        bottom => false,
        right => true,
        left => true,
      };
  @override
  bool get isVertical => switch (this) {
        top => true,
        bottom => true,
        right => false,
        left => false,
      };
  @override
  final double facingDegrees;
  const AnchorAlignmentCardinal(this.facingDegrees);

  AnchorAlignmentOrdinal toAnchorAlignmentOrdinal() => switch (this) {
        top => AnchorAlignmentOrdinal.top,
        bottom => AnchorAlignmentOrdinal.bottom,
        left => AnchorAlignmentOrdinal.left,
        right => AnchorAlignmentOrdinal.right,
      };
}

enum AnchorAlignmentOrdinal with AnchorAlignment {
  top(270),
  bottom(90),
  left(0),
  right(180),
  topLeft(180 + 45),
  bottomLeft(90 + 45),
  bottomRight(45),
  topRight(270 + 45);

  @override
  Alignment get alignment => switch (this) {
        top => Alignment.topCenter,
        bottom => Alignment.bottomCenter,
        right => Alignment.centerRight,
        left => Alignment.centerLeft,
        topLeft => Alignment.topLeft,
        bottomLeft => Alignment.bottomLeft,
        bottomRight => Alignment.bottomRight,
        topRight => Alignment.topRight,
      };
  @override
  bool get isHorizontal => switch (this) {
        top => false,
        bottom => false,
        right => true,
        left => true,
        topLeft => true,
        bottomLeft => true,
        bottomRight => true,
        topRight => true,
      };
  @override
  bool get isVertical => switch (this) {
        top => true,
        bottom => true,
        right => false,
        left => false,
        topLeft => true,
        bottomLeft => true,
        bottomRight => true,
        topRight => true,
      };
  @override
  final double facingDegrees;
  const AnchorAlignmentOrdinal(this.facingDegrees);
  static num constrainDegrees(num degrees) =>
      degrees < 0 ? 360 + (degrees % 360) : degrees % 360;
  factory AnchorAlignmentOrdinal.fromLocationDegrees(num degrees) =>
      switch (constrainDegrees(degrees)) {
        == 0 => right,
        > 0 && < 90 => topRight,
        == 90 => top,
        > 90 && < 180 => topLeft,
        == 180 => right,
        > 180 && < 270 => bottomRight,
        == 270 => bottom,
        > 270 && < 360 => topLeft,
        < 0 || >= 360 => throw StateError("Should be 0 <= x < 360 by now"),
        num n when !n.isFinite =>
          throw ArgumentError.value(degrees, "degrees", "Must be finite"),
        _ => throw StateError("Something has gone extremely wrong"),
      };
  factory AnchorAlignmentOrdinal.fromDirectionDegrees(num degrees) =>
      switch (constrainDegrees(degrees)) {
        == 0 => left,
        > 0 && < 90 => bottomLeft,
        == 90 => bottom,
        > 90 && < 180 => bottomRight,
        == 180 => right,
        > 180 && < 270 => topRight,
        == 270 => top,
        > 270 && < 360 => topLeft,
        < 0 || >= 360 => throw StateError("Should be 0 <= x < 360 by now"),
        num n when !n.isFinite =>
          throw ArgumentError.value(degrees, "degrees", "Must be finite"),
        _ => throw StateError("Something has gone extremely wrong"),
      };
}

enum CardinalDirection {
  d0,
  d90,
  d180,
  d270;
}

enum Quadrants {
  one,
  oneAndTwo,
  two,
  twoAndThree,
  three,
  threeAndFour,
  four,
  fourAndOne;
}

mixin AnchorAlignment {
  static const top = AnchorAlignmentOrdinal.top;
  static const bottom = AnchorAlignmentOrdinal.bottom;
  static const left = AnchorAlignmentOrdinal.left;
  static const right = AnchorAlignmentOrdinal.right;
  static const topLeft = AnchorAlignmentOrdinal.topLeft;
  static const bottomLeft = AnchorAlignmentOrdinal.bottomLeft;
  static const bottomRight = AnchorAlignmentOrdinal.bottomRight;
  static const topRight = AnchorAlignmentOrdinal.topRight;

  bool get isCardinal =>
      isApproximately(facingDegrees, 0) ||
      isApproximately(facingDegrees, 90) ||
      isApproximately(facingDegrees, 180) ||
      isApproximately(facingDegrees, 270) ||
      isApproximately(facingDegrees, 360);
  bool get isOrdinal =>
      isApproximately(facingDegrees, 0 + 45) ||
      isApproximately(facingDegrees, 90 + 45) ||
      isApproximately(facingDegrees, 180 + 45) ||
      isApproximately(facingDegrees, 270 + 45) ||
      isApproximately(facingDegrees, 360 + 45);
  bool get isCardinalOrOrdinal => isCardinal || isOrdinal;
  static CardinalDirection getClosestCardinal(num facingDegrees) {
    facingDegrees = constrainDegrees(facingDegrees);
    final d0 = (facingDegrees.toDouble()).abs(),
        d90 = (facingDegrees.toDouble() - 90).abs(),
        d180 = (facingDegrees.toDouble() - 180).abs(),
        d270 = (facingDegrees.toDouble() - 270).abs(),
        d360 = (facingDegrees.toDouble() - 360).abs();
    var s = d0;
    if (d90 < s) s = d90;
    if (d180 < s) s = d180;
    if (d270 < s) s = d270;
    if (d360 < s) s = d360;
    return switch (s) {
      double d when d == d0 || d == d360 => CardinalDirection.d0,
      double d when d == d90 => CardinalDirection.d90,
      double d when d == d180 => CardinalDirection.d180,
      double d when d == d270 => CardinalDirection.d270,
      _ => throw StateError("Something went very wrong"),
    };
  }

  Quadrants get quadrantsFacing => getQuadrants(facingDegrees);
  Quadrants get quadrantsContaining =>
      getQuadrants(constrainDegrees(facingDegrees + 180).toDouble());
  static Quadrants getQuadrants(double angleDegrees) => switch (angleDegrees) {
        > 0 + double.minPositive && < 90 - double.minPositive => Quadrants.one,
        > 90 + double.minPositive && < 180 - double.minPositive =>
          Quadrants.two,
        > 180 + double.minPositive && < 270 - double.minPositive =>
          Quadrants.three,
        > 270 + double.minPositive && < 360 - double.minPositive =>
          Quadrants.four,
        double d when isApproximately(d, 0) || isApproximately(d, 360) =>
          Quadrants.fourAndOne,
        double d when isApproximately(d, 90) => Quadrants.oneAndTwo,
        double d when isApproximately(d, 180) => Quadrants.twoAndThree,
        double d when isApproximately(d, 270) => Quadrants.threeAndFour,
        _ => throw StateError("Something went very wrong"),
      };

  Alignment get alignment {
    final o = Offset.fromDirection(facingRadians);
    return Alignment(o.dx, o.dy);
  }

  bool get isVertical => switch (facingDegrees) {
        (> 0 + double.minPositive && < 360 - double.minPositive) &&
              (< 180 - double.minPositive || > 180 + double.minPositive) =>
          true,
        _ => false,
      };
  bool get isHorizontal => switch (facingDegrees) {
        (< 90 - double.minPositive || > 90 + double.minPositive) &&
              (< 270 - double.minPositive || > 270 + double.minPositive) =>
          true,
        _ => false,
      };
  double get facingDegrees;
  double get facingRadians => facingDegrees * (math.pi / 180);
  double get xComponent => switch (constrainDegrees(facingDegrees)) {
        double d when isApproximately(d, 0) => 1,
        double d when isApproximately(d, 90) => 0,
        double d when isApproximately(d, 180) => -1,
        double d when isApproximately(d, 270) => 0,
        double d when isApproximately(d, 360) => 1,
        // 45 => math.cos(facingDegrees),
        // const (90 + 45) => math.cos(facingDegrees),
        // const (180 + 45) => math.cos(facingDegrees),
        // const (270 + 45) => math.cos(facingDegrees),
        _ => math.cos(facingDegrees),
      };
  double get yComponent => switch (constrainDegrees(facingDegrees)) {
        double d when isApproximately(d, 0) => 0,
        double d when isApproximately(d, 90) => 1,
        double d when isApproximately(d, 180) => 0,
        double d when isApproximately(d, 270) => -1,
        double d when isApproximately(d, 360) => 0,
        // 45 => math.sin(facingDegrees),
        // const (90 + 45) => math.sin(facingDegrees),
        // const (180 + 45) => math.sin(facingDegrees),
        // const (270 + 45) => math.sin(facingDegrees),
        _ => math.sin(facingDegrees),
      };
  // const AnchorAlignmentM(this.facingDegrees);
  static num constrainDegrees(num degrees) =>
      degrees < 0 ? 360 + (degrees % 360) : degrees % 360;
  static bool isApproximately(double lhs, double rhs,
          [double epsilon = double.minPositive]) =>
      lhs <= rhs + epsilon && lhs >= rhs - epsilon;
  static AnchorAlignmentOrdinal fromLocationDegrees(num degrees) =>
      switch (constrainDegrees(degrees)) {
        == 0 => AnchorAlignmentOrdinal.right,
        > 0 && < 90 => AnchorAlignmentOrdinal.topRight,
        == 90 => AnchorAlignmentOrdinal.top,
        > 90 && < 180 => AnchorAlignmentOrdinal.topLeft,
        == 180 => AnchorAlignmentOrdinal.right,
        > 180 && < 270 => AnchorAlignmentOrdinal.bottomRight,
        == 270 => AnchorAlignmentOrdinal.bottom,
        > 270 && < 360 => AnchorAlignmentOrdinal.topLeft,
        < 0 || >= 360 => throw StateError("Should be 0 <= x < 360 by now"),
        num n when !n.isFinite =>
          throw ArgumentError.value(degrees, "degrees", "Must be finite"),
        _ => throw StateError("Something has gone extremely wrong"),
      };
  static AnchorAlignment fromDirectionDegrees(num degrees) =>
      switch (constrainDegrees(degrees)) {
        == 0 => AnchorAlignmentOrdinal.left,
        == 45 => AnchorAlignmentOrdinal.bottomLeft,
        == 90 => AnchorAlignmentOrdinal.bottom,
        == 90 + 45 => AnchorAlignmentOrdinal.bottomRight,
        == 180 => AnchorAlignmentOrdinal.right,
        == 180 + 45 => AnchorAlignmentOrdinal.topRight,
        == 270 => AnchorAlignmentOrdinal.top,
        == 270 + 45 => AnchorAlignmentOrdinal.topLeft,
        < 0 || >= 360 => throw StateError("Should be 0 <= x < 360 by now"),
        num n when !n.isFinite =>
          throw ArgumentError.value(degrees, "degrees", "Must be finite"),
        _ => AnchorAlignmentInstance(degrees.toDouble()),
      };
  static AnchorAlignmentOrdinal fromDirectionDegreesOrdinal(num degrees) =>
      switch (constrainDegrees(degrees)) {
        == 0 => AnchorAlignmentOrdinal.left,
        > 0 && < 90 => AnchorAlignmentOrdinal.bottomLeft,
        == 90 => AnchorAlignmentOrdinal.bottom,
        > 90 && < 180 => AnchorAlignmentOrdinal.bottomRight,
        == 180 => AnchorAlignmentOrdinal.right,
        > 180 && < 270 => AnchorAlignmentOrdinal.topRight,
        == 270 => AnchorAlignmentOrdinal.top,
        > 270 && < 360 => AnchorAlignmentOrdinal.topLeft,
        < 0 || >= 360 => throw StateError("Should be 0 <= x < 360 by now"),
        num n when !n.isFinite =>
          throw ArgumentError.value(degrees, "degrees", "Must be finite"),
        _ => throw StateError("Something has gone extremely wrong"),
      };
}

class AnchorAlignmentInstance with AnchorAlignment {
  @override
  final double facingDegrees;
  const AnchorAlignmentInstance(this.facingDegrees);
  static num constrainDegrees(num degrees) =>
      degrees < 0 ? 360 + (degrees % 360) : degrees % 360;
  factory AnchorAlignmentInstance.fromLocationDegrees(num degrees) =>
      AnchorAlignmentInstance.fromDirectionDegrees(degrees + 180);
  factory AnchorAlignmentInstance.fromDirectionDegrees(num degrees) {
    degrees = constrainDegrees(degrees);
    return !degrees.isFinite
        ? throw ArgumentError.value(degrees, "degrees", "Must be finite")
        : AnchorAlignmentInstance(degrees.toDouble());
  }
  AnchorAlignmentOrdinal toOrdinal() =>
      switch (constrainDegrees(facingDegrees)) {
        == 0 => AnchorAlignmentOrdinal.left,
        > 0 && < 90 => AnchorAlignmentOrdinal.bottomLeft,
        == 90 => AnchorAlignmentOrdinal.bottom,
        > 90 && < 180 => AnchorAlignmentOrdinal.bottomRight,
        == 180 => AnchorAlignmentOrdinal.right,
        > 180 && < 270 => AnchorAlignmentOrdinal.topRight,
        == 270 => AnchorAlignmentOrdinal.top,
        > 270 && < 360 => AnchorAlignmentOrdinal.topLeft,
        < 0 || >= 360 => throw StateError("Should be 0 <= x < 360 by now"),
        num n when !n.isFinite => throw ArgumentError.value(
            facingDegrees, "facingDegrees", "Must be finite"),
        _ => throw StateError("Something has gone extremely wrong"),
      };
}
