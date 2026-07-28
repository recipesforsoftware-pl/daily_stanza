import 'package:equatable/equatable.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

enum DailyPoemFailureType { network, permission, unknown }

sealed class DailyPoemState extends Equatable {
  const DailyPoemState();
}

final class DailyPoemInitial extends DailyPoemState {
  const DailyPoemInitial();

  @override
  List<Object> get props => [];
}

final class DailyPoemLoading extends DailyPoemState {
  const DailyPoemLoading();

  @override
  List<Object> get props => [];
}

final class DailyPoemLoaded extends DailyPoemState {
  const DailyPoemLoaded({required this.poem, required this.isFromCache});

  final Poem poem;
  final bool isFromCache;

  @override
  List<Object> get props => [poem, isFromCache];
}

final class DailyPoemMissing extends DailyPoemState {
  const DailyPoemMissing();

  @override
  List<Object> get props => [];
}

final class DailyPoemFailure extends DailyPoemState {
  const DailyPoemFailure({required this.failureType});

  final DailyPoemFailureType failureType;

  @override
  List<Object> get props => [failureType];
}
