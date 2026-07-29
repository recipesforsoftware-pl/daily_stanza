import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_state.dart';

class PoemDetailsCubit extends Cubit<PoemDetailsState> {
  PoemDetailsCubit({required PoemRepository repository})
    : _repository = repository,
      super(const PoemDetailsInitial());

  final PoemRepository _repository;
  String? _lastRequestedId;

  Future<void> loadPoem(String poemId) async {
    final trimmed = poemId.trim();
    if (trimmed.isEmpty) {
      emit(const PoemDetailsMissing());
      return;
    }

    _lastRequestedId = trimmed;
    emit(const PoemDetailsLoading());

    try {
      final poems = await _repository.getPoemsByIds([trimmed]);

      if (poems.isEmpty) {
        emit(const PoemDetailsMissing());
        return;
      }

      final match = poems.where((p) => p.id == trimmed);
      if (match.isEmpty) {
        emit(const PoemDetailsMissing());
        return;
      }

      emit(PoemDetailsLoaded(poem: match.first));
    } catch (_) {
      emit(const PoemDetailsFailure());
    }
  }

  Future<void> retry() async {
    if (_lastRequestedId != null) {
      await loadPoem(_lastRequestedId!);
    }
  }
}
