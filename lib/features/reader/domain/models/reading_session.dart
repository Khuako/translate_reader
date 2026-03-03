import 'package:translate_reader/features/reader/domain/models/book_content.dart';

enum ReaderAppearancePreset { paper, mist, sepia, sage, graphite, night }

enum ReaderLayoutMode { pagedHorizontal, scrollVertical }

enum ReaderFontFamily {
  system,
  literata,
  merriweather,
  lora,
  ptSerif,
  notoSerif,
  cormorantGaramond,
  playfairDisplay,
}

ReaderAppearancePreset parseReaderAppearancePreset(String value) {
  for (final ReaderAppearancePreset preset in ReaderAppearancePreset.values) {
    if (preset.name == value) {
      return preset;
    }
  }

  return ReaderAppearancePreset.paper;
}

ReaderLayoutMode parseReaderLayoutMode(String value) {
  for (final ReaderLayoutMode mode in ReaderLayoutMode.values) {
    if (mode.name == value) {
      return mode;
    }
  }

  return ReaderLayoutMode.pagedHorizontal;
}

ReaderFontFamily parseReaderFontFamily(String value) {
  for (final ReaderFontFamily family in ReaderFontFamily.values) {
    if (family.name == value) {
      return family;
    }
  }

  return ReaderFontFamily.system;
}

extension ReaderLayoutModeX on ReaderLayoutMode {
  String get label {
    switch (this) {
      case ReaderLayoutMode.pagedHorizontal:
        return 'Страницы';
      case ReaderLayoutMode.scrollVertical:
        return 'Вертикально';
    }
  }
}

class ReadingSession {
  const ReadingSession({
    required this.book,
    required this.currentPage,
    required this.fontSize,
    required this.fontFamily,
    required this.appearancePreset,
    required this.layoutMode,
  });

  final BookContent book;
  final int currentPage;
  final double fontSize;
  final ReaderFontFamily fontFamily;
  final ReaderAppearancePreset appearancePreset;
  final ReaderLayoutMode layoutMode;

  ReadingSession copyWith({
    BookContent? book,
    int? currentPage,
    double? fontSize,
    ReaderFontFamily? fontFamily,
    ReaderAppearancePreset? appearancePreset,
    ReaderLayoutMode? layoutMode,
  }) {
    return ReadingSession(
      book: book ?? this.book,
      currentPage: currentPage ?? this.currentPage,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      appearancePreset: appearancePreset ?? this.appearancePreset,
      layoutMode: layoutMode ?? this.layoutMode,
    );
  }
}
