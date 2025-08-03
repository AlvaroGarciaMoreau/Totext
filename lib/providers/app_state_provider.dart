import 'package:flutter/material.dart';
import '../models/text_entry.dart';
import '../database/database_helper.dart';
import '../services/cloud_sync_service.dart';
import '../services/translation_service.dart';

class AppStateProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<TextEntry> _textEntries = [];
  List<TextEntry> _filteredEntries = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedSource = '';
  DateTimeRange? _dateRange;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<TextEntry> get textEntries => _filteredEntries;
  List<TextEntry> get allEntries => _textEntries;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedSource => _selectedSource;
  DateTimeRange? get dateRange => _dateRange;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get totalEntries => _textEntries.length;
  int get filteredCount => _filteredEntries.length;

  Future<void> initialize() async {
    await loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      _setLoading(true);
      _textEntries = await _dbHelper.getAllTextEntries();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar entradas: $e');
      _setLoading(false);
    }
  }

  Future<void> addEntry(TextEntry entry) async {
    try {
      await _dbHelper.insertTextEntry(entry);
      _textEntries.insert(0, entry);
      _applyFilters();
      
      // Intentar sincronizar automáticamente
      CloudSyncService.uploadEntry(entry).catchError((e) {
        // Error al sincronizar entrada: $e
        return SyncResult(success: false, message: 'Error de sincronización');
      });
      
      notifyListeners();
    } catch (e) {
      _setError('Error al agregar entrada: $e');
    }
  }

  Future<void> updateEntry(TextEntry entry) async {
    try {
      await _dbHelper.updateTextEntry(entry);
      int index = _textEntries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _textEntries[index] = entry;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al actualizar entrada: $e');
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _dbHelper.deleteTextEntry(entryId);
      _textEntries.removeWhere((entry) => entry.id == entryId);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar entrada: $e');
    }
  }

  Future<void> deleteMultipleEntries(List<String> entryIds) async {
    try {
      _setLoading(true);
      
      for (String id in entryIds) {
        await _dbHelper.deleteTextEntry(id);
      }
      
      _textEntries.removeWhere((entry) => entryIds.contains(entry.id));
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Error al eliminar entradas: $e');
      _setLoading(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    
    // Guardar consulta de búsqueda
    if (query.isNotEmpty) {
      _dbHelper.saveSearchQuery(query).catchError((e) {
        // Error al guardar consulta de búsqueda: $e
      });
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSource(String source) {
    _selectedSource = source;
    _applyFilters();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedSource = '';
    _dateRange = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredEntries = _textEntries.where((entry) {
      // Filtro de búsqueda
      bool matchesSearch = _searchQuery.isEmpty ||
          entry.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (entry.translatedText?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      // Filtro de categoría
      bool matchesCategory = _selectedCategory.isEmpty || entry.category == _selectedCategory;

      // Filtro de fuente
      bool matchesSource = _selectedSource.isEmpty || entry.source == _selectedSource;

      // Filtro de fecha
      bool matchesDate = _dateRange == null ||
          (entry.timestamp.isAfter(_dateRange!.start) && 
           entry.timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1))));

      return matchesSearch && matchesCategory && matchesSource && matchesDate;
    }).toList();

    notifyListeners();
  }

  Future<void> translateEntry(TextEntry entry, String targetLanguage) async {
    try {
      String? translatedText = await TranslationService.translateText(
        entry.text,
        targetLanguage,
        sourceLanguage: entry.originalLanguage,
      );

      if (translatedText != null) {
        TextEntry updatedEntry = entry.copyWith(
          translatedText: translatedText,
          targetLanguage: targetLanguage,
        );
        await updateEntry(updatedEntry);
      }
    } catch (e) {
      _setError('Error al traducir texto: $e');
    }
  }

  Future<void> categorizeEntry(TextEntry entry, String category) async {
    try {
      TextEntry updatedEntry = entry.copyWith(category: category);
      await updateEntry(updatedEntry);
    } catch (e) {
      _setError('Error al categorizar entrada: $e');
    }
  }

  Future<void> addTagsToEntry(TextEntry entry, List<String> newTags) async {
    try {
      List<String> updatedTags = List.from(entry.tags);
      for (String tag in newTags) {
        if (!updatedTags.contains(tag)) {
          updatedTags.add(tag);
        }
      }
      
      TextEntry updatedEntry = entry.copyWith(tags: updatedTags);
      await updateEntry(updatedEntry);
    } catch (e) {
      _setError('Error al agregar etiquetas: $e');
    }
  }

  Future<void> removeTagsFromEntry(TextEntry entry, List<String> tagsToRemove) async {
    try {
      List<String> updatedTags = List.from(entry.tags);
      updatedTags.removeWhere((tag) => tagsToRemove.contains(tag));
      
      TextEntry updatedEntry = entry.copyWith(tags: updatedTags);
      await updateEntry(updatedEntry);
    } catch (e) {
      _setError('Error al remover etiquetas: $e');
    }
  }

  Future<Map<String, int>> getCategoryStats() async {
    try {
      return await _dbHelper.getCategoryStats();
    } catch (e) {
      _setError('Error al obtener estadísticas de categorías: $e');
      return {};
    }
  }

  Future<Map<String, int>> getSourceStats() async {
    try {
      return await _dbHelper.getSourceStats();
    } catch (e) {
      _setError('Error al obtener estadísticas de fuentes: $e');
      return {};
    }
  }

  Future<List<String>> getSearchHistory() async {
    try {
      return await _dbHelper.getSearchHistory();
    } catch (e) {
      _setError('Error al obtener historial de búsqueda: $e');
      return [];
    }
  }

  List<String> getAllCategories() {
    Set<String> categories = _textEntries.map((entry) => entry.category).toSet();
    return categories.toList()..sort();
  }

  List<String> getAllTags() {
    Set<String> tags = {};
    for (TextEntry entry in _textEntries) {
      tags.addAll(entry.tags);
    }
    return tags.toList()..sort();
  }

  List<String> getAllSources() {
    Set<String> sources = _textEntries.map((entry) => entry.source).toSet();
    return sources.toList()..sort();
  }

  List<TextEntry> getEntriesByCategory(String category) {
    return _textEntries.where((entry) => entry.category == category).toList();
  }

  List<TextEntry> getEntriesBySource(String source) {
    return _textEntries.where((entry) => entry.source == source).toList();
  }

  List<TextEntry> getEntriesByTag(String tag) {
    return _textEntries.where((entry) => entry.tags.contains(tag)).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
    
    // Limpiar error después de unos segundos
    if (error != null) {
      Future.delayed(const Duration(seconds: 5), () {
        if (_error == error) {
          _error = null;
          notifyListeners();
        }
      });
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
