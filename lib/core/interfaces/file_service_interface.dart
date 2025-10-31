/// Supporta sia mobile (File System nativo) che web (Browser APIs)
abstract class FileServiceInterface {
  /// Salva un'immagine e ritorna il percorso/ID
  Future<String?> saveImage(List<int> imageBytes, String filename);

  /// Carica un'immagine dal percorso/ID
  Future<List<int>?> loadImage(String path);

  Future<bool> deleteImage(String path);

  Future<bool> imageExists(String path);

  Future<bool> shareDatabase();

  Future<bool> sharePdf(List<int> pdfBytes, String filename);

  Future<bool> exportCsv(String csvContent, String filename);

  Future<String?> importFile();

  Future<String> getTempDirectory();
  Future<void> cleanTempFiles();
}
