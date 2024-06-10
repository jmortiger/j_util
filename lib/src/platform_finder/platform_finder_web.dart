import 'package:j_util/src/types.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

Platform getPlatform() => Platform.web;

void registerImgElement() {
  ui.platformViewRegistry.registerViewFactory("imgPostTile",
      (int viewId /* , {Object? params} */) {
    final html.Element htmlElement = html.ImageElement()
      // ..other props
      ..style.width = '100%'
      ..style.height = '100%';
    // ...
    return htmlElement;
  });
}

Object getViewById(int viewId) =>
    ui.platformViewRegistry.getViewById(viewId);
