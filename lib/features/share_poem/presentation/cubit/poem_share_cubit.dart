import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/share_poem/application/poem_share_text_builder.dart';
import 'package:daily_stanza/features/share_poem/domain/model/poem_share_result.dart';
import 'package:daily_stanza/features/share_poem/domain/service/poem_share_service.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_state.dart';

/// Cubit that orchestrates poem sharing through the platform share sheet.
///
/// Depends on [PoemShareService] and [PoemShareTextBuilder].
/// Does not depend on share_plus, Firebase, or SharedPreferences directly.
class PoemShareCubit extends Cubit<PoemShareState> {
  PoemShareCubit({
    required PoemShareService shareService,
    PoemShareTextBuilder textBuilder = const PoemShareTextBuilder(),
  }) : _shareService = shareService,
       _textBuilder = textBuilder,
       super(const PoemShareState());

  final PoemShareService _shareService;
  final PoemShareTextBuilder _textBuilder;

  static const String _errorMessage = 'Unable to share poem. Please try again.';

  /// Shares the given [poem] through the native share sheet.
  ///
  /// Ignores a new request while another share is active.
  /// Clears any previous error before starting.
  Future<void> sharePoem(Poem poem, {Rect? sharePositionOrigin}) async {
    if (state.isSharing) return;

    // Clear previous error before each new attempt.
    if (state.mutationError != null) {
      emit(state.copyWith(mutationError: () => null));
    }

    emit(state.copyWith(sharingPoemId: () => poem.id, isSharing: true));

    try {
      final text = _textBuilder.buildText(poem);
      final subject = _textBuilder.buildSubject(poem);

      final result = await _shareService.shareText(
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );

      switch (result) {
        case PoemShareResult.completed:
          emit(const PoemShareState(isSharing: false));
        case PoemShareResult.dismissed:
          emit(const PoemShareState(isSharing: false));
        case PoemShareResult.unavailable:
          emit(const PoemShareState(isSharing: false));
      }
    } catch (_) {
      emit(const PoemShareState(mutationError: _errorMessage));
    }
  }
}
