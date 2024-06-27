import 'package:flutter/material.dart';

class WFoldout extends StatefulWidget {
  final Widget header;
  final Widget body;
  final bool startExpanded;

  /// Callback fired after the state is toggled between expanded and collapsed.
  ///
  /// This is fired before the specific [onExpanded] & [onCollapsed] callbacks.
  ///
  /// [isExpanded] is the value *after* being toggled.
  final void Function(bool isExpanded)? onToggleExpansion;

  /// Callback fired after the state is toggled from collapsed to expanded.
  final void Function()? onExpanded;

  /// Callback fired after the state is toggled from expanded to collapsed.
  final void Function()? onCollapsed;
  const WFoldout({
    super.key,
    required this.header,
    required this.body,
    this.startExpanded = false,
    this.onToggleExpansion,
    this.onExpanded,
    this.onCollapsed,
  });

  /// Shorthand to create a foldout with [Text]/[SelectableText]
  /// widgets for the header and body.
  WFoldout.simple({
    Key? key,
    bool isHeaderSelectable = false,
    required String headerText,
    TextStyle? headerStyle,
    StrutStyle? headerStrutStyle,
    TextAlign? headerTextAlign,
    TextDirection? headerTextDirection,
    Locale? headerLocale,
    bool? headerSoftWrap,
    TextOverflow? headerOverflow,
    TextScaler? headerTextScaler,
    int? headerMaxLines,
    String? headerSemanticsLabel,
    TextWidthBasis? headerTextWidthBasis,
    TextHeightBehavior? headerTextHeightBehavior,
    Color? headerSelectionColor,
    bool isBodySelectable = true,
    required String bodyText,
    TextStyle? bodyStyle,
    StrutStyle? bodyStrutStyle,
    TextAlign? bodyTextAlign,
    TextDirection? bodyTextDirection,
    Locale? bodyLocale,
    bool? bodySoftWrap,
    TextOverflow? bodyOverflow,
    TextScaler? bodyTextScaler,
    int? bodyMaxLines,
    String? bodySemanticsLabel,
    TextWidthBasis? bodyTextWidthBasis,
    TextHeightBehavior? bodyTextHeightBehavior,
    Color? bodySelectionColor,
    bool startExpanded = false,
    void Function(bool isExpanded)? onToggleExpansion,
    void Function()? onExpanded,
    void Function()? onCollapsed,
  }) : this(
          header: isHeaderSelectable
              ? SelectableText(
                  headerText,
                  style: headerStyle,
                  strutStyle: headerStrutStyle,
                  textAlign: headerTextAlign,
                  textDirection: headerTextDirection,
                  // locale: headerLocale,
                  // softWrap: headerSoftWrap,
                  // overflow: headerOverflow,
                  textScaler: headerTextScaler,
                  maxLines: headerMaxLines,
                  semanticsLabel: headerSemanticsLabel,
                  textWidthBasis: headerTextWidthBasis,
                  textHeightBehavior: headerTextHeightBehavior,
                  // selectionColor: headerSelectionColor,
                )
              : Text(
                  headerText,
                  style: headerStyle,
                  strutStyle: headerStrutStyle,
                  textAlign: headerTextAlign,
                  textDirection: headerTextDirection,
                  locale: headerLocale,
                  softWrap: headerSoftWrap,
                  overflow: headerOverflow,
                  textScaler: headerTextScaler,
                  maxLines: headerMaxLines,
                  semanticsLabel: headerSemanticsLabel,
                  textWidthBasis: headerTextWidthBasis,
                  textHeightBehavior: headerTextHeightBehavior,
                  selectionColor: headerSelectionColor,
                ),
          body: isBodySelectable
              ? SelectableText(
                  bodyText,
                  style: bodyStyle,
                  strutStyle: bodyStrutStyle,
                  textAlign: bodyTextAlign,
                  textDirection: bodyTextDirection,
                  // locale: bodyLocale,
                  // softWrap: bodySoftWrap,
                  // overflow: bodyOverflow,
                  textScaler: bodyTextScaler,
                  maxLines: bodyMaxLines,
                  semanticsLabel: bodySemanticsLabel,
                  textWidthBasis: bodyTextWidthBasis,
                  textHeightBehavior: bodyTextHeightBehavior,
                  // selectionColor: bodySelectionColor,
                )
              : Text(
                  bodyText,
                  style: bodyStyle,
                  strutStyle: bodyStrutStyle,
                  textAlign: bodyTextAlign,
                  textDirection: bodyTextDirection,
                  locale: bodyLocale,
                  softWrap: bodySoftWrap,
                  overflow: bodyOverflow,
                  textScaler: bodyTextScaler,
                  maxLines: bodyMaxLines,
                  semanticsLabel: bodySemanticsLabel,
                  textWidthBasis: bodyTextWidthBasis,
                  textHeightBehavior: bodyTextHeightBehavior,
                  selectionColor: bodySelectionColor,
                ),
          key: key,
          onCollapsed: onCollapsed,
          onExpanded: onExpanded,
          onToggleExpansion: onToggleExpansion,
          startExpanded: startExpanded,
        );

