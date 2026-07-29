import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

/// Pure text builder that produces deterministic share content from a [Poem].
///
/// Does not depend on BuildContext, share_plus, Flutter widgets, Firebase,
/// or SharedPreferences.
class PoemShareTextBuilder {
  const PoemShareTextBuilder();

  /// Builds the full share body text.
  ///
  /// Format:
  /// ```
  /// {title}
  /// by {author}
  ///
  /// {content}
  ///
  /// Shared from Daily Stanza
  /// ```
  String buildText(Poem poem) {
    final title = poem.title.trim();
    final author = poem.author.trim();
    final content = poem.content.trim();

    return '$title\nby $author\n\n$content\n\nShared from Daily Stanza';
  }

  /// Builds the subject line for the share.
  ///
  /// Format: `{title} by {author}`
  String buildSubject(Poem poem) {
    final title = poem.title.trim();
    final author = poem.author.trim();

    return '$title by $author';
  }
}
