import 'package:translate_reader/features/reader/domain/models/book_content.dart';

/// Класс для форматирования текста книги.
class BookTextFormatter {
  FormattedBookContent format({
    required List<BookBlock> blocks,
    List<BookTocEntry> tocEntries = const <BookTocEntry>[],
  }) {
    if (blocks.isEmpty) {
      return const FormattedBookContent(
        text: '',
        blocks: <FormattedBookBlock>[],
        tocEntries: <FormattedBookTocEntry>[],
      );
    }

    const String indent = '\u2003\u2003';
    final StringBuffer buffer = StringBuffer();
    final List<FormattedBookBlock> formattedBlocks = <FormattedBookBlock>[];
    final Map<int, int> blockOffsets = <int, int>{};

    for (int index = 0; index < blocks.length; index += 1) {
      final BookBlock block = blocks[index];
      final String normalizedText = _normalizeBlockText(block.text);
      if (normalizedText.isEmpty) {
        continue;
      }

      if (buffer.isNotEmpty) {
        buffer.write('\n');
      }

      final int start = buffer.length;
      final String formattedText = block.isHeading
          ? normalizedText
          : '$indent$normalizedText';
      buffer.write(formattedText);
      final int end = buffer.length;

      formattedBlocks.add(
        FormattedBookBlock(
          text: formattedText,
          start: start,
          end: end,
          type: block.type,
          level: block.level,
        ),
      );
      blockOffsets[index] = start;
    }

    final List<FormattedBookTocEntry> formattedTocEntries = tocEntries
        .map((BookTocEntry entry) {
          final int? textOffset = blockOffsets[entry.targetBlockIndex];
          if (textOffset == null) {
            return null;
          }

          return FormattedBookTocEntry(
            title: _normalizeBlockText(entry.title),
            level: entry.level,
            textOffset: textOffset,
          );
        })
        .whereType<FormattedBookTocEntry>()
        .toList(growable: false);

    return FormattedBookContent(
      text: buffer.toString(),
      blocks: formattedBlocks,
      tocEntries: formattedTocEntries,
    );
  }

  String _normalizeBlockText(String rawText) {
    return rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
