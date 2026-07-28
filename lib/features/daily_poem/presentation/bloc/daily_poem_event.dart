import 'package:equatable/equatable.dart';

sealed class DailyPoemEvent extends Equatable {
  const DailyPoemEvent();
}

final class DailyPoemRequested extends DailyPoemEvent {
  const DailyPoemRequested({required this.date, required this.languageCode});

  final DateTime date;
  final String languageCode;

  @override
  List<Object> get props => [date, languageCode];
}

final class DailyPoemRetryRequested extends DailyPoemEvent {
  const DailyPoemRetryRequested();

  @override
  List<Object> get props => [];
}
