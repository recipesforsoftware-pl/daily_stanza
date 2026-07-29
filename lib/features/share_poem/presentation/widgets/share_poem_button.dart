import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/features/daily_poem/domain/model/poem.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_cubit.dart';
import 'package:daily_stanza/features/share_poem/presentation/cubit/poem_share_state.dart';

/// A reusable button that triggers the native share sheet for a [Poem].
///
/// Reads [PoemShareCubit] from the widget tree.
/// Calculates its own global [Rect] for correct iPad popover positioning.
///
/// When [label] is provided, renders as a TextButton.icon with the label text;
/// otherwise renders as an icon-only IconButton (suitable for AppBar actions).
class SharePoemButton extends StatelessWidget {
  const SharePoemButton({required this.poem, this.label, super.key});

  /// The poem to share when the button is pressed.
  final Poem poem;

  /// Optional label text. When provided, the button is rendered as a
  /// [TextButton.icon] with this label alongside the share icon.
  /// When null, the button is rendered as an [IconButton].
  final String? label;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PoemShareCubit, PoemShareState>(
      builder: (context, state) {
        final isSharing = state.isSharing && state.sharingPoemId == poem.id;

        if (label != null) {
          return Semantics(
            label: 'Share poem',
            child: TextButton.icon(
              onPressed: isSharing ? null : () => _share(context),
              icon: isSharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share, size: 18),
              label: Text(label!),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          );
        }

        return Semantics(
          label: 'Share poem',
          child: IconButton(
            icon: isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            tooltip: 'Share poem',
            onPressed: isSharing ? null : () => _share(context),
          ),
        );
      },
    );
  }

  void _share(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final origin = renderBox == null
        ? null
        : renderBox.localToGlobal(Offset.zero) & renderBox.size;
    context.read<PoemShareCubit>().sharePoem(poem, sharePositionOrigin: origin);
  }
}
