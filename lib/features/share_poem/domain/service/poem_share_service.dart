import 'dart:ui';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';

/// Application-facing service for sharing poem text.
///
/// Implementations wrap platform-specific share APIs while keeping
/// poem-sharing code independent of any particular platform library.
abstract interface class PoemShareService {
  /// Opens the native share sheet with [text] content.
  ///
  /// [subject] is used as email subject where supported.
  /// [sharePositionOrigin] is the global rectangle of the source widget
  /// used for iPad popover positioning.
  Future<PoemShareResult> shareText({
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  });
}