  /// Shorthand to create a foldout with a [Text]/[SelectableText]
  /// widget for the body and a custom widget for the header.
  WFoldout.simpleBody({
    Key? key,
    bool isHeaderSelectable = false,
    required Widget header,
    bool isBodySelectable = true,
    required String bodyText,
    TextStyle? bodyStyle,
    StrutStyle? bodyStrutStyle,
    TextAlign? bodyTextAlign,
    TextDirection? bodyTextDirection,
    Locale? bodyLocale,
    bool? bodySoftWrap,
    TextOverflow? bodyOverflow,
    TextScaler? bodyTextScaler,
    int? bodyMaxLines,
    String? bodySemanticsLabel,
    TextWidthBasis? bodyTextWidthBasis,
    TextHeightBehavior? bodyTextHeightBehavior,
    Color? bodySelectionColor,
    bool startExpanded = false,
    void Function(bool isExpanded)? onToggleExpansion,
    void Function()? onExpanded,
    void Function()? onCollapsed,
  }) : this(
          header: header,
          body: isBodySelectable
              ? SelectableText(
                  bodyText,
                  style: bodyStyle,
                  strutStyle: bodyStrutStyle,
                  textAlign: bodyTextAlign,
                  textDirection: bodyTextDirection,
                  // locale: bodyLocale,
                  // softWrap: bodySoftWrap,
                  // overflow: bodyOverflow,
                  textScaler: bodyTextScaler,
                  maxLines: bodyMaxLines,
                  semanticsLabel: bodySemanticsLabel,
                  textWidthBasis: bodyTextWidthBasis,
                  textHeightBehavior: bodyTextHeightBehavior,
                  // selectionColor: bodySelectionColor,
                )
              : Text(
                  bodyText,
                  style: bodyStyle,
                  strutStyle: bodyStrutStyle,
                  textAlign: bodyTextAlign,
                  textDirection: bodyTextDirection,
                  locale: bodyLocale,
                  softWrap: bodySoftWrap,
                  overflow: bodyOverflow,
                  textScaler: bodyTextScaler,
                  maxLines: bodyMaxLines,
                  semanticsLabel: bodySemanticsLabel,
                  textWidthBasis: bodyTextWidthBasis,
                  textHeightBehavior: bodyTextHeightBehavior,
                  selectionColor: bodySelectionColor,
                ),
          key: key,
          onCollapsed: onCollapsed,
          onExpanded: onExpanded,
          onToggleExpansion: onToggleExpansion,
          startExpanded: startExpanded,
        );

  /// Shorthand to create a foldout with a [Text]/[SelectableText]
  /// widget for the header and a custom widget for the body.
  WFoldout.simpleHeader({
    Key? key,
    bool isHeaderSelectable = false,
    required String headerText,
    TextStyle? headerStyle,
    StrutStyle? headerStrutStyle,
    TextAlign? headerTextAlign,
    TextDirection? headerTextDirection,
    Locale? headerLocale,
    bool? headerSoftWrap,
    TextOverflow? headerOverflow,
    TextScaler? headerTextScaler,
    int? headerMaxLines,
    String? headerSemanticsLabel,
    TextWidthBasis? headerTextWidthBasis,
    TextHeightBehavior? headerTextHeightBehavior,
    Color? headerSelectionColor,
    required Widget body,
    bool startExpanded = false,
    void Function(bool isExpanded)? onToggleExpansion,
    void Function()? onExpanded,
    void Function()? onCollapsed,
  }) : this(
          header: isHeaderSelectable
              ? SelectableText(
                  headerText,
                  style: headerStyle,
                  strutStyle: headerStrutStyle,
                  textAlign: headerTextAlign,
                  textDirection: headerTextDirection,
                  // locale: headerLocale,
                  // softWrap: headerSoftWrap,
                  // overflow: headerOverflow,
                  textScaler: headerTextScaler,
                  maxLines: headerMaxLines,
                  semanticsLabel: headerSemanticsLabel,
                  textWidthBasis: headerTextWidthBasis,
                  textHeightBehavior: headerTextHeightBehavior,
                  // selectionColor: headerSelectionColor,
                )
              : Text(
                  headerText,
                  style: headerStyle,
                  strutStyle: headerStrutStyle,
                  textAlign: headerTextAlign,
                  textDirection: headerTextDirection,
                  locale: headerLocale,
                  softWrap: headerSoftWrap,
                  overflow: headerOverflow,
                  textScaler: headerTextScaler,
                  maxLines: headerMaxLines,
                  semanticsLabel: headerSemanticsLabel,
                  textWidthBasis: headerTextWidthBasis,
                  textHeightBehavior: headerTextHeightBehavior,
                  selectionColor: headerSelectionColor,
                ),
          body: body,
          key: key,
          onCollapsed: onCollapsed,
          onExpanded: onExpanded,
          onToggleExpansion: onToggleExpansion,
          startExpanded: startExpanded,
        );

  @override
  State<WFoldout> createState() => _WFoldoutState();
}

class _WFoldoutState extends State<WFoldout> {
  bool isExpanded = false;
  @override
  void initState() {
    super.initState();
    isExpanded = widget.startExpanded;
  }

  void _callback() {
    toggleState();
    widget.onToggleExpansion?.call(isExpanded);
    switch (isExpanded) {
      case true:
        widget.onExpanded?.call();
        break;
      case false:
        widget.onCollapsed?.call();
        break;
    }
  }

  void toggleState() => setState(() {
        isExpanded = !isExpanded;
      });
  @override
  Widget build(BuildContext context) {
    // LinearBorder.bottom()
    return Stack(
      children: [
        isExpanded
            ? widget.header
            : Column(
                children: [
                  widget.header,
                  widget.body,
                ],
              ),
        Positioned.directional(
          textDirection: TextDirection.ltr,
          top: 0,
          bottom: 0,
          end: 0,
          child: IconButton(
            onPressed: _callback,
            icon: isExpanded
                ? const Icon(Icons.arrow_drop_up)
                : const Icon(Icons.arrow_drop_down),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _callback,
            ),
          ),
        ),
      ],
    );
  }
}
