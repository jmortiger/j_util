import 'dart:convert';
import 'dart:io';

import 'package:j_util/src/types.dart';

/// TODO: Add local_storage support for web testing.
mixin Storable<T> {
  final file = LateFinal<File>();
  final _exists = LateInstance<bool>();
  void initStorage(String filePath) => file.$ = File(filePath);
  T get instance => this as T;

  void initStorageSync(String filePath) {
    file.$ = File(filePath);
    _exists.$ = file.$.existsSync();
    if (!_exists.$) {
      file.$.createSync(recursive: true);
      _exists.$ = true;
    }
  }

  Future<void> initStorageAsync(String filePath) async {
    file.$ = File(filePath);
    var v = (await file.$.exists());
    _exists.$ = v;
    if (!v) {
      await file.$.create(recursive: true);
      _exists.$ = true;
    }
  }

  static File? handleInitStorageSync(String filePath) {
    try {
      var f = File(filePath);
      if (!f.existsSync()) {
        f.createSync(recursive: true);
      }
      return f;
    } catch (e) {
      print("Storable.handleInitStorageSync: $e");
      return null;
    }
  }

  static Future<File?> handleInitStorageAsync(String filePath) {
    try {
      File f = File(filePath);
      return f
          .exists()
          .then<File?>((v) async => (!v) ? await f.create(recursive: true) : f)
          .onError((e, s) {
        print("Storable.handleInitStorageAsync: $e");
        print("$s");
        return null;
      });
    } catch (e) {
      print("Storable.handleInitStorageAsync: $e");
      return Future.sync(() => null);
    }
  }

  T loadSync({Encoding encoding = utf8}) {
    if (!file.isAssigned || !_exists.isAssigned || !_exists.$) {
      throw StateError("File not loaded/existent.");
    }
    return ((T as dynamic).fromJson(jsonDecode(
      file.$.readAsStringSync(encoding: encoding),
    ))) as T;
  }

  T? tryLoadSync({Encoding encoding = utf8}) {
    try {
      return loadSync(encoding: encoding);
    } catch (e) {
      return null;
    }
  }

  Future<T> loadAsync({Encoding encoding = utf8}) {
    if (!file.isAssigned || !_exists.isAssigned || !_exists.$) {
      throw StateError("File not loaded/existent.");
    }
    return file.$
        .readAsString(encoding: encoding)
        .then((v) => ((T as dynamic).fromJson(jsonDecode(v))) as T);
  }

  Future<T?> tryLoadAsync({Encoding encoding = utf8}) {
    try {
      return (loadAsync(encoding: encoding) as Future<T?>).onError((e, s) {
        print(e);
        return null;
      });
    } catch (e) {
      return Future.sync(() => null);
    }
  }

  void writeSync({
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    if (!file.isAssigned || !_exists.isAssigned || !_exists.$) {
      throw StateError("File not loaded/existent.");
    }
    file.$.writeAsStringSync(
      jsonEncode((instance as dynamic).toJson()),
      encoding: encoding,
      flush: flush,
      mode: mode,
    );
  }

  bool tryWriteSync(
    T contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    try {
      writeSync(
        encoding: encoding,
        flush: flush,
        mode: mode,
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// {@template WriteAsStringAdapted}
  /// Writes this [T] as a JSON string to a file.
  ///
  /// Opens the file, writes the string in the given encoding, and closes the file. Returns a [Future] that completes once the entire operation has completed.
  ///
  /// By default [writeAsString] creates the file for writing and truncates the file if it already exists. In order to append the bytes to an existing file, pass [FileMode.append] as the optional mode parameter.
  ///
  /// If the argument [flush] is set to true, the data written will be flushed to the file system before the returned future completes.
  ///
  /// This method does not transform newline characters ("\n") to the platform conventional line ending (e.g. "\r\n" on Windows). Use [Platform.lineTerminator] to separate lines in [contents] if platform conventional line endings are needed.
  /// {@endtemplate}
  Future<void> writeAsync({
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    if (!file.isAssigned || !_exists.isAssigned || !_exists.$) {
      throw StateError("File not loaded/existent.");
    }
    return file.$.writeAsString(
      jsonEncode((instance as dynamic).toJson()),
      encoding: encoding,
      flush: flush,
      mode: mode,
    );
  }

  /// {@macro WriteAsStringAdapted}
  Future<bool> tryWriteAsync({
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    try {
      return (((writeAsync(
        encoding: encoding,
        flush: flush,
        mode: mode,
      ).then((_) => true))).onError((e, s) {
        print(e);
        print(s);
        return false;
      }));
    } catch (e) {
      print(e);
      return Future.sync(() => false);
    }
  }

  /// true for success false for error
  static bool _errorCheck(String filePath) => (filePath.isEmpty)
      ? throw ArgumentError.value(
          filePath, "filePath", "must be a path to a file")
      : true;

  static File getStorageSync(String filePath) {
    _errorCheck(filePath);
    File file = File(filePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  static Future<File> getStorageAsync(String filePath) {
    _errorCheck(filePath);
    var file = File(filePath);
    return file.exists().then((v) {
      if (!v) {
        return file.create(recursive: true);
      } else {
        return file;
      }
    });
  }

  static T loadToInstanceSync<T>(String filePath, {Encoding encoding = utf8}) {
    File file = getStorageSync(filePath);
    return ((T as dynamic).fromJson(jsonDecode(
      file.readAsStringSync(encoding: encoding),
    ))) as T;
  }

  static T? tryLoadToInstanceSync<T>(String filePath,
      {Encoding encoding = utf8}) {
    try {
      return loadToInstanceSync(filePath, encoding: encoding);
    } catch (e) {
      return null;
    }
  }

  static Future<T> loadToInstanceAsync<T>(
    String filePath, {
    Encoding encoding = utf8,
  }) {
    return getStorageAsync(filePath)
        .then((file) => file.readAsString(encoding: encoding).then((v) {
              return ((T as dynamic).fromJson(jsonDecode(v))) as T;
            }));
  }

  static Future<T?> tryLoadToInstanceAsync<T>(String filePath,
      {Encoding encoding = utf8}) {
    try {
      return (Storable.getStorageAsync(filePath)
          .then((file) => file.readAsString(encoding: encoding).then((v) {
                return ((T as dynamic).fromJson(jsonDecode(v))) as T?;
              }))).onError((e, s) {
        print("tryLoadToInstanceAsync: $e");
        print(getStorageSync(filePath).readAsStringSync());
        return null;
      });
    } catch (e) {
      print("tryLoadToInstanceAsync: $e");
      try {
        print(getStorageSync(filePath).readAsStringSync());
      } catch (e) {
        print("can't print current value");
        return Future.sync(() => null);
      }
      return Future.sync(() => null);
    }
  }

  static Future<String?> tryLoadStringAsync(String filePath,
      {Encoding encoding = utf8}) {
    try {
      // if (Platform.isWeb) {
      //   return
      // }
      return (Storable.getStorageAsync(filePath).then((file) => file
          .readAsString(encoding: encoding)
          /* .then((v) {
          return ((T as dynamic).fromJson(jsonDecode(v))) as T?;
        }) */
          .then((v) => v ?? null))).onError((e, s) {
        print("tryLoadStringAsync: $e");
        print(getStorageSync(filePath).readAsStringSync());
        return null;
      });
    } catch (e) {
      print("tryLoadStringAsync: $e");
      try {
        print(getStorageSync(filePath).readAsStringSync());
      } catch (e) {
        print("can't print current value");
        return Future.sync(() => null);
      }
      return Future.sync(() => null);
    } /*  finally {
      return Future.sync(() => null);
    } */
  }

  static String? tryLoadStringSync(String filePath,
      {Encoding encoding = utf8}) {
    try {
      return Storable.getStorageSync(filePath)
          .readAsStringSync(encoding: encoding);
    } catch (e) {
      print("tryLoadStringSync: $e");
      try {
        print(getStorageSync(filePath).readAsStringSync());
      } catch (e) {
        print("can't print current value");
        return null;
      }
      return null;
    } /* finally {
      return null;
    } */
  }
}
