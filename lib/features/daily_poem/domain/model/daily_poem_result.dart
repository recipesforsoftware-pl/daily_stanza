import 'package:equatable/equatable.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';

class DailyPoemResult extends Equatable {
  const DailyPoemResult({required this.poem, required this.isFromCache});

  final Poem poem;
  final bool isFromCache;

  @override
  List<Object> get props => [poem, isFromCache];
}
