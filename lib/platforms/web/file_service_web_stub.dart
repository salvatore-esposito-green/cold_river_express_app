import 'package:cold_river_express_app/core/interfaces/file_service_interface.dart';

class FileServiceWeb implements FileServiceInterface {
  @override Future<String?> saveImage(List<int> imageBytes, String filename) => throw UnimplementedError();
  @override Future<List<int>?> loadImage(String path) => throw UnimplementedError();
  @override Future<bool> deleteImage(String path) => throw UnimplementedError();
  @override Future<bool> imageExists(String path) => throw UnimplementedError();
  @override Future<bool> shareDatabase() => throw UnimplementedError();
  @override Future<bool> sharePdf(List<int> pdfBytes, String filename) => throw UnimplementedError();
  @override Future<bool> exportCsv(String csvContent, String filename) => throw UnimplementedError();
  @override Future<String?> importFile() => throw UnimplementedError();
  @override Future<String> getTempDirectory() => throw UnimplementedError();
  @override Future<void> cleanTempFiles() => throw UnimplementedError();
}
