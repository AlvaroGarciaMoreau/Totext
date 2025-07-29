import 'package:speech_to_text/speech_to_text.dart';
import '../constants/app_constants.dart';
import '../utils/permission_utils.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  Future<void> initialize() async {
    _isInitialized = await _speechToText.initialize();
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
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

    try {
      // Obtener el primer locale español disponible
      final locales = await _speechToText.locales();
      final esLocale = locales.firstWhere(
        (l) => l.localeId.startsWith('es'),
        orElse: () => locales.first,
      );

      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            final recognizedText = result.recognizedWords;
            if (recognizedText.isNotEmpty) {
              onResult(recognizedText);
            }
          }
        },
        listenFor: AppConstants.speechListenDuration,
        pauseFor: AppConstants.speechPauseDuration,
        localeId: esLocale.localeId,
        onSoundLevelChange: (level) {},
      ).whenComplete(() {
        _isListening = false;
      });
    } catch (e) {
      _isListening = false;
      onError('Error al iniciar reconocimiento de voz: $e');
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    _isListening = false;
  }
}
