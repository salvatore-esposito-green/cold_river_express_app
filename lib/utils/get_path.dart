import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> getPath() async {
  if (kIsWeb) {
    // Web doesn't have file system
    return null;
  }

  if (Platform.isAndroid) {
    return await getExternalStorageDirectory()?.then((dir) => dir?.path);
  } else {
    return (await getApplicationDocumentsDirectory()).path;
  }
}
