import 'package:equatable/equatable.dart';

class Poem extends Equatable {
  const Poem({
    required this.id,
    required this.title,
    required this.author,
    required this.languageCode,
    required this.countryCode,
    required this.content,
    required this.sourceName,
    required this.sourceUrl,
    required this.rightsStatus,
  });

  final String id;
  final String title;
  final String author;
  final String languageCode;
  final String countryCode;
  final String content;
  final String sourceName;
  final String sourceUrl;
  final String rightsStatus;

  @override
  List<Object> get props => [
    id,
    title,
    author,
    languageCode,
    countryCode,
    content,
    sourceName,
    sourceUrl,
    rightsStatus,
  ];
}
