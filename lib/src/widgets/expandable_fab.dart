import 'dart:math' as math;
import 'package:flutter/material.dart';

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    this.distance = 112,
    required List<Widget> this.children,
    this.openIcon = const Icon(Icons.create),
    this.closeIcon = const Icon(Icons.close),
    this.disabledTooltip = "",
    this.useDefaultHeroTag = true,
    this.heroTag,
  }) : childrenBuilder = null;
  const ExpandableFab.builder({
    super.key,
    this.initialOpen,
    this.distance = 112,
    required List<Widget> Function(BuildContext context) this.childrenBuilder,
    this.openIcon = const Icon(Icons.create),
    this.closeIcon = const Icon(Icons.close),
    this.disabledTooltip = "",
    this.useDefaultHeroTag = true,
    this.heroTag,
  }) : children = null;

  final Widget openIcon;
  final Widget closeIcon;

  final bool? initialOpen;
  final double distance;
  final List<Widget>? children;
  final List<Widget> Function(BuildContext context)? childrenBuilder;
  final String disabledTooltip;
  final bool useDefaultHeroTag;
  final Object? heroTag;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;
  List<Widget> get children =>
      (widget.childrenBuilder?.call(context) ?? widget.children)!;
  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
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
      _open = !_open;
      if (_open) {
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
        ? SizedBox.expand(
            child: Stack(
              alignment: Alignment.bottomRight,
              clipBehavior: Clip.none,
              children: [
                _buildTapToCloseFab(),
                ...buttons,
                _buildTapToOpenFab(buttons.isNotEmpty),
              ],
            ),
          )
        : IconButton(
            tooltip: widget.disabledTooltip,
            onPressed: null,
            icon: widget.openIcon);
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
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widgetChildren[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab([bool enabled = true]) {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: widget.useDefaultHeroTag
              ? FloatingActionButton(
                  onPressed: enabled ? _toggle : null,
                  child: widget.openIcon,
                )
              : FloatingActionButton(
                  onPressed: enabled ? _toggle : null,
                  child: widget.openIcon,
                  heroTag: widget.heroTag,
                ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  final String? tooltip;

  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.shape = const CircleBorder(),
    this.elevation = 4,
    this.color,
  })  : type = MaterialType.canvas,
        shadowColor = null,
        surfaceTintColor = null,
        textStyle = null,
        borderRadius = null,
        borderOnForeground = true,
        animationDuration = kThemeChangeDuration;
  const ActionButton.full({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.shape = const CircleBorder(),
    this.elevation = 4,
    this.type = MaterialType.canvas,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.borderRadius,
    this.borderOnForeground = true,
    this.animationDuration = kThemeChangeDuration,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final ShapeBorder shape;
  final double elevation;
  final MaterialType type;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final TextStyle? textStyle;
  final BorderRadiusGeometry? borderRadius;
  final bool borderOnForeground;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: shape,
      clipBehavior: Clip.antiAlias,
      color: color ?? theme.colorScheme.secondary,
      elevation: elevation,
      type: type, // MaterialType.canvas,
      shadowColor: shadowColor, // null,
      surfaceTintColor: surfaceTintColor, // null,
      textStyle: textStyle, // null,
      borderRadius: borderRadius, // null,
      borderOnForeground: borderOnForeground, // true,
      animationDuration: animationDuration, // kThemeChangeDuration,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: color ?? theme.colorScheme.onSecondary,
        tooltip: tooltip,
      ),
    );
  }
}

// @immutable
// class FakeItem extends StatelessWidget {
//   const FakeItem({
//     super.key,
//     required this.isBig,
//   });

//   final bool isBig;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
//       height: isBig ? 128 : 36,
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.all(Radius.circular(8)),
//         color: Colors.grey.shade300,
//       ),
//     );
//   }
// }
