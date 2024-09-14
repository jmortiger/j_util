import 'package:flutter/material.dart';

/// TODO: Finish
mixin AutoSnackbarStateful on State {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarSimple(
    String text, {
    SnackBarAction? action,
    AnimationStyle? snackBarAnimationStyle,
    Duration waitToCloseDuration = const Duration(seconds: 4),
  }) =>
      _$.showCustomSnackBar(
        context,
        SnackBar(
          content: Text(text),
          action: action,
          duration: waitToCloseDuration,
        ),
        waitToCloseDuration: waitToCloseDuration,
        snackBarAnimationStyle: snackBarAnimationStyle,
      );

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showCustomSnackBar(
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
    Duration waitToCloseDuration = const Duration(seconds: 4),
  }) =>
      _$.showCustomSnackBar(
        context,
        snackBar,
        snackBarAnimationStyle: snackBarAnimationStyle,
        waitToCloseDuration: waitToCloseDuration,
      );
}
mixin AutoSnackbar {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarSimple(
    BuildContext context,
    String text, {
    SnackBarAction? action,
    AnimationStyle? snackBarAnimationStyle,
    Duration waitToCloseDuration = const Duration(seconds: 4),
  }) =>
      _$.showSnackBarSimple(
        context,
        text,
        action: action,
        snackBarAnimationStyle: snackBarAnimationStyle,
        waitToCloseDuration: waitToCloseDuration,
      );
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showCustomSnackBar(
    BuildContext context,
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
    Duration waitToCloseDuration = const Duration(seconds: 4),
  }) =>
      _$.showCustomSnackBar(
        context,
        snackBar,
        snackBarAnimationStyle: snackBarAnimationStyle,
        waitToCloseDuration: waitToCloseDuration,
      );
}

class _$ {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackBarSimple(
    BuildContext context,
    String text, {
    SnackBarAction? action,
    AnimationStyle? snackBarAnimationStyle,
    Duration waitToCloseDuration = const Duration(seconds: 4),
  }) {
    return showCustomSnackBar(
      context,
      SnackBar(
        content: Text(text),
        action: action,
        duration: waitToCloseDuration,
      ),
      waitToCloseDuration: waitToCloseDuration,
      snackBarAnimationStyle: snackBarAnimationStyle,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showCustomSnackBar(
    BuildContext context,
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
    Duration waitToCloseDuration = const Duration(seconds: 4),
  }) {
    var r = ScaffoldMessenger.of(context).showSnackBar(
      snackBar,
      snackBarAnimationStyle: snackBarAnimationStyle,
    );
    if (waitToCloseDuration.inMicroseconds > 0) {
      Future.delayed(waitToCloseDuration, () => r.close);
    }
    return r;
  }
}
