import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/theme_preferences.dart';
import '../config/app_config.dart';
import '../services/cloud_sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configuración'),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildThemeSection(themeProvider),
              const SizedBox(height: 20),
              _buildLanguageSection(themeProvider),
              const SizedBox(height: 20),
              _buildAccessibilitySection(themeProvider),
              const SizedBox(height: 20),
              _buildSyncSection(themeProvider),
              const SizedBox(height: 20),
              _buildCategorySection(themeProvider),
              const SizedBox(height: 20),
              _buildAboutSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSection(ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            RadioListTile<AppThemeMode>(
              title: const Text('Claro'),
              value: AppThemeMode.light,
              groupValue: themeProvider.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Oscuro'),
              value: AppThemeMode.dark,
              groupValue: themeProvider.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Automático (del sistema)'),
              value: AppThemeMode.system,
              groupValue: themeProvider.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Idioma',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Idioma de la aplicación'),
              subtitle: Text(AppConfig.translationLanguages[themeProvider.preferences.language] ?? 'Español'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLanguageDialog(themeProvider, false),
            ),
            const Divider(),
            ListTile(
              title: const Text('Idioma por defecto para OCR'),
              subtitle: Text(AppConfig.translationLanguages[themeProvider.preferences.ocrLanguage] ?? 'Español'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLanguageDialog(themeProvider, true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilitySection(ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accesibilidad',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tamaño de fuente'),
              subtitle: Text('${themeProvider.preferences.fontSize.toInt()}px'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: themeProvider.preferences.fontSize,
                  min: AppConfig.minFontSize,
                  max: AppConfig.maxFontSize,
                  divisions: ((AppConfig.maxFontSize - AppConfig.minFontSize) / 2).round(),
                  onChanged: (value) {
                    themeProvider.setFontSize(value);
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Alto contraste'),
              subtitle: const Text('Mejora la legibilidad'),
              value: themeProvider.preferences.highContrast,
              onChanged: (value) {
                themeProvider.setHighContrast(value);
              },
            ),
            SwitchListTile(
              title: const Text('Animaciones reducidas'),
              subtitle: const Text('Reduce las animaciones para mejorar el rendimiento'),
              value: themeProvider.preferences.reducedAnimations,
              onChanged: (value) {
                themeProvider.setReducedAnimations(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection(ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sincronización',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sincronización automática'),
              subtitle: const Text('Sincronizar datos automáticamente en la nube'),
              value: themeProvider.preferences.autoSyncEnabled,
              onChanged: (value) {
                themeProvider.setAutoSyncEnabled(value);
                CloudSyncService.setAutoSyncEnabled(value);
              },
            ),
            ListTile(
              title: const Text('Estado de sincronización'),
              subtitle: const Text('Ver estadísticas de sincronización'),
              trailing: const Icon(Icons.cloud_sync),
              onTap: () => _showSyncStatus(),
            ),
            ListTile(
              title: const Text('Sincronizar ahora'),
              subtitle: const Text('Forzar sincronización manual'),
              trailing: const Icon(Icons.sync),
              onTap: () => _performManualSync(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorización',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Categoría por defecto'),
              subtitle: Text(themeProvider.preferences.defaultCategory),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showCategoryDialog(themeProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acerca de',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Versión'),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.info),
            ),
            ListTile(
              title: const Text('Comandos de voz'),
              subtitle: const Text('Ver lista de comandos disponibles'),
              trailing: const Icon(Icons.mic),
              onTap: () => _showVoiceCommands(),
            ),
            ListTile(
              title: const Text('Restablecer configuración'),
              subtitle: const Text('Volver a los valores por defecto'),
              trailing: const Icon(Icons.refresh),
              onTap: () => _resetSettings(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(ThemeProvider themeProvider, bool isOcrLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isOcrLanguage ? 'Idioma para OCR' : 'Idioma de la aplicación'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: AppConfig.translationLanguages.entries.map((entry) {
              bool isSelected = isOcrLanguage 
                  ? entry.key == themeProvider.preferences.ocrLanguage
                  : entry.key == themeProvider.preferences.language;
              
              return ListTile(
                title: Text(entry.value),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  if (isOcrLanguage) {
                    themeProvider.setOcrLanguage(entry.key);
                  } else {
                    themeProvider.setLanguage(entry.key);
                  }
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Categoría por defecto'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: AppConfig.textCategories.map((category) {
              bool isSelected = category == themeProvider.preferences.defaultCategory;
              
              return ListTile(
                title: Text(category),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  themeProvider.setDefaultCategory(category);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showSyncStatus() {
    // En una implementación real, mostrarías las estadísticas de sincronización
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado de Sincronización'),
        content: const Text('Funcionalidad en desarrollo.\n\nEn la versión final se mostrarán estadísticas detalladas de sincronización.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _performManualSync() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sincronizando...'),
          ],
        ),
      ),
    );

    try {
      await CloudSyncService.syncAll();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronización completada')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en sincronización: $e')),
      );
    }
  }

  void _showVoiceCommands() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comandos de Voz'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: AppConfig.voiceCommands.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key.toUpperCase()),
                children: entry.value.map((command) => 
                  ListTile(
                    title: Text('"$command"'),
                    leading: const Icon(Icons.mic),
                  ),
                ).toList(),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Configuración'),
        content: const Text('¿Estás seguro de que quieres restablecer toda la configuración a los valores por defecto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración restablecida')),
              );
            },
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }
}
