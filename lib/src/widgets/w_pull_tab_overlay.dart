import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:j_util/src/widgets/w_pull_tab.dart';

class WPullTabOverlay extends StatefulWidget {
  final AnchorAlignmentOrdinal anchorAlignment;
  final Duration duration;
  final List<Widget>? children;
  final List<Widget> Function(BuildContext context)? builder;

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
  const WPullTabOverlay({
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
    this.color,
    this.disabledColor,
    this.verticalBounds,
    this.horizontalBounds,
  }) : builder = null;
  const WPullTabOverlay.builder({
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
    this.color,
    this.disabledColor,
    this.verticalBounds,
    this.horizontalBounds,
  }) : children = null;

  @override
  State<WPullTabOverlay> createState() => _WPullTabOverlayState();
}

class _WPullTabOverlayState extends State<WPullTabOverlay>
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
  }

  @override
  Widget build(BuildContext context) {
    var buttons = _buildExpandingActionButtons(context);
    return buttons.isNotEmpty
        ? ConstrainedBox(
          constraints: BoxConstraints.loose(MediaQuery.sizeOf(context)),
          child: Stack(
            alignment: widget.anchorAlignment.alignment,
            // clipBehavior: Clip.hardEdge,
            children: [
              _WRibbon(
                distance: widget.distance,
                progress: _expandAnimation,
                duration: widget.duration,
                color: widget.color,
                anchorAlignment: widget.anchorAlignment,
              ),
              _buildTapToCloseFab(),
              ...buttons,
              _buildTapToOpenFab(buttons.isNotEmpty),
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

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: widget.closeIcon,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons(BuildContext context) {
    final children = <Widget>[];
    final widgetChildren = this.children;
    final count = widgetChildren.length;
    final step = widget.distance / (count + 1);
    for (var i = 0, displacement = step; i < count; i++, displacement += step) {
      children.add(
        _ExpandingActionButton.axisBased(
          anchor: widget.anchorAlignment,
          // directionInDegrees: angleInDegrees,
          maxDistance: displacement, //widget.distance,
          progress: _expandAnimation,
          child: widgetChildren[i],
          ignore: true,
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab([bool enabled = true]) {
    return IgnorePointer(
      ignoring: _expanded,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _expanded ? 0.7 : 1.0,
          _expanded ? 0.7 : 1.0,
          1.0,
        ),
        duration: widget.duration,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _expanded ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: widget.duration,
          child: widget.useDefaultHeroTag
              ? IconButton(
                  onPressed: enabled ? _toggle : null,
                  icon: widget.openIcon,
                  color: widget.color,
                )
              : IconButton(
                  onPressed: enabled ? _toggle : null,
                  icon: widget.openIcon,
                  color: widget.color,
                  // heroTag: widget.heroTag,
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
  const _WRibbon({
    super.key,
    required this.progress,
    required this.duration,
    this.color,
    required this.anchorAlignment,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final ribbon = Material(
      shape: StadiumBorder(),
      color: color,
      animationDuration: duration,
    );
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) => switch (anchorAlignment) {
        AnchorAlignmentOrdinal.top => Positioned(
            top: 0,
            height: progress.value * distance,
            right: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.bottom => Positioned(
            bottom: 0,
            height: progress.value * distance,
            right: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.left => Positioned(
            bottom: 0,
            width: progress.value * distance,
            top: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.right => Positioned(
            bottom: 0,
            width: progress.value * distance,
            top: 0,
            right: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.topLeft => Positioned(
            height: progress.value * distance * anchorAlignment.yComponent,
            width: progress.value * distance * anchorAlignment.xComponent,
            top: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.bottomLeft => Positioned(
            height: progress.value * distance * anchorAlignment.yComponent,
            width: progress.value * distance * anchorAlignment.xComponent,
            bottom: 0,
            left: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.bottomRight => Positioned(
            height: progress.value * distance * anchorAlignment.yComponent,
            width: progress.value * distance * anchorAlignment.xComponent,
            bottom: 0,
            right: 0,
            child: child!,
          ),
        AnchorAlignmentOrdinal.topRight => Positioned(
            height: progress.value * distance * anchorAlignment.yComponent,
            width: progress.value * distance * anchorAlignment.xComponent,
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
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    this.anchor,
    this.ignore = false,
    required this.child,
  });
  const _ExpandingActionButton.axisBased({
    this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.anchor,
    this.ignore = false,
    required this.child,
  });

  final double? directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final bool ignore;

  final AnchorAlignmentOrdinal? anchor;
  AnchorAlignmentOrdinal get anchorFromValues =>
      anchor ?? AnchorAlignmentOrdinal.fromDirectionDegrees(directionInDegrees!);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final r1 = Transform.rotate(
          angle: (1.0 - progress.value) * math.pi / 2,
          child: child!,
        );
        final root = ignore && progress.status != AnimationStatus.completed ? IgnorePointer(child: r1) : r1;
        final offset = directionInDegrees == null
            ? Offset(anchor!.xComponent * progress.value * maxDistance,
                anchor!.yComponent * progress.value * maxDistance)
            : anchorFromValues.xComponent == anchorFromValues.xComponent.toInt()
                ? Offset(
                    anchorFromValues.xComponent * progress.value * maxDistance,
                    anchorFromValues.yComponent * progress.value * maxDistance)
                : Offset.fromDirection(
                    (/* anchor?.facingDegrees ??  */ directionInDegrees!) *
                        (math.pi / 180.0),
                    progress.value * maxDistance,
                  );
        switch (anchorFromValues) {
          case AnchorAlignmentOrdinal.top:
            // assert(offset.dx == 0);
            return Positioned(
              // right: /* 4.0 +  */offset.dx,
              top: /* 4.0 +  */ offset.dy,
              child: root,
            );
          case AnchorAlignmentOrdinal.bottom:
            return Positioned(
              // right: /* 4.0 +  */offset.dx,
              bottom: /* 4.0 +  */ offset.dy,
              child: root,
            );
          case AnchorAlignmentOrdinal.left:
            return Positioned(
              left: /* 4.0 +  */ offset.dx,
              // top: /* 4.0 +  */offset.dy,
              child: root,
            );
          case AnchorAlignmentOrdinal.right:
            return Positioned(
              right: /* 4.0 +  */ offset.dx,
              // top: /* 4.0 +  */offset.dy,
              child: root,
            );
          case AnchorAlignmentOrdinal.topLeft:
            return Positioned(
              left: /* 4.0 +  */ offset.dx,
              top: /* 4.0 +  */ offset.dy,
              child: root,
            );
          case AnchorAlignmentOrdinal.bottomLeft:
            return Positioned(
              left: /* 4.0 +  */ offset.dx,
              bottom: /* 4.0 +  */ offset.dy,
              child: root,
            );
          case AnchorAlignmentOrdinal.bottomRight:
            return Positioned(
              right: /* 4.0 +  */ offset.dx,
              bottom: /* 4.0 +  */ offset.dy,
              child: root,
            );
          case AnchorAlignmentOrdinal.topRight:
            return Positioned(
              right: /* 4.0 +  */ offset.dx,
              top: /* 4.0 +  */ offset.dy,
              child: root,
            );
        }
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}