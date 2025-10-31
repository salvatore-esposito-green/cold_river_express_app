import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> getPath() async {
  if (kIsWeb) {
    // Web doesn't have file system
    return null;
  }

  if (Platform.isAndroid) {
    // This method only works on Android.
    return await getExternalStorageDirectory()?.then((dir) => dir?.path);
  } else {
    // For non-Android platforms, use an alternative path.
    return (await getApplicationDocumentsDirectory()).path;
  }
}
