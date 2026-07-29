import 'package:equatable/equatable.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

sealed class PoemDetailsState extends Equatable {
  const PoemDetailsState();
}

final class PoemDetailsInitial extends PoemDetailsState {
  const PoemDetailsInitial();

  @override
  List<Object> get props => [];
}

final class PoemDetailsLoading extends PoemDetailsState {
  const PoemDetailsLoading();

  @override
  List<Object> get props => [];
}

final class PoemDetailsLoaded extends PoemDetailsState {
  const PoemDetailsLoaded({required this.poem});

  final Poem poem;

  @override
  List<Object> get props => [poem];
}

final class PoemDetailsMissing extends PoemDetailsState {
  const PoemDetailsMissing();

  @override
  List<Object> get props => [];
}

final class PoemDetailsFailure extends PoemDetailsState {
  const PoemDetailsFailure();

  @override
  List<Object> get props => [];
}
