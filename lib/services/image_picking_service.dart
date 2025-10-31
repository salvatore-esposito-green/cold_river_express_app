import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cold_river_express_app/core/platform_factory.dart';
import 'package:uuid/uuid.dart';

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

      if (media == null) return null;

      // Sul web, dobbiamo salvare l'immagine in localStorage invece di usare blob URL
      if (kIsWeb) {
        final bytes = await media.readAsBytes();
        final filename = '${const Uuid().v4()}.jpg';
        final fileService = PlatformFactory.createFileService();
        final savedPath = await fileService.saveImage(bytes, filename);
        return savedPath;
      }

      // Su mobile, usa il path normale
      return media.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }
}
