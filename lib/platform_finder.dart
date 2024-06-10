/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

export 'src/platform_finder/platform_finder_stub.dart'
  if (dart.library.io) 'src/platform_finder/platform_finder_native.dart'
  if (dart.library.js_interop) 'src/platform_finder/platform_finder_web.dart';
export 'src/types.dart' show Platform;
// export 'src/types.dart';
