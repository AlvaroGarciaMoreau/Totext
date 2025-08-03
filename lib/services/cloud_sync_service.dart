import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/text_entry.dart';
import '../database/database_helper.dart';
import '../config/app_config.dart';

// Simulación de servicios en la nube - En producción usarías Firebase
class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  static StreamController<SyncStatus>? _syncStatusController;
  static Timer? _syncTimer;
  static bool _isInitialized = false;

  CloudSyncService._internal();

  factory CloudSyncService() => _instance;

  static Stream<SyncStatus> get syncStatusStream {
    _syncStatusController ??= StreamController<SyncStatus>.broadcast();
    return _syncStatusController!.stream;
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    
    // Configurar sincronización automática
    final prefs = await SharedPreferences.getInstance();
    bool autoSyncEnabled = prefs.getBool(AppConfig.autoSyncKey) ?? true;
    
    if (autoSyncEnabled) {
      startAutoSync();
    }

    // Escuchar cambios de conectividad
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none && autoSyncEnabled) {
        syncAll();
      }
    });
  }

  static void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(AppConfig.syncInterval, (timer) {
      syncAll();
    });
  }

  static void stopAutoSync() {
    _syncTimer?.cancel();
  }

  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<SyncResult> syncAll() async {
    if (!await isConnected()) {
      _emitStatus(SyncStatus.noConnection);
      return SyncResult(success: false, message: 'Sin conexión a internet');
    }

    _emitStatus(SyncStatus.syncing);

    try {
      final dbHelper = DatabaseHelper();
      final unsyncedEntries = await dbHelper.getUnsyncedEntries();
      
      int successCount = 0;
      int failCount = 0;
      List<String> errors = [];

      for (TextEntry entry in unsyncedEntries) {
        try {
          bool uploaded = await _uploadEntry(entry);
          if (uploaded) {
            // Marcar como sincronizado en la base de datos local
            TextEntry updatedEntry = entry.copyWith(
              isSynced: true,
              cloudId: entry.id, // En una implementación real, esto sería el ID del servidor
            );
            await dbHelper.updateTextEntry(updatedEntry);
            successCount++;
          } else {
            failCount++;
            errors.add('Error al subir entrada: ${entry.id}');
          }
        } catch (e) {
          failCount++;
          errors.add('Error al sincronizar ${entry.id}: $e');
        }
      }

      // Intentar descargar cambios del servidor
      await _downloadChanges();

      // Actualizar timestamp de última sincronización
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.lastSyncKey, DateTime.now().toIso8601String());

      if (failCount == 0) {
        _emitStatus(SyncStatus.completed);
        return SyncResult(
          success: true,
          message: 'Sincronización completada. $successCount elementos sincronizados.',
          uploadedCount: successCount,
        );
      } else {
        _emitStatus(SyncStatus.partialSuccess);
        return SyncResult(
          success: false,
          message: 'Sincronización parcial. $successCount exitosos, $failCount fallidos.',
          uploadedCount: successCount,
          failedCount: failCount,
          errors: errors,
        );
      }
    } catch (e) {
      _emitStatus(SyncStatus.error);
      return SyncResult(success: false, message: 'Error de sincronización: $e');
    }
  }

  static Future<bool> _uploadEntry(TextEntry entry) async {
    // Simulación de subida a la nube
    // En una implementación real, usarías Firebase Firestore o similar
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simular latencia de red
    
    // Simular éxito en el 95% de los casos
    return DateTime.now().millisecond % 20 != 0;
  }

  static Future<void> _downloadChanges() async {
    // Simulación de descarga de cambios del servidor
    // En una implementación real, consultarías el servidor por cambios nuevos
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Aquí implementarías la lógica para:
    // 1. Consultar el servidor por cambios desde la última sincronización
    // 2. Descargar entradas nuevas o modificadas
    // 3. Resolver conflictos de sincronización
    // 4. Actualizar la base de datos local
  }

  static Future<SyncResult> uploadEntry(TextEntry entry) async {
    if (!await isConnected()) {
      return SyncResult(success: false, message: 'Sin conexión a internet');
    }

    try {
      bool uploaded = await _uploadEntry(entry);
      if (uploaded) {
        final dbHelper = DatabaseHelper();
        TextEntry updatedEntry = entry.copyWith(isSynced: true, cloudId: entry.id);
        await dbHelper.updateTextEntry(updatedEntry);
        
        return SyncResult(
          success: true,
          message: 'Entrada sincronizada exitosamente',
          uploadedCount: 1,
        );
      } else {
        return SyncResult(success: false, message: 'Error al subir la entrada');
      }
    } catch (e) {
      return SyncResult(success: false, message: 'Error: $e');
    }
  }

  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastSyncString = prefs.getString(AppConfig.lastSyncKey);
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  static Future<void> setAutoSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.autoSyncKey, enabled);
    
    if (enabled) {
      startAutoSync();
    } else {
      stopAutoSync();
    }
  }

  static Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConfig.autoSyncKey) ?? true;
  }

  static void _emitStatus(SyncStatus status) {
    _syncStatusController?.add(status);
  }

  static Future<SyncStats> getSyncStats() async {
    final dbHelper = DatabaseHelper();
    final allEntries = await dbHelper.getAllTextEntries();
    final unsyncedEntries = await dbHelper.getUnsyncedEntries();
    final lastSync = await getLastSyncTime();
    
    return SyncStats(
      totalEntries: allEntries.length,
      syncedEntries: allEntries.length - unsyncedEntries.length,
      unsyncedEntries: unsyncedEntries.length,
      lastSyncTime: lastSync,
      isAutoSyncEnabled: await isAutoSyncEnabled(),
    );
  }

  static void dispose() {
    _syncTimer?.cancel();
    _syncStatusController?.close();
    _isInitialized = false;
  }
}

enum SyncStatus {
  idle,
  syncing,
  completed,
  partialSuccess,
  error,
  noConnection,
}

class SyncResult {
  final bool success;
  final String message;
  final int uploadedCount;
  final int failedCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    this.uploadedCount = 0,
    this.failedCount = 0,
    this.errors = const [],
  });
}

class SyncStats {
  final int totalEntries;
  final int syncedEntries;
  final int unsyncedEntries;
  final DateTime? lastSyncTime;
  final bool isAutoSyncEnabled;

  SyncStats({
    required this.totalEntries,
    required this.syncedEntries,
    required this.unsyncedEntries,
    this.lastSyncTime,
    required this.isAutoSyncEnabled,
  });

  double get syncPercentage {
    if (totalEntries == 0) return 100.0;
    return (syncedEntries / totalEntries) * 100;
  }
}
