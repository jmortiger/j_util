import 'dart:io' as io show Platform;

import 'package:j_util/src/types.dart';

Platform getPlatform() => switch (io.Platform.operatingSystem) {
  "android" => Platform.android,
  "fuchsia" => Platform.fuchsia,
  "ios" => Platform.iOS,
  "linux" => Platform.linux,
  "macos" => Platform.macOS,
  "windows" => Platform.windows,
  // web
  _ => throw UnimplementedError("Platform.operatingSystem: ${io.Platform.operatingSystem} It shouldn't be possible to see this error unless the # of supported platforms increased or you accessed this function's file directly. Use the library (`import 'package:j_util/platform_finder.dart'`) to access."),
};
// Guarenteed to work
// (io.Platform.isAndroid)
//   ? Platform.android
//     : (io.Platform.isWindows)
//       ? Platform.windows
//       : (io.Platform.isLinux)
//         ? Platform.linux
//         : (io.Platform.isIOS)
//           ? Platform.iOS
//           : (io.Platform.isMacOS)
//             ? Platform.macOS
//             : (io.Platform.isFuchsia)
//               ? Platform.fuchsia
//               : throw UnimplementedError("It shouldn't be possible to see this unless the # of supported platforms increased or you accessed this function's file directly. Use the library to access.");
