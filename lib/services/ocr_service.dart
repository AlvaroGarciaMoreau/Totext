import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../constants/app_constants.dart';

class OcrService {
  static final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String extractedText = recognizedText.text;
      return extractedText.isNotEmpty ? extractedText : AppConstants.statusNoTextFound;
    } catch (e) {
      throw Exception('${AppConstants.errorProcessImage}: $e');
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
