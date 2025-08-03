import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import '../config/app_config.dart';

class CompressionService {
  static Future<File> compressImage(
    File imageFile, {
    int? quality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // Leer la imagen
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar si es necesario
      int targetWidth = maxWidth ?? AppConfig.maxImageDimension;
      int targetHeight = maxHeight ?? AppConfig.maxImageDimension;
      
      if (image.width > targetWidth || image.height > targetHeight) {
        image = img.copyResize(
          image,
          width: image.width > targetWidth ? targetWidth : null,
          height: image.height > targetHeight ? targetHeight : null,
          maintainAspect: true,
        );
      }

      // Comprimir la imagen
      int compressionQuality = quality ?? AppConfig.imageCompressionQuality;
      List<int> compressedBytes = img.encodeJpg(image, quality: compressionQuality);

      // Crear archivo temporal comprimido
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      throw Exception('Error al comprimir imagen: $e');
    }
  }

  static Future<List<File>> compressBatch(
    List<File> imageFiles, {
    int? quality,
    int? maxWidth,
    int? maxHeight,
    Function(int, int)? onProgress,
  }) async {
    List<File> compressedFiles = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        File compressedFile = await compressImage(
          imageFiles[i],
          quality: quality,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
        compressedFiles.add(compressedFile);
        onProgress?.call(i + 1, imageFiles.length);
      } catch (e) {
        // Error comprimiendo imagen ${imageFiles[i].path}: $e
        // En caso de error, usar el archivo original
        compressedFiles.add(imageFiles[i]);
        onProgress?.call(i + 1, imageFiles.length);
      }
    }
    
    return compressedFiles;
  }

  static Future<File> createArchive(
    List<File> files,
    String archiveName, {
    ArchiveFormat format = ArchiveFormat.zip,
  }) async {
    try {
      Archive archive = Archive();

      for (File file in files) {
        Uint8List fileBytes = await file.readAsBytes();
        String fileName = file.path.split('/').last;
        
        ArchiveFile archiveFile = ArchiveFile(
          fileName,
          fileBytes.length,
          fileBytes,
        );
        archive.addFile(archiveFile);
      }

      Uint8List archiveBytes;
      String extension;

      switch (format) {
        case ArchiveFormat.zip:
          archiveBytes = Uint8List.fromList(ZipEncoder().encode(archive));
          extension = 'zip';
          break;
        case ArchiveFormat.tar:
          final tarData = TarEncoder().encode(archive);
          archiveBytes = Uint8List.fromList(tarData);
          extension = 'tar';
          break;
        case ArchiveFormat.gzip:
          // GZIP no soportado en esta versión, usar ZIP como alternativa
          archiveBytes = Uint8List.fromList(ZipEncoder().encode(archive));
          extension = 'zip';
          break;
      }

      final tempDir = await getTemporaryDirectory();
      final archiveFile = File('${tempDir.path}/$archiveName.$extension');
      await archiveFile.writeAsBytes(archiveBytes);

      return archiveFile;
    } catch (e) {
      throw Exception('Error al crear archivo: $e');
    }
  }

  static Future<List<File>> extractArchive(File archiveFile) async {
    try {
      Uint8List archiveBytes = await archiveFile.readAsBytes();
      Archive archive;

      String extension = archiveFile.path.split('.').last.toLowerCase();
      
      switch (extension) {
        case 'zip':
          archive = ZipDecoder().decodeBytes(archiveBytes);
          break;
        case 'tar':
          archive = TarDecoder().decodeBytes(archiveBytes);
          break;
        case 'gz':
          List<int> decompressedBytes = GZipDecoder().decodeBytes(archiveBytes);
          archive = TarDecoder().decodeBytes(decompressedBytes);
          break;
        default:
          throw Exception('Formato de archivo no soportado: $extension');
      }

      final tempDir = await getTemporaryDirectory();
      List<File> extractedFiles = [];

      for (ArchiveFile file in archive) {
        if (file.isFile) {
          File extractedFile = File('${tempDir.path}/${file.name}');
          await extractedFile.writeAsBytes(file.content as List<int>);
          extractedFiles.add(extractedFile);
        }
      }

      return extractedFiles;
    } catch (e) {
      throw Exception('Error al extraer archivo: $e');
    }
  }

  static Future<CompressionStats> getCompressionStats(
    File originalFile,
    File compressedFile,
  ) async {
    int originalSize = await originalFile.length();
    int compressedSize = await compressedFile.length();
    
    double compressionRatio = originalSize > 0 ? (compressedSize / originalSize) : 1.0;
    double spaceSaved = originalSize > 0 ? (1 - compressionRatio) * 100 : 0.0;
    
    return CompressionStats(
      originalSize: originalSize,
      compressedSize: compressedSize,
      compressionRatio: compressionRatio,
      spaceSavedPercentage: spaceSaved,
    );
  }

  static Future<BatchCompressionStats> getBatchCompressionStats(
    List<File> originalFiles,
    List<File> compressedFiles,
  ) async {
    int totalOriginalSize = 0;
    int totalCompressedSize = 0;
    
    for (File file in originalFiles) {
      totalOriginalSize += await file.length();
    }
    
    for (File file in compressedFiles) {
      totalCompressedSize += await file.length();
    }
    
    double compressionRatio = totalOriginalSize > 0 ? (totalCompressedSize / totalOriginalSize) : 1.0;
    double spaceSaved = totalOriginalSize > 0 ? (1 - compressionRatio) * 100 : 0.0;
    
    return BatchCompressionStats(
      totalFiles: originalFiles.length,
      totalOriginalSize: totalOriginalSize,
      totalCompressedSize: totalCompressedSize,
      compressionRatio: compressionRatio,
      spaceSavedPercentage: spaceSaved,
    );
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Future<bool> isImageFile(File file) async {
    try {
      String extension = file.path.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
    } catch (e) {
      return false;
    }
  }

  static Future<img.Image?> getImageInfo(File imageFile) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      return img.decodeImage(imageBytes);
    } catch (e) {
      return null;
    }
  }
}

enum ArchiveFormat {
  zip,
  tar,
  gzip,
}

class CompressionStats {
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final double spaceSavedPercentage;

  CompressionStats({
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.spaceSavedPercentage,
  });

  String get originalSizeFormatted => CompressionService.formatFileSize(originalSize);
  String get compressedSizeFormatted => CompressionService.formatFileSize(compressedSize);
}

class BatchCompressionStats {
  final int totalFiles;
  final int totalOriginalSize;
  final int totalCompressedSize;
  final double compressionRatio;
  final double spaceSavedPercentage;

  BatchCompressionStats({
    required this.totalFiles,
    required this.totalOriginalSize,
    required this.totalCompressedSize,
    required this.compressionRatio,
    required this.spaceSavedPercentage,
  });

  String get totalOriginalSizeFormatted => CompressionService.formatFileSize(totalOriginalSize);
  String get totalCompressedSizeFormatted => CompressionService.formatFileSize(totalCompressedSize);
}
