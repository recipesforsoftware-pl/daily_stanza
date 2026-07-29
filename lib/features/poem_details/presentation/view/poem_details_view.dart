import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_stanza/core/theme/app_colors.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_cubit.dart';
import 'package:daily_stanza/features/poem_details/presentation/cubit/poem_details_state.dart';
import 'package:daily_stanza/features/poem_details/presentation/widgets/poem_details_content.dart';
import 'package:daily_stanza/features/poem_details/presentation/widgets/poem_details_status_view.dart';

class PoemDetailsView extends StatelessWidget {
  const PoemDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Poem')),
      backgroundColor: AppColors.lightBg,
      body: BlocBuilder<PoemDetailsCubit, PoemDetailsState>(
        builder: (context, state) {
          return switch (state) {
            PoemDetailsInitial() => const SizedBox.shrink(),
            PoemDetailsLoading() => const PoemDetailsStatusView(
              title: 'Loading poem\u2026',
              message: 'Taking a calm moment to prepare your reading.',
            ),
            PoemDetailsLoaded(:final poem) => PoemDetailsContent(poem: poem),
            PoemDetailsMissing() => const PoemDetailsStatusView(
              title: 'Poem not found',
              message: 'This poem is no longer available.',
              showStanzi: true,
            ),
            PoemDetailsFailure() => PoemDetailsStatusView(
              title: 'Unable to load poem',
              message: 'Something went wrong. Please try again.',
              showStanzi: true,
              showRetry: true,
              onRetry: () => context.read<PoemDetailsCubit>().retry(),
            ),
          };
        },
      ),
    );
  }
}
