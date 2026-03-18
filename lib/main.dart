import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

// Importar modelos y servicios
import 'models/text_entry.dart';

// Importar widgets y pantallas
import 'widgets/text_display_widget.dart';
import 'widgets/history_list_widget.dart';
import 'widgets/custom_bottom_app_bar.dart';
import 'widgets/camera_options_sheet.dart';
import 'screens/settings_screen.dart';
import 'screens/search_screen.dart';

// Importar providers
import 'providers/theme_provider.dart';
import 'providers/app_state_provider.dart';

// Importar constantes
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquear orientación en vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Obtener las cámaras disponibles
  final cameras = await availableCameras();
  
  // Inicializar servicios básicos
  await _initializeServices();
  
  runApp(MyApp(cameras: cameras));
}

Future<void> _initializeServices() async {
  try {
    // Servicios básicos inicializados
  } catch (e) {
    // Error inicializando servicios: $e
    // En producción, aquí se podría usar un logger apropiado
  }
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return FutureBuilder(
            future: themeProvider.isInitialized ? null : themeProvider.initialize(),
            builder: (context, snapshot) {
              if (!themeProvider.isInitialized) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              
              return MaterialApp(
                title: AppConstants.appTitle,
                debugShowCheckedModeBanner: false,
                theme: themeProvider.lightTheme,
                darkTheme: themeProvider.darkTheme,
                themeMode: themeProvider.themeMode,
                home: HomePage(cameras: cameras),
              );
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const HomePage({super.key, required this.cameras});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isEditing = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar el AppStateProvider después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppStateProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _startEditing(String initialText) {
    setState(() {
      _isEditing = true;
      _textController.text = initialText;
    });
  }

  void _saveEditedText(AppStateProvider provider) async {
    final editedText = _textController.text;
    await provider.saveEditedText(editedText);
    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEditing(String originalText) {
    setState(() {
      _isEditing = false;
      _textController.text = originalText;
    });
  }

  void _selectTextFromHistory(TextEntry entry, AppStateProvider provider) async {
    await provider.saveExtractedText(entry.text, entry.source);
    setState(() {
      _selectedIndex = 0;
      _isEditing = false;
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return AppConstants.homeTitle;
      case 1:
        return AppConstants.historyTitle;
      case 2:
        return AppConstants.searchTitle;
      default:
        return AppConstants.homeTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        // Mostrar error si existe
        if (provider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showError(provider.error!);
            provider.clearError();
          });
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(_getAppBarTitle()),
            actions: [
              if (_selectedIndex == 0 && provider.extractedText.isNotEmpty && !_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _startEditing(provider.extractedText),
                  tooltip: AppConstants.tooltipEdit,
                ),
              if (_selectedIndex == 0 && _isEditing)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _saveEditedText(provider),
                      tooltip: AppConstants.tooltipSave,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _cancelEditing(provider.extractedText),
                      tooltip: AppConstants.tooltipCancel,
                    ),
                  ],
                ),
              if (_selectedIndex == 0 && provider.extractedText.isNotEmpty && !_isEditing)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: provider.clearText,
                  tooltip: AppConstants.tooltipClear,
                ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _openSettings,
                tooltip: AppConstants.tooltipSettings,
              ),
            ],
          ),
          body: _getCurrentView(provider),
          bottomNavigationBar: CustomBottomAppBar(
            selectedIndex: _selectedIndex,
            isLoading: provider.isLoading,
            speechEnabled: provider.isSpeechInitialized,
            isListening: provider.isListening,
            onIndexChanged: (index) => setState(() => _selectedIndex = index),
            onCameraPressed: () => CameraOptionsSheet.show(
              context,
              onTakePhoto: provider.processImageFromCamera,
              onSelectGallery: provider.processImageFromGallery,
            ),
            onMicrophonePressed: provider.handleMicrophonePress,
          ),
        );
      },
    );
  }

  Widget _getCurrentView(AppStateProvider provider) {
    switch (_selectedIndex) {
      case 0:
        return _buildMainView(provider);
      case 1:
        return _buildHistoryView(provider);
      case 2:
        return SearchScreen(appStateProvider: provider);
      default:
        return _buildMainView(provider);
    }
  }

  Widget _buildMainView(AppStateProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: TextDisplayWidget(
              text: provider.extractedText,
              isLoading: provider.isLoading,
              isEditing: _isEditing,
              controller: _textController,
              onTap: () => _startEditing(provider.extractedText),
              onChanged: (value) {},
            ),
          ),
          const SizedBox(height: 16),
          if (provider.extractedText.isNotEmpty && 
              provider.extractedText != AppConstants.statusListening && 
              provider.extractedText != AppConstants.statusNoAudioDetected && 
              provider.extractedText != AppConstants.statusNoTextFound)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => provider.shareText(_isEditing ? _textController.text : provider.extractedText),
                icon: const Icon(Icons.share),
                label: const Text(AppConstants.buttonShareText),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryView(AppStateProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial de textos extraídos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: HistoryListWidget(
              textHistory: provider.allEntries,
              onSelectText: (entry) => _selectTextFromHistory(entry, provider),
              onDeleteEntry: provider.deleteEntry,
            ),
          ),
        ],
      ),
    );
  }
}
