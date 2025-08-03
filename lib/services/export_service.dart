import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/text_entry.dart';
import '../config/app_config.dart';

class ExportService {
  static Future<String> exportToTxt(List<TextEntry> entries) async {
    StringBuffer buffer = StringBuffer();
    
    buffer.writeln('=== HISTORIAL DE TEXTO EXTRAÍDO ===');
    buffer.writeln('Exportado el: ${DateTime.now().toString()}');
    buffer.writeln('Total de entradas: ${entries.length}');
    buffer.writeln('${'=' * 50}\n');
    
    for (TextEntry entry in entries) {
      buffer.writeln('Fecha: ${entry.timestamp.toString()}');
      buffer.writeln('Fuente: ${entry.source}');
      buffer.writeln('Categoría: ${entry.category}');
      if (entry.tags.isNotEmpty) {
        buffer.writeln('Etiquetas: ${entry.tags.join(', ')}');
      }
      if (entry.originalLanguage != null) {
        buffer.writeln('Idioma: ${entry.originalLanguage}');
      }
      if (entry.confidence != null) {
        buffer.writeln('Confianza: ${entry.confidence!.toStringAsFixed(1)}%');
      }
      buffer.writeln('Texto:');
      buffer.writeln(entry.text);
      
      if (entry.translatedText != null && entry.translatedText!.isNotEmpty) {
        buffer.writeln('\nTraducción (${entry.targetLanguage}):');
        buffer.writeln(entry.translatedText);
      }
      
      buffer.writeln('\n${'_' * 50}\n');
    }
    
    return buffer.toString();
  }

  static Future<String> exportToJson(List<TextEntry> entries) async {
    Map<String, dynamic> exportData = {
      'export_info': {
        'app_name': 'ToText',
        'version': '1.0.0',
        'export_date': DateTime.now().toIso8601String(),
        'total_entries': entries.length,
      },
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
    
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(exportData);
  }

  static Future<File> exportToPdf(List<TextEntry> entries) async {
    final pdf = pw.Document();
    
    // Configurar fuente
    final font = await _loadFont();
    
    // Crear páginas
    final chunks = _chunkEntries(entries, 5); // 5 entradas por página
    
    for (List<TextEntry> chunk in chunks) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) => [
            if (chunk == chunks.first) _buildHeader(),
            ...chunk.map((entry) => _buildEntryWidget(entry, font)),
          ],
        ),
      );
    }
    
    // Guardar archivo
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/historial_texto_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Historial de Texto Extraído',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Exportado el: ${DateTime.now().toString()}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Divider(),
        ],
      ),
    );
  }

  static pw.Widget _buildEntryWidget(TextEntry entry, pw.Font font) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                entry.source.toUpperCase(),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Categoría: ${entry.category}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          if (entry.tags.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              'Etiquetas: ${entry.tags.join(', ')}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
          pw.SizedBox(height: 10),
          pw.Text(
            entry.text,
            style: pw.TextStyle(font: font),
          ),
          if (entry.translatedText != null && entry.translatedText!.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              'Traducción (${entry.targetLanguage}):',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              entry.translatedText!,
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  static Future<pw.Font> _loadFont() async {
    // En una implementación real, cargarías una fuente que soporte múltiples idiomas
    // Por ahora usamos la fuente por defecto
    return pw.Font.helvetica();
  }

  static List<List<TextEntry>> _chunkEntries(List<TextEntry> entries, int chunkSize) {
    List<List<TextEntry>> chunks = [];
    for (int i = 0; i < entries.length; i += chunkSize) {
      chunks.add(entries.sublist(i, i + chunkSize > entries.length ? entries.length : i + chunkSize));
    }
    return chunks;
  }

  static Future<File> saveToFile(String content, String filename, String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename.$extension');
    await file.writeAsString(content);
    return file;
  }

  static Future<void> shareFile(File file, String title) async {
    await Share.shareXFiles([XFile(file.path)], text: title);
  }

  static Future<void> shareText(String text, String title) async {
    await Share.share(text, subject: title);
  }

  static Future<void> exportAndShare(
    List<TextEntry> entries,
    String format, {
    String? customFilename,
  }) async {
    String filename = customFilename ?? 'historial_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      switch (format.toUpperCase()) {
        case 'TXT':
          String content = await exportToTxt(entries);
          File file = await saveToFile(content, filename, 'txt');
          await shareFile(file, 'Historial de Texto');
          break;
          
        case 'JSON':
          String content = await exportToJson(entries);
          File file = await saveToFile(content, filename, 'json');
          await shareFile(file, 'Datos de Historial');
          break;
          
        case 'PDF':
          File file = await exportToPdf(entries);
          await shareFile(file, 'Historial de Texto PDF');
          break;
          
        default:
          throw Exception('Formato no soportado: $format');
      }
    } catch (e) {
      throw Exception('Error al exportar: $e');
    }
  }

  static List<String> getSupportedFormats() {
    return AppConfig.exportFormats;
  }

  static Future<Map<String, dynamic>> getExportStats(List<TextEntry> entries) async {
    Map<String, int> categoryCounts = {};
    Map<String, int> sourceCounts = {};
    int totalCharacters = 0;
    int translatedCount = 0;
    
    for (TextEntry entry in entries) {
      categoryCounts[entry.category] = (categoryCounts[entry.category] ?? 0) + 1;
      sourceCounts[entry.source] = (sourceCounts[entry.source] ?? 0) + 1;
      totalCharacters += entry.text.length;
      if (entry.translatedText != null && entry.translatedText!.isNotEmpty) {
        translatedCount++;
      }
    }
    
    return {
      'total_entries': entries.length,
      'total_characters': totalCharacters,
      'translated_entries': translatedCount,
      'categories': categoryCounts,
      'sources': sourceCounts,
      'date_range': {
        'from': entries.isEmpty ? null : entries.last.timestamp.toIso8601String(),
        'to': entries.isEmpty ? null : entries.first.timestamp.toIso8601String(),
      },
    };
  }
}
