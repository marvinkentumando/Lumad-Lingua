import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/lesson_provider.dart';
import '../../widgets/learning/unit_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mansaka Curriculum'),
      ),
      body: unitsAsync.when(
        data: (units) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: units.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final unit = units[index];
            return UnitCard(
              unit: unit,
              onTap: () {
                context.push('/unit/${unit.id}');
              },
            );
          },
        ),
        loading: () => const LoadingWidget(message: 'Loading learning path...'),
        error: (err, stack) => AppErrorWidget(
          message: 'Failed to load curriculum: $err',
          onRetry: () => ref.invalidate(unitsProvider),
        ),
      ),
    );
  }
}
