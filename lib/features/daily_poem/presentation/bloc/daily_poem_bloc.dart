import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/daily_poem/domain/failure/daily_poem_failure.dart'
    as domain;
import 'package:daily_stanza/features/daily_poem/domain/repository/poem_repository.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_event.dart';
import 'package:daily_stanza/features/daily_poem/presentation/bloc/daily_poem_state.dart';

class DailyPoemBloc extends Bloc<DailyPoemEvent, DailyPoemState> {
  DailyPoemBloc({required PoemRepository repository})
    : _repository = repository,
      super(const DailyPoemInitial()) {
    on<DailyPoemRequested>(_onRequested);
    on<DailyPoemRetryRequested>(_onRetry);
  }

  final PoemRepository _repository;

  DateTime? _lastDate;
  String? _lastLanguageCode;

  Future<void> _onRequested(
    DailyPoemRequested event,
    Emitter<DailyPoemState> emit,
  ) async {
    _lastDate = event.date;
    _lastLanguageCode = event.languageCode;
    await _loadPoem(emit: emit);
  }

  Future<void> _onRetry(
    DailyPoemRetryRequested event,
    Emitter<DailyPoemState> emit,
  ) async {
    if (_lastDate == null || _lastLanguageCode == null) return;
    await _loadPoem(emit: emit);
  }

  Future<void> _loadPoem({required Emitter<DailyPoemState> emit}) async {
    emit(const DailyPoemLoading());

    try {
      final result = await _repository.getDailyPoem(
        date: _lastDate!,
        languageCode: _lastLanguageCode!,
      );
      emit(DailyPoemLoaded(poem: result.poem, isFromCache: result.isFromCache));
    } on domain.DailyPoemNotFoundFailure {
      emit(const DailyPoemMissing());
    } on domain.PoemNotFoundFailure {
      emit(const DailyPoemMissing());
    } on domain.NetworkFailure {
      emit(const DailyPoemFailure(failureType: DailyPoemFailureType.network));
    } on domain.PermissionFailure {
      emit(
        const DailyPoemFailure(failureType: DailyPoemFailureType.permission),
      );
    } on domain.InvalidPoemDataFailure {
      emit(const DailyPoemFailure(failureType: DailyPoemFailureType.unknown));
    } on domain.UnknownFailure {
      emit(const DailyPoemFailure(failureType: DailyPoemFailureType.unknown));
    }
  }
}
