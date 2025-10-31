import 'dart:html' as html;
import 'dart:convert';
import 'package:cold_river_express_app/core/interfaces/file_service_interface.dart';

/// Implementazione web del servizio File System
/// Utilizza localStorage, Blob API e download via anchor element
class FileServiceWeb implements FileServiceInterface {
  static const String _imageStoragePrefix = 'img_';

  @override
  Future<String?> saveImage(List<int> imageBytes, String filename) async {
    try {
      // Converti in base64 per localStorage
      final base64Image = base64Encode(imageBytes);
      final key = '$_imageStoragePrefix$filename';

      html.window.localStorage[key] = base64Image;
      return key; // Ritorna la chiave come "path"
    } catch (e) {
      print('Error saving image to web storage: $e');
      return null;
    }
  }

  @override
  Future<List<int>?> loadImage(String path) async {
    try {
      final base64Image = html.window.localStorage[path];
      if (base64Image != null) {
        return base64Decode(base64Image);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteImage(String path) async {
    try {
      html.window.localStorage.remove(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> imageExists(String path) async {
    return html.window.localStorage.containsKey(path);
  }

  @override
  Future<bool> shareDatabase() async {
    // TODO: Esportare database come JSON e scaricare
    return false;
  }

  @override
  Future<bool> sharePdf(List<int> pdfBytes, String filename) async {
    try {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();

      html.Url.revokeObjectUrl(url);
      return true;
    } catch (e) {
      print('Error sharing PDF: $e');
      return false;
    }
  }

  @override
  Future<bool> exportCsv(String csvContent, String filename) async {
    try {
      final blob = html.Blob([csvContent], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();

      html.Url.revokeObjectUrl(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> importFile() async {
    try {
      final uploadInput = html.FileUploadInputElement()..click();

      await uploadInput.onChange.first;

      final file = uploadInput.files?.first;
      if (file == null) return null;

      final reader = html.FileReader();
      reader.readAsText(file);
      await reader.onLoad.first;

      return reader.result as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> getTempDirectory() async {
    // Il web non ha una directory temporanea fisica
    return 'web://temp';
  }

  @override
  Future<void> cleanTempFiles() async {
    // Pulizia localStorage se necessario
    final keys = html.window.localStorage.keys.where(
      (key) => key.startsWith('temp_'),
    ).toList();

    for (final key in keys) {
      html.window.localStorage.remove(key);
    }
  }
}
