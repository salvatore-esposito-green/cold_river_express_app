import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/core/platform_factory.dart';

/// Widget per visualizzare immagini in modo cross-platform
/// Su mobile usa Image.file, su web carica i bytes e usa Image.memory
class PlatformImage extends StatelessWidget {
  final String imagePath;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const PlatformImage({
    super.key,
    required this.imagePath,
    this.fit,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Su web, usa FutureBuilder per caricare i bytes
      return FutureBuilder<Uint8List?>(
        future: _loadImageBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
              return Image.memory(
                snapshot.data!,
                fit: fit,
                width: width,
                height: height,
                errorBuilder: errorWidget != null
                    ? (context, error, stackTrace) => errorWidget!
                    : null,
              );
            } else {
              return errorWidget ??
                  Container(
                    width: width,
                    height: height,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
            }
          } else {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
        },
      );
    } else {
      // Su mobile, usa Image.file direttamente
      return Image.file(
        File(imagePath),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorWidget != null
            ? (context, error, stackTrace) => errorWidget!
            : null,
      );
    }
  }

  Future<Uint8List?> _loadImageBytes() async {
    try {
      final fileService = PlatformFactory.createFileService();
      final bytes = await fileService.loadImage(imagePath);
      return bytes != null ? Uint8List.fromList(bytes) : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading image bytes: $e');
      }
      return null;
    }
  }
}
