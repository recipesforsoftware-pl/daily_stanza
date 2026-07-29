import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';

/// [PoemShareService] implementation backed by share_plus.
///
/// For testability, the share invocation is injectable via [shareInvoker].
class SharePlusPoemShareService implements PoemShareService {
  SharePlusPoemShareService({
    Future<ShareResult> Function(ShareParams)? shareInvoker,
  }) : _shareInvoker = shareInvoker;

  final Future<ShareResult> Function(ShareParams)? _shareInvoker;

  Future<ShareResult> _defaultShare(ShareParams params) =>
      SharePlus.instance.share(params);

  @override
  Future<PoemShareResult> shareText({
    required String text,
    required String subject,
    Rect? sharePositionOrigin,
  }) async {
    final invoker = _shareInvoker ?? _defaultShare;

    try {
      final result = await invoker(
        ShareParams(
          text: text,
          subject: subject,
          title: subject,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );

      return switch (result.status) {
        ShareResultStatus.success => PoemShareResult.completed,
        ShareResultStatus.dismissed => PoemShareResult.dismissed,
        ShareResultStatus.unavailable => PoemShareResult.unavailable,
      };
    } catch (_) {
      rethrow;
    }
  }
}
