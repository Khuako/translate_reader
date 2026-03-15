import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис озвучивания текста (Text-to-Speech).
class TtsService {
  TtsService._() {
    _init();
  }

  static final TtsService instance = TtsService._();

  static const String _speechRateKey = 'tts_speech_rate';
  static const double defaultSpeechRate = 0.45;

  /// Минимальная скорость (уровень 1).
  static const double minRate = 0.10;

  /// Максимальная скорость (уровень 10).
  static const double maxRate = 0.55;

  /// Шаг скорости между уровнями.
  static const double rateStep = 0.05;

  final FlutterTts _tts = FlutterTts();
  bool _isReady = false;
  double _speechRate = defaultSpeechRate;

  /// Текущая скорость произношения.
  double get speechRate => _speechRate;

  /// Конвертирует реальное значение скорости (0.10–0.55) в уровень (1–10).
  static int rateToLevel(double rate) =>
      ((rate - minRate) / rateStep).round() + 1;

  /// Конвертирует уровень (1–10) в реальное значение скорости.
  static double levelToRate(int level) => minRate + (level - 1) * rateStep;

  Future<void> _init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble(_speechRateKey) ?? defaultSpeechRate;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isReady = true;
  }

  /// Устанавливает скорость произношения и сохраняет в настройки.
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(minRate, maxRate);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speechRateKey, _speechRate);
    await _tts.setSpeechRate(_speechRate);
  }

  /// Озвучивает переданный текст на английском.
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    if (!_isReady) {
      await _init();
    }
    await _tts.stop();
    await _tts.speak(text.trim());
  }

  /// Останавливает текущее озвучивание.
  Future<void> stop() async {
    await _tts.stop();
  }
}
