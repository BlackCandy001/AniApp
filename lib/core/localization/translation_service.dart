import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';
import 'language_provider.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  final currentLang = ref.watch(languageProvider);
  return TranslationService(currentLang);
});

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();
  final String currentLang;

  TranslationService(this.currentLang);

  /// Dịch một đoạn văn bản sang ngôn ngữ hiện tại.
  /// Nếu ngôn ngữ là tiếng Anh ('en'), trả về nguyên bản (vì API Jikan đã là tiếng Anh).
  Future<String> translate(String text) async {
    if (text.isEmpty) return text;
    if (currentLang == 'en') return text; // Không cần dịch nếu chọn tiếng Anh

    try {
      final result = await _translator.translate(text, to: currentLang);
      return result.text;
    } catch (e) {
      // Nếu có lỗi (VD mất mạng), trả về văn bản gốc
      return text;
    }
  }

  /// Dịch một List các chuỗi
  Future<List<String>> translateList(List<String> texts) async {
    if (currentLang == 'en' || texts.isEmpty) return texts;

    try {
      List<String> translated = [];
      for (String text in texts) {
        final result = await _translator.translate(text, to: currentLang);
        translated.add(result.text);
      }
      return translated;
    } catch (e) {
      return texts;
    }
  }
}
