import 'package:flutter_test/flutter_test.dart';
import 'package:totext/models/text_entry.dart';

void main() {
  group('TextEntry Model Tests', () {
    test('should create TextEntry with required fields', () {
      final entry = TextEntry(
        id: 'test-id',
        text: 'Hello World',
        source: 'camera',
        timestamp: DateTime.now(),
      );

      expect(entry.id, 'test-id');
      expect(entry.text, 'Hello World');
      expect(entry.source, 'camera');
      expect(entry.category, 'Otro'); // default value
      expect(entry.tags, isEmpty);
      expect(entry.isHandwritten, false);
      expect(entry.isSynced, false);
    });

    test('should generate unique IDs', () {
      final id1 = TextEntry.generateId();
      final id2 = TextEntry.generateId();
      
      expect(id1, isNot(equals(id2)));
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
    });

    test('should convert to JSON correctly', () {
      final timestamp = DateTime.now();
      final entry = TextEntry(
        id: 'test-id',
        text: 'Test text',
        source: 'microphone',
        timestamp: timestamp,
        category: 'Documento',
        tags: ['test', 'unit'],
        isHandwritten: true,
        confidence: 95.5,
        isSynced: true,
      );

      final json = entry.toJson();

      expect(json['id'], 'test-id');
      expect(json['text'], 'Test text');
      expect(json['source'], 'microphone');
      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['category'], 'Documento');
      expect(json['tags'], ['test', 'unit']);
      expect(json['isHandwritten'], true);
      expect(json['confidence'], 95.5);
      expect(json['isSynced'], true);
    });

    test('should create from JSON correctly', () {
      final timestamp = DateTime.now();
      final json = {
        'id': 'test-id',
        'text': 'Test text',
        'source': 'camera',
        'timestamp': timestamp.toIso8601String(),
        'category': 'Recibo',
        'tags': ['receipt', 'shop'],
        'isHandwritten': false,
        'confidence': 87.3,
        'isSynced': false,
      };

      final entry = TextEntry.fromJson(json);

      expect(entry.id, 'test-id');
      expect(entry.text, 'Test text');
      expect(entry.source, 'camera');
      expect(entry.timestamp, timestamp);
      expect(entry.category, 'Recibo');
      expect(entry.tags, ['receipt', 'shop']);
      expect(entry.isHandwritten, false);
      expect(entry.confidence, 87.3);
      expect(entry.isSynced, false);
    });

    test('should handle copyWith correctly', () {
      final originalEntry = TextEntry(
        id: 'original-id',
        text: 'Original text',
        source: 'camera',
        timestamp: DateTime.now(),
        category: 'Original',
      );

      final copiedEntry = originalEntry.copyWith(
        text: 'Modified text',
        category: 'Modified',
        isSynced: true,
      );

      expect(copiedEntry.id, 'original-id'); // unchanged
      expect(copiedEntry.text, 'Modified text'); // changed
      expect(copiedEntry.source, 'camera'); // unchanged
      expect(copiedEntry.category, 'Modified'); // changed
      expect(copiedEntry.isSynced, true); // changed
    });

    test('should convert to Map for database correctly', () {
      final timestamp = DateTime.now();
      final entry = TextEntry(
        id: 'db-test-id',
        text: 'Database test',
        source: 'gallery',
        timestamp: timestamp,
        tags: ['tag1', 'tag2'],
        isHandwritten: true,
        confidence: 92.1,
      );

      final map = entry.toMap();

      expect(map['id'], 'db-test-id');
      expect(map['text'], 'Database test');
      expect(map['source'], 'gallery');
      expect(map['timestamp'], timestamp.toIso8601String());
      expect(map['tags'], 'tag1,tag2'); // joined with comma
      expect(map['isHandwritten'], 1); // boolean to int
      expect(map['confidence'], 92.1);
      expect(map['isSynced'], 0); // boolean to int
    });

    test('should create from Map (database) correctly', () {
      final timestamp = DateTime.now();
      final map = {
        'id': 'db-test-id',
        'text': 'Database test',
        'source': 'gallery',
        'timestamp': timestamp.toIso8601String(),
        'category': 'Test Category',
        'tags': 'tag1,tag2,tag3',
        'isHandwritten': 1,
        'confidence': 88.7,
        'isSynced': 0,
      };

      final entry = TextEntry.fromMap(map);

      expect(entry.id, 'db-test-id');
      expect(entry.text, 'Database test');
      expect(entry.source, 'gallery');
      expect(entry.timestamp, timestamp);
      expect(entry.category, 'Test Category');
      expect(entry.tags, ['tag1', 'tag2', 'tag3']);
      expect(entry.isHandwritten, true);
      expect(entry.confidence, 88.7);
      expect(entry.isSynced, false);
    });

    test('should handle empty tags in database map', () {
      final map = {
        'id': 'test-id',
        'text': 'Test',
        'source': 'camera',
        'timestamp': DateTime.now().toIso8601String(),
        'tags': '', // empty string
        'isHandwritten': 0,
        'isSynced': 0,
      };

      final entry = TextEntry.fromMap(map);
      expect(entry.tags, isEmpty);
    });

    test('should handle null tags in database map', () {
      final map = {
        'id': 'test-id',
        'text': 'Test',
        'source': 'camera',
        'timestamp': DateTime.now().toIso8601String(),
        'tags': null, // null value
        'isHandwritten': 0,
        'isSynced': 0,
      };

      final entry = TextEntry.fromMap(map);
      expect(entry.tags, isEmpty);
    });
  });
}
