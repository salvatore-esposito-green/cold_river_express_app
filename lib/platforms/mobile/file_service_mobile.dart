import 'dart:io';
import 'package:cold_river_express_app/core/interfaces/file_service_interface.dart';
import 'package:cold_river_express_app/services/file_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Implementazione mobile del servizio File System
class FileServiceMobile implements FileServiceInterface {
  final FileService _fileService = FileService();

  @override
  Future<String?> saveImage(List<int> imageBytes, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<int>?> loadImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> imageExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> shareDatabase() async {
    return await _fileService.shareDatabase();
  }

  @override
  Future<bool> sharePdf(List<int> pdfBytes, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      final result = await Share.shareXFiles([XFile(filePath)]);
      return result.status == ShareResultStatus.success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> exportCsv(String csvContent, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsString(csvContent);

      final result = await Share.shareXFiles([XFile(filePath)]);
      return result.status == ShareResultStatus.success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> importFile() async {
    // TODO: Implementare con file_picker
    return null;
  }

  @override
  Future<String> getTempDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  @override
  Future<void> cleanTempFiles() async {
    try {
      final directory = await getTemporaryDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create();
      }
    } catch (e) {
      // Ignore
    }
  }
}
