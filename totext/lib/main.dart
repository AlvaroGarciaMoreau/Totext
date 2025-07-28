import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:speech_to_text/speech_to_text.dart'; // Temporalmente comentado
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'models/text_entry.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquear orientación en vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Obtener las cámaras disponibles
  final cameras = await availableCameras();
  
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToText - OCR y Voz a Texto',
      debugShowCheckedModeBanner: false, // Quitar debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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
  // final SpeechToText _speechToText = SpeechToText(); // Temporalmente comentado
  final bool _speechEnabled = false; // Temporalmente deshabilitado
  bool _isListening = false;
  List<TextEntry> _textHistory = [];
  int _selectedIndex = 0;
  bool _isEditing = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _initSpeech(); // Temporalmente comentado
    _loadData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // void _initSpeech() async {
  //   _speechEnabled = await _speechToText.initialize();
  //   setState(() {});
  // }

  Future<void> _loadData() async {
    // Cargar historial de textos
    final history = await StorageService.loadTextEntries();
    
    // Cargar texto actual
    final currentData = await StorageService.loadCurrentText();
    
    setState(() {
      _textHistory = history;
      _extractedText = currentData['text'] ?? '';
      _textController.text = _extractedText;
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  Future<void> _takePhotoAndExtractText() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _requestPermissions();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showError('Error al tomar la foto: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _requestPermissions();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showError('Error al seleccionar la imagen: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String extractedText = recognizedText.text;
      
      if (extractedText.isNotEmpty) {
        // Crear nueva entrada y guardarla
        final entry = TextEntry(
          id: TextEntry.generateId(),
          text: extractedText,
          source: 'camera',
          timestamp: DateTime.now(),
        );
        
        await StorageService.addTextEntry(entry);
        await StorageService.saveCurrentText(extractedText, 'camera');
        await _loadData(); // Recargar datos
        
        setState(() {
          _extractedText = extractedText;
          _textController.text = extractedText;
        });
      } else {
        setState(() {
          _extractedText = 'No se encontró texto en la imagen';
        });
      }

      textRecognizer.close();
    } catch (e) {
      _showError('Error al procesar la imagen: $e');
    }
  }

  Future<void> _startListening() async {
    // Funcionalidad temporalmente deshabilitada debido a problemas de compatibilidad
    _showError('Funcionalidad de voz temporalmente no disponible');
    return;
    
    /* Código comentado temporalmente
    if (!_speechEnabled) {
      _showError('El reconocimiento de voz no está disponible');
      return;
    }

    await _requestPermissions();

    setState(() {
      _isListening = true;
      _extractedText = 'Escuchando...';
    });

    await _speechToText.listen(
      onResult: (result) async {
        final recognizedText = result.recognizedWords;
        
        setState(() {
          _extractedText = recognizedText;
        });
        
        // Si el resultado es final y no está vacío, guardarlo
        if (result.finalResult && recognizedText.isNotEmpty) {
          final entry = TextEntry(
            id: TextEntry.generateId(),
            text: recognizedText,
            source: 'microphone',
            timestamp: DateTime.now(),
          );
          
          await StorageService.addTextEntry(entry);
          await StorageService.saveCurrentText(recognizedText, 'microphone');
          await _loadData(); // Recargar datos
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'es_ES',
    );
    */
  }

  Future<void> _stopListening() async {
    // Funcionalidad temporalmente deshabilitada
    setState(() {
      _isListening = false;
    });
    
    /* Código comentado temporalmente
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      if (_extractedText == 'Escuchando...') {
        _extractedText = 'No se detectó ningún audio';
      }
    });
    */
  }

  void _shareText() {
    final textToShare = _isEditing ? _textController.text.trim() : _extractedText;
    if (textToShare.isNotEmpty && 
        textToShare != 'Escuchando...' && 
        textToShare != 'No se detectó ningún audio' && 
        textToShare != 'No se encontró texto en la imagen') {
      Share.share(textToShare, subject: 'Texto extraído con ToText');
    } else {
      _showError('No hay texto para compartir');
    }
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
      await StorageService.saveCurrentText(editedText, 'edited');
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
      _selectedIndex = 0; // Volver a la pestaña principal
      _isEditing = false;
    });
  }

  Future<void> _deleteHistoryEntry(String id) async {
    await StorageService.deleteTextEntry(id);
    await _loadData();
  }

  void _showHistory() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_selectedIndex == 0 ? 'ToText - OCR y Voz' : 'Historial'),
        actions: [
          if (_selectedIndex == 0 && _extractedText.isNotEmpty && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _startEditing,
              tooltip: 'Editar texto',
            ),
          if (_selectedIndex == 0 && _isEditing)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveEditedText,
                  tooltip: 'Guardar',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _cancelEditing,
                  tooltip: 'Cancelar',
                ),
              ],
            ),
          if (_selectedIndex == 0 && _extractedText.isNotEmpty && !_isEditing)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearText,
              tooltip: 'Limpiar texto',
            ),
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showHistory,
              tooltip: 'Ver historial',
            ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildMainView() : _buildHistoryView(),
      bottomNavigationBar: _selectedIndex == 0 
          ? _buildBottomAppBarWithButtons()
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Historial',
                ),
              ],
            ),
    );
  }

  Widget _buildMainView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Área de texto extraído/editable
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey.shade50,
              ),
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Procesando...'),
                        ],
                      ),
                    )
                  : _isEditing
                      ? TextFormField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Edita tu texto aquí...',
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: (value) {
                            // Actualizar en tiempo real mientras edita
                          },
                        )
                      : SingleChildScrollView(
                          child: GestureDetector(
                            onTap: _extractedText.isNotEmpty ? _startEditing : null,
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 200),
                              child: Text(
                                _extractedText.isEmpty
                                    ? 'El texto extraído aparecerá aquí...\n\n• Toca el botón de cámara para tomar una foto y extraer texto\n• Selecciona de galería para procesar imágenes existentes\n• Una vez que tengas texto, podrás editarlo y compartirlo\n• Ve al historial para revisar textos anteriores\n\nNota: La funcionalidad de voz está temporalmente deshabilitada por problemas de compatibilidad.'
                                    : '$_extractedText\n\n(Toca para editar)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _extractedText.isEmpty ? Colors.grey.shade600 : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón de compartir
          if (_extractedText.isNotEmpty && 
              _extractedText != 'Escuchando...' && 
              _extractedText != 'No se detectó ningún audio' && 
              _extractedText != 'No se encontró texto en la imagen')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareText,
                icon: const Icon(Icons.share),
                label: const Text('Compartir Texto'),
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
            child: _textHistory.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay textos guardados aún',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _textHistory.length,
                    itemBuilder: (context, index) {
                      final entry = _textHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            entry.source == 'camera' ? Icons.camera_alt : Icons.mic,
                            color: entry.source == 'camera' ? Colors.blue : Colors.red,
                          ),
                          title: Text(
                            entry.text.length > 50 
                                ? '${entry.text.substring(0, 50)}...'
                                : entry.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${_formatDate(entry.timestamp)} • ${entry.source == 'camera' ? 'Cámara' : 'Micrófono'}',
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'select',
                                child: ListTile(
                                  leading: Icon(Icons.check),
                                  title: Text('Usar este texto'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'share',
                                child: ListTile(
                                  leading: Icon(Icons.share),
                                  title: Text('Compartir'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Eliminar'),
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'select':
                                  _selectTextFromHistory(entry);
                                  break;
                                case 'share':
                                  Share.share(entry.text, subject: 'Texto extraído con ToText');
                                  break;
                                case 'delete':
                                  _deleteHistoryEntry(entry.id);
                                  break;
                              }
                            },
                          ),
                          onTap: () => _selectTextFromHistory(entry),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBarWithButtons() {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Botón de navegación a Inicio
          Expanded(
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              icon: Icon(
                Icons.home,
                size: 32,
                color: _selectedIndex == 0 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: 'Inicio',
            ),
          ),
          
          // Separador vertical
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // Botón de cámara
          Expanded(
            child: IconButton(
              onPressed: _isLoading ? null : () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Tomar foto'),
                            onTap: () {
                              Navigator.pop(context);
                              _takePhotoAndExtractText();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Seleccionar de galería'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromGallery();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.camera_alt,
                size: 32,
              ),
              tooltip: 'Cámara',
            ),
          ),
          
          // Separador vertical
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // Botón de micrófono (deshabilitado)
          Expanded(
            child: IconButton(
              onPressed: _startListening,
              icon: Icon(
                Icons.mic_off,
                size: 32,
                color: Colors.grey.shade400,
              ),
              tooltip: 'Voz (no disponible)',
            ),
          ),
          
          // Separador vertical
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          
          // Botón de navegación a Historial
          Expanded(
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              icon: Icon(
                Icons.history,
                size: 32,
                color: _selectedIndex == 1 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: 'Historial',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
