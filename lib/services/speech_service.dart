import 'package:speech_to_text/speech_to_text.dart';
import '../constants/app_constants.dart';
import '../utils/permission_utils.dart';
import '../config/app_config.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  Function(VoiceCommand)? _onVoiceCommand;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  Future<void> initialize() async {
    _isInitialized = await _speechToText.initialize();
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Function(VoiceCommand)? onVoiceCommand,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      onError(AppConstants.errorSpeechNotInitialized);
      return;
    }

    if (!await PermissionUtils.requestMicrophonePermission()) {
      onError(AppConstants.errorMicrophonePermission);
      return;
    }

    if (_isListening) return;

    _isListening = true;
    _onVoiceCommand = onVoiceCommand;

    try {
      // Obtener el locale específico o el primero español disponible
      final locales = await _speechToText.locales();
      String targetLocale = localeId ?? 'es-ES';
      
      final selectedLocale = locales.firstWhere(
        (l) => l.localeId == targetLocale,
        orElse: () => locales.firstWhere(
          (l) => l.localeId.startsWith('es'),
          orElse: () => locales.first,
        ),
      );

      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            final recognizedText = result.recognizedWords;
            if (recognizedText.isNotEmpty) {
              // Verificar si es un comando de voz
              VoiceCommand? command = _detectVoiceCommand(recognizedText);
              if (command != null && _onVoiceCommand != null) {
                _onVoiceCommand!(command);
              } else {
                onResult(recognizedText);
              }
            }
          }
        },
        listenFor: AppConstants.speechListenDuration,
        pauseFor: AppConstants.speechPauseDuration,
        localeId: selectedLocale.localeId,
        onSoundLevelChange: (level) {},
      ).whenComplete(() {
        _isListening = false;
      });
    } catch (e) {
      _isListening = false;
      onError('Error al iniciar reconocimiento de voz: $e');
    }
  }

  Future<void> startCommandListening({
    required Function(VoiceCommand) onCommand,
    required Function(String) onError,
    String? localeId,
  }) async {
    await startListening(
      onResult: (text) {
        // En modo comando, todos los resultados se procesan como posibles comandos
        VoiceCommand? command = _detectVoiceCommand(text);
        if (command != null) {
          onCommand(command);
        }
      },
      onError: onError,
      localeId: localeId,
    );
  }

  VoiceCommand? _detectVoiceCommand(String text) {
    String normalizedText = text.toLowerCase().trim();
    
    for (String commandType in AppConfig.voiceCommands.keys) {
      List<String> phrases = AppConfig.voiceCommands[commandType]!;
      
      for (String phrase in phrases) {
        if (normalizedText.contains(phrase.toLowerCase())) {
          return VoiceCommand(
            type: commandType,
            originalText: text,
            confidence: _calculateCommandConfidence(normalizedText, phrase.toLowerCase()),
          );
        }
      }
    }
    
    return null;
  }

  double _calculateCommandConfidence(String text, String command) {
    // Cálculo simple de confianza basado en similitud
    List<String> textWords = text.split(' ');
    List<String> commandWords = command.split(' ');
    
    int matches = 0;
    for (String commandWord in commandWords) {
      if (textWords.any((word) => word.contains(commandWord) || commandWord.contains(word))) {
        matches++;
      }
    }
    
    return matches / commandWords.length;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    _isListening = false;
    _onVoiceCommand = null;
  }

  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) return [];
    return await _speechToText.locales();
  }

  Future<bool> hasPermission() async {
    return await _speechToText.hasPermission;
  }

  List<String> getSupportedCommands() {
    List<String> commands = [];
    AppConfig.voiceCommands.forEach((key, phrases) {
      commands.addAll(phrases);
    });
    return commands;
  }

  Map<String, List<String>> getAllCommands() {
    return AppConfig.voiceCommands;
  }
}

class VoiceCommand {
  final String type;
  final String originalText;
  final double confidence;

  VoiceCommand({
    required this.type,
    required this.originalText,
    required this.confidence,
  });

  @override
  String toString() {
    return 'VoiceCommand(type: $type, text: $originalText, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}
