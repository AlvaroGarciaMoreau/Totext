import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

// Importar modelos y servicios
import 'models/text_entry.dart';
import 'services/storage_service.dart';
import 'services/ocr_service.dart';
import 'services/speech_service.dart';
import 'services/image_service.dart';

// Importar widgets y pantallas
import 'widgets/text_display_widget.dart';
import 'widgets/history_list_widget.dart';
import 'widgets/custom_bottom_app_bar.dart';
import 'widgets/camera_options_sheet.dart';

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
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: HomePage(cameras: cameras),
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
  String _extractedText = '';
  bool _isLoading = false;
  final SpeechService _speechService = SpeechService();
  List<TextEntry> _textHistory = [];
  int _selectedIndex = 0;
  bool _isEditing = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initServices();
    _loadData();
  }

  @override
  void dispose() {
    _textController.dispose();
    OcrService.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    await _speechService.initialize();
    setState(() {});
  }

  Future<void> _loadData() async {
    final history = await StorageService.loadTextEntries();
    final currentData = await StorageService.loadCurrentText();
    
    setState(() {
      _textHistory = history;
      _extractedText = currentData['text'] ?? '';
      _textController.text = _extractedText;
    });
  }

  Future<void> _processImageFromCamera() async {
    await _processImageSource(() => ImageService.takePhotoFromCamera());
  }

  Future<void> _processImageFromGallery() async {
    await _processImageSource(() => ImageService.pickImageFromGallery());
  }

  Future<void> _processImageSource(Future<File?> Function() imageSource) async {
    setState(() => _isLoading = true);

    try {
      final imageFile = await imageSource();
      if (imageFile != null) {
        final result = await OcrService.extractTextFromImage(imageFile);
        
        // El nuevo servicio OCR devuelve un Map, extraer el texto
        final extractedText = result['text'] ?? AppConstants.statusNoTextFound;
        
        await _saveExtractedText(extractedText, AppConstants.sourceCamera);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveExtractedText(String text, String source) async {
    if (text != AppConstants.statusNoTextFound) {
      final entry = TextEntry(
        id: TextEntry.generateId(),
        text: text,
        source: source,
        timestamp: DateTime.now(),
      );
      
      await StorageService.addTextEntry(entry);
      await StorageService.saveCurrentText(text, source);
      await _loadData();
      
      setState(() {
        _extractedText = text;
        _textController.text = text;
      });
    } else {
      setState(() => _extractedText = text);
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _extractedText = AppConstants.statusListening;
      _textController.text = AppConstants.statusListening;
    });

    await _speechService.startListening(
      onResult: (text) async {
        await _saveExtractedText(text, AppConstants.sourceMicrophone);
      },
      onError: (error) {
        _showError(error);
        setState(() => _extractedText = '');
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
  }

  void _handleMicrophonePress() {
    if (_speechService.isListening) {
      _stopListening();
    } else if (_speechService.isInitialized) {
      _startListening();
    } else {
      _showError(AppConstants.errorSpeechNotAvailable);
    }
  }

  void _shareText() {
    final textToShare = _isEditing ? _textController.text.trim() : _extractedText;
    if (_isValidTextToShare(textToShare)) {
      Share.share(textToShare, subject: AppConstants.shareSubject);
    } else {
      _showError(AppConstants.errorNoTextToShare);
    }
  }

  bool _isValidTextToShare(String text) {
    return text.isNotEmpty && 
           text != AppConstants.statusListening && 
           text != AppConstants.statusNoAudioDetected && 
           text != AppConstants.statusNoTextFound;
  }

  void _clearText() async {
    await StorageService.clearCurrentText();
    setState(() {
      _extractedText = '';
      _textController.clear();
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _textController.text = _extractedText;
    });
  }

  void _saveEditedText() async {
    final editedText = _textController.text.trim();
    if (editedText.isNotEmpty) {
      // Crear una nueva entrada en el historial para el texto editado
      final entry = TextEntry(
        id: TextEntry.generateId(),
        text: editedText,
        source: AppConstants.sourceEdited,
        timestamp: DateTime.now(),
      );
      
      // Guardar en el historial y como texto actual
      await StorageService.addTextEntry(entry);
      await StorageService.saveCurrentText(editedText, AppConstants.sourceEdited);
      
      // Recargar los datos para actualizar la UI
      await _loadData();
      
      setState(() {
        _extractedText = editedText;
        _isEditing = false;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _textController.text = _extractedText;
    });
  }

  void _selectTextFromHistory(TextEntry entry) async {
    await StorageService.saveCurrentText(entry.text, entry.source);
    setState(() {
      _extractedText = entry.text;
      _textController.text = entry.text;
      _selectedIndex = 0;
      _isEditing = false;
    });
    
    // Recargar datos para asegurar consistencia
    await _loadData();
  }

  void _deleteHistoryEntry(String id) async {
    await StorageService.deleteTextEntry(id);
    await _loadData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_selectedIndex == 0 ? AppConstants.homeTitle : AppConstants.historyTitle),
        actions: [
          if (_selectedIndex == 0 && _extractedText.isNotEmpty && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _startEditing,
              tooltip: AppConstants.tooltipEdit,
            ),
          if (_selectedIndex == 0 && _isEditing)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveEditedText,
                  tooltip: AppConstants.tooltipSave,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _cancelEditing,
                  tooltip: AppConstants.tooltipCancel,
                ),
              ],
            ),
          if (_selectedIndex == 0 && _extractedText.isNotEmpty && !_isEditing)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearText,
              tooltip: AppConstants.tooltipClear,
            ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildMainView() : _buildHistoryView(),
      bottomNavigationBar: CustomBottomAppBar(
        selectedIndex: _selectedIndex,
        isLoading: _isLoading,
        speechEnabled: _speechService.isInitialized,
        isListening: _speechService.isListening,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
        onCameraPressed: () => CameraOptionsSheet.show(
          context,
          onTakePhoto: _processImageFromCamera,
          onSelectGallery: _processImageFromGallery,
        ),
        onMicrophonePressed: _handleMicrophonePress,
      ),
    );
  }

  Widget _buildMainView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: TextDisplayWidget(
              text: _extractedText,
              isLoading: _isLoading,
              isEditing: _isEditing,
              controller: _textController,
              onTap: _startEditing,
              onChanged: (value) {
                // Actualizar en tiempo real mientras edita
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (_isValidTextToShare(_isEditing ? _textController.text.trim() : _extractedText))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareText,
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

  Widget _buildHistoryView() {
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
              textHistory: _textHistory,
              onSelectText: _selectTextFromHistory,
              onDeleteEntry: _deleteHistoryEntry,
            ),
          ),
        ],
      ),
    );
  }
}
