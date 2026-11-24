import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/lesson_provider.dart';
import '../../widgets/learning/lesson_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/lumad_background.dart';

class UnitDetailsScreen extends ConsumerWidget {
  final String unitId;

  const UnitDetailsScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(unitLessonsProvider(unitId));

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: lessonsAsync.when(
            skipLoadingOnRefresh: true,
            data: (lessons) => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const ScreenHeader(
                  title: 'Unit Lessons',
                  subtitle: 'Complete all lessons to master this unit',
                ),
                const SizedBox(height: AppSpacing.sm),
                ...lessons.map((lesson) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: LessonCard(
                        lesson: lesson,
                        onTap: () {
                          context.push('/lesson/${lesson.id}');
                        },
                      ),
                    )),
              ],
            ),
            loading: () => const LoadingWidget(message: 'Loading unit lessons...'),
            error: (err, stack) => AppErrorWidget(
              message: 'Failed to load lessons: $err',
              onRetry: () => ref.invalidate(unitLessonsProvider(unitId)),
            ),
          ),
        ),
      ),
    );
  }
}
