import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickingService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage({
    ImageSource source = ImageSource.camera,
    double maxWidth = 1024.0,
    double maxHeight = 768.0,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? media = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return media?.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }
}
