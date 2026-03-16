import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:translate_reader/core/database/app_database.dart';

/// Сервис для работы со словариком сохранённых слов.
class VocabularyService {
  VocabularyService._();

  static final VocabularyService instance = VocabularyService._();

  final AppDatabase _db = AppDatabase.instance;

  /// Добавляет слово в словарик. Возвращает true, если слово добавлено.
  Future<bool> addWord({
    required String word,
    required String translation,
  }) async {
    final String normalized = word.toLowerCase();
    final bool alreadySaved = await _db.isWordSaved(normalized);
    if (alreadySaved) {
      return false;
    }

    await _db.addWord(word: normalized, translation: translation);
    return true;
  }

  /// Удаляет слово из словарика по тексту.
  Future<void> removeWord(String word) async {
    await _db.removeWordByText(word.toLowerCase());
  }

  /// Удаляет слово из словарика по id.
  Future<void> removeWordById(int id) async {
    await _db.removeWord(id);
  }

  /// Проверяет, сохранено ли слово в словарике.
  Future<bool> isWordSaved(String word) {
    return _db.isWordSaved(word.toLowerCase());
  }

  /// Поток всех слов из словарика.
  Stream<List<VocabularyEntry>> watchAllWords() {
    return _db.watchAllWords();
  }

  /// Все слова из словарика.
  Future<List<VocabularyEntry>> getAllWords() {
    return _db.getAllWords();
  }

  /// Добавляет фразу в словарик. Возвращает true, если фраза добавлена.
  Future<bool> addPhrase({
    required String phrase,
    required String translation,
  }) async {
    final String normalized = phrase.toLowerCase();
    final bool alreadySaved = await _db.isPhraseSaved(normalized);
    if (alreadySaved) {
      return false;
    }

    await _db.addPhrase(phrase: normalized, translation: translation);
    return true;
  }

  /// Удаляет фразу из словарика по тексту.
  Future<void> removePhrase(String phrase) async {
    await _db.removePhraseByText(phrase.toLowerCase());
  }

  /// Удаляет фразу из словарика по id.
  Future<void> removePhraseById(int id) async {
    await _db.removePhraseById(id);
  }

  /// Проверяет, сохранена ли фраза в словарике.
  Future<bool> isPhraseSaved(String phrase) {
    return _db.isPhraseSaved(phrase.toLowerCase());
  }

  /// Поток всех фраз из словарика.
  Stream<List<SavedPhrase>> watchAllPhrases() {
    return _db.watchAllPhrases();
  }

  /// Экспортирует словарик (слова + фразы) в JSON-файл.
  /// Возвращает true, если файл успешно сохранён.
  Future<bool> exportVocabulary() async {
    final words = await _db.getAllWords();
    final phrases = await _db.getAllPhrases();

    final data = <String, dynamic>{
      'version': 1,
      'words': words
          .map((w) => <String, dynamic>{
                'word': w.word,
                'translation': w.translation,
                'createdAt': w.createdAt.toIso8601String(),
              })
          .toList(),
      'phrases': phrases
          .map((p) => <String, dynamic>{
                'phrase': p.phrase,
                'translation': p.translation,
                'createdAt': p.createdAt.toIso8601String(),
              })
          .toList(),
    };

    final jsonBytes =
        utf8.encode(const JsonEncoder.withIndent('  ').convert(data));

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Сохранить словарик',
      fileName: 'vocabulary.json',
      bytes: jsonBytes,
    );

    if (result == null) return false;

    // На десктопе saveFile возвращает путь, но не записывает bytes —
    // нужно записать самостоятельно.
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      await File(result).writeAsBytes(jsonBytes);
    }

    return true;
  }

  /// Импортирует словарик из JSON-файла.
  /// Возвращает кол-во добавленных слов и фраз: (words, phrases).
  Future<({int words, int phrases})> importVocabulary() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );

    if (picked == null || picked.files.isEmpty) {
      return (words: 0, phrases: 0);
    }

    final file = picked.files.single;
    final String content;

    if (file.bytes != null) {
      content = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      return (words: 0, phrases: 0);
    }

    final data = jsonDecode(content) as Map<String, dynamic>;

    int addedWords = 0;
    int addedPhrases = 0;

    if (data['words'] is List) {
      for (final item in data['words'] as List) {
        if (item is Map<String, dynamic>) {
          final word = (item['word'] as String?)?.toLowerCase();
          final translation = item['translation'] as String?;
          if (word == null || translation == null) continue;
          if (await _db.isWordSaved(word)) continue;
          await _db.addWord(word: word, translation: translation);
          addedWords++;
        }
      }
    }

    if (data['phrases'] is List) {
      for (final item in data['phrases'] as List) {
        if (item is Map<String, dynamic>) {
          final phrase = (item['phrase'] as String?)?.toLowerCase();
          final translation = item['translation'] as String?;
          if (phrase == null || translation == null) continue;
          if (await _db.isPhraseSaved(phrase)) continue;
          await _db.addPhrase(phrase: phrase, translation: translation);
          addedPhrases++;
        }
      }
    }

    return (words: addedWords, phrases: addedPhrases);
  }
}
