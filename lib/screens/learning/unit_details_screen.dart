import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/lesson_provider.dart';
import '../../widgets/learning/lesson_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class UnitDetailsScreen extends ConsumerWidget {
  final String unitId;

  const UnitDetailsScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(unitLessonsProvider(unitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Lessons'),
      ),
      body: lessonsAsync.when(
        data: (lessons) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: lessons.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return LessonCard(
              lesson: lesson,
              onTap: () {
                context.push('/lesson/${lesson.id}');
              },
            );
          },
        ),
        loading: () => const LoadingWidget(message: 'Loading lessons...'),
        error: (err, stack) => AppErrorWidget(
          message: 'Failed to load lessons: $err',
          onRetry: () => ref.invalidate(unitLessonsProvider(unitId)),
        ),
      ),
    );
  }
}
