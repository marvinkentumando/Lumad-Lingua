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
        title: const Text('Mansaka Dictionary'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).updateQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search Mansaka or English words...',
                prefixIcon: const Icon(Icons.search, color: AppColors.forestGreen),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).updateQuery('');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResultsAsync.when(
              data: (words) {
                if (words.isEmpty) {
                  return const Center(
                    child: Text('No dictionary entries match your search.'),
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
                            decoration: const BoxDecoration(
                              color: AppColors.lightGreenBackground,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.translate, color: AppColors.forestGreen),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vocab.headword,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vocab.translation,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.darkCharcoal.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.softGray,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              vocab.partOfSpeech,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
