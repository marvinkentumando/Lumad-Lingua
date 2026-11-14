import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/dictionary_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class DictionaryScreen extends ConsumerWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResultsAsync = ref.watch(dictionarySearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mansaka Dictionary', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).updateQuery(val);
              },
              style: AppTypography.bodyLarge.copyWith(color: AppColors.creamText),
              decoration: InputDecoration(
                hintText: 'Search Mansaka or English words...',
                hintStyle: AppTypography.body.copyWith(color: AppColors.creamText3),
                prefixIcon: const Icon(Icons.search, color: AppColors.forest500),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.creamText2),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).updateQuery('');
                  },
                ),
                filled: true,
                fillColor: AppColors.creamSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: const BorderSide(color: AppColors.creamBorder, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: const BorderSide(color: AppColors.creamBorder, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  borderSide: const BorderSide(color: AppColors.forest500, width: 2.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResultsAsync.when(
              data: (words) {
                if (words.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: AppColors.creamText3),
                          const SizedBox(height: AppSpacing.md),
                          Text('No dictionary entries match your search.', style: AppTypography.h3.copyWith(color: AppColors.creamText2), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: words.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final vocab = words[index];
                    return AppCard(
                      onTap: () {
                        context.push('/dictionary/details', extra: vocab);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.gold100,
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                              border: Border.all(color: AppColors.gold300),
                            ),
                            child: const Icon(Icons.translate, color: AppColors.gold800, size: 24),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vocab.headword,
                                  style: AppTypography.h3.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vocab.translation,
                                  style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold500,
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                            ),
                            child: Text(
                              vocab.partOfSpeech.toUpperCase(),
                              style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Searching dictionary...'),
              error: (err, stack) => AppErrorWidget(
                message: 'Failed to search dictionary: $err',
                onRetry: () => ref.invalidate(dictionarySearchResultsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
