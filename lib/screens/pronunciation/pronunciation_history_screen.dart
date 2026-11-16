import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/pronunciation_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';

class PronunciationHistoryScreen extends ConsumerWidget {
  const PronunciationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pronunciationProvider);
    final history = state.history;

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const ScreenHeader(
                title: 'Practice History',
                subtitle: 'Review your past pronunciation attempts and scores',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 64, color: AppColors.creamText3),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No practice history yet. Record some phrases in the Pronunciation Lab!',
                        style: AppTypography.h3.copyWith(color: AppColors.subtitleColor(context)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...history.map((attempt) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: BrandCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attempt.phrase,
                                  style: AppTypography.lessonTitle.copyWith(color: Colors.white, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Attempted at ${attempt.timestamp.hour}:${attempt.timestamp.minute.toString().padLeft(2, '0')} • ${attempt.timestamp.day}/${attempt.timestamp.month}/${attempt.timestamp.year}',
                                  style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold500,
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                            ),
                            child: Text(
                              '${attempt.score.toStringAsFixed(1)}%',
                              style: AppTypography.labelBold.copyWith(color: AppColors.forest900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
