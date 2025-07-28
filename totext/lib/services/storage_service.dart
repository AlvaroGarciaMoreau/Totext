import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/text_entry.dart';

class StorageService {
  static const String _keyTextEntries = 'text_entries';
  static const String _keyCurrentText = 'current_text';
  static const String _keyCurrentSource = 'current_source';

  // Guardar lista de entradas de texto
  static Future<void> saveTextEntries(List<TextEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    await prefs.setString(_keyTextEntries, json.encode(jsonList));
  }

  // Cargar lista de entradas de texto
  static Future<List<TextEntry>> loadTextEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTextEntries);
    
    if (jsonString == null) {
      return [];
    }

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => TextEntry.fromJson(json)).toList();
  }

  // Agregar nueva entrada de texto
  static Future<void> addTextEntry(TextEntry entry) async {
    final entries = await loadTextEntries();
    entries.insert(0, entry); // Agregar al principio de la lista
    
    // Limitar a las últimas 50 entradas
    if (entries.length > 50) {
      entries.removeRange(50, entries.length);
    }
    
    await saveTextEntries(entries);
  }

  // Eliminar entrada de texto
  static Future<void> deleteTextEntry(String id) async {
    final entries = await loadTextEntries();
    entries.removeWhere((entry) => entry.id == id);
    await saveTextEntries(entries);
  }

  // Guardar texto actual
  static Future<void> saveCurrentText(String text, String source) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentText, text);
    await prefs.setString(_keyCurrentSource, source);
  }

  // Cargar texto actual
  static Future<Map<String, String>> loadCurrentText() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_keyCurrentText) ?? '';
    final source = prefs.getString(_keyCurrentSource) ?? '';
    return {'text': text, 'source': source};
  }

  // Limpiar texto actual
  static Future<void> clearCurrentText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentText);
    await prefs.remove(_keyCurrentSource);
  }
}
