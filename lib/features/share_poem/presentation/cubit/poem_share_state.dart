import 'package:equatable/equatable.dart';

/// State for [PoemShareCubit].
final class PoemShareState extends Equatable {
  const PoemShareState({
    this.sharingPoemId,
    this.isSharing = false,
    this.mutationError,
  });

  /// The ID of the poem currently being shared, if any.
  final String? sharingPoemId;

  /// Whether a share operation is in progress.
  final bool isSharing;

  /// One-time error message from a failed share mutation.
  ///
  /// The global listener shows it via SnackBar. The next share clears it.
  final String? mutationError;

  PoemShareState copyWith({
    String? Function()? sharingPoemId,
    bool? isSharing,
    String? Function()? mutationError,
  }) {
    return PoemShareState(
      sharingPoemId: sharingPoemId != null
          ? sharingPoemId()
          : this.sharingPoemId,
      isSharing: isSharing ?? this.isSharing,
      mutationError: mutationError != null
          ? mutationError()
          : this.mutationError,
    );
  }

  @override
  List<Object?> get props => [sharingPoemId, isSharing, mutationError];
}
