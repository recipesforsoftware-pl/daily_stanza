import 'package:equatable/equatable.dart';

class DailyPoemAssignment extends Equatable {
  const DailyPoemAssignment({
    required this.date,
    required this.languageCode,
    required this.poemId,
    required this.isPublished,
  });

  final DateTime date;
  final String languageCode;
  final String poemId;
  final bool isPublished;

  @override
  List<Object> get props => [date, languageCode, poemId, isPublished];
}
