import 'package:uuid/uuid.dart';

class TextEntry {
  final String id;
  final String text;
  final String source; // 'camera', 'microphone', 'gallery'
  final DateTime timestamp;
  final String? originalLanguage;
  final String? translatedText;
  final String? targetLanguage;
  final String category;
  final List<String> tags;
  final String? imagePath;
  final bool isHandwritten;
  final double? confidence;
  final bool isSynced;
  final String? cloudId;

  TextEntry({
    required this.id,
    required this.text,
    required this.source,
    required this.timestamp,
    this.originalLanguage,
    this.translatedText,
    this.targetLanguage,
    this.category = 'Otro',
    this.tags = const [],
    this.imagePath,
    this.isHandwritten = false,
    this.confidence,
    this.isSynced = false,
    this.cloudId,
  });

  // Convertir a Map para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
      'originalLanguage': originalLanguage,
      'translatedText': translatedText,
      'targetLanguage': targetLanguage,
      'category': category,
      'tags': tags,
      'imagePath': imagePath,
      'isHandwritten': isHandwritten,
      'confidence': confidence,
      'isSynced': isSynced,
      'cloudId': cloudId,
    };
  }

  // Crear desde Map
  factory TextEntry.fromJson(Map<String, dynamic> json) {
    return TextEntry(
      id: json['id'],
      text: json['text'],
      source: json['source'],
      timestamp: DateTime.parse(json['timestamp']),
      originalLanguage: json['originalLanguage'],
      translatedText: json['translatedText'],
      targetLanguage: json['targetLanguage'],
      category: json['category'] ?? 'Otro',
      tags: List<String>.from(json['tags'] ?? []),
      imagePath: json['imagePath'],
      isHandwritten: json['isHandwritten'] ?? false,
      confidence: json['confidence']?.toDouble(),
      isSynced: json['isSynced'] ?? false,
      cloudId: json['cloudId'],
    );
  }

  // Generar un ID único
  static String generateId() {
    const uuid = Uuid();
    return uuid.v4();
  }

  // Crear copia con cambios
  TextEntry copyWith({
    String? id,
    String? text,
    String? source,
    DateTime? timestamp,
    String? originalLanguage,
    String? translatedText,
    String? targetLanguage,
    String? category,
    List<String>? tags,
    String? imagePath,
    bool? isHandwritten,
    double? confidence,
    bool? isSynced,
    String? cloudId,
  }) {
    return TextEntry(
      id: id ?? this.id,
      text: text ?? this.text,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      translatedText: translatedText ?? this.translatedText,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
      isHandwritten: isHandwritten ?? this.isHandwritten,
      confidence: confidence ?? this.confidence,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }

  // Convertir a Map para base de datos SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
      'originalLanguage': originalLanguage,
      'translatedText': translatedText,
      'targetLanguage': targetLanguage,
      'category': category,
      'tags': tags.join(','),
      'imagePath': imagePath,
      'isHandwritten': isHandwritten ? 1 : 0,
      'confidence': confidence,
      'isSynced': isSynced ? 1 : 0,
      'cloudId': cloudId,
    };
  }

  // Crear desde Map de base de datos SQLite
  factory TextEntry.fromMap(Map<String, dynamic> map) {
    return TextEntry(
      id: map['id'],
      text: map['text'],
      source: map['source'],
      timestamp: DateTime.parse(map['timestamp']),
      originalLanguage: map['originalLanguage'],
      translatedText: map['translatedText'],
      targetLanguage: map['targetLanguage'],
      category: map['category'] ?? 'Otro',
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty 
          ? (map['tags'] as String).split(',') 
          : [],
      imagePath: map['imagePath'],
      isHandwritten: map['isHandwritten'] == 1,
      confidence: map['confidence']?.toDouble(),
      isSynced: map['isSynced'] == 1,
      cloudId: map['cloudId'],
    );
  }
}
