import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> getPath() async {
  if (Platform.isAndroid) {
    // This method only works on Android.
    return await getExternalStorageDirectory()?.then((dir) => dir?.path);
  } else {
    // For non-Android platforms, use an alternative path.
    return (await getApplicationDocumentsDirectory()).path;
  }
}
