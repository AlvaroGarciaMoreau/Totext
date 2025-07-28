class TextEntry {
  final String id;
  final String text;
  final String source; // 'camera' or 'microphone'
  final DateTime timestamp;

  TextEntry({
    required this.id,
    required this.text,
    required this.source,
    required this.timestamp,
  });

  // Convertir a Map para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Crear desde Map
  factory TextEntry.fromJson(Map<String, dynamic> json) {
    return TextEntry(
      id: json['id'],
      text: json['text'],
      source: json['source'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Generar un ID único
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
