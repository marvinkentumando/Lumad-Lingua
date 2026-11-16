import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../common/brand_card.dart';

class StreakCard extends StatefulWidget {
  final int streakDays;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streakDays,
    this.onTap,
  });

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      context.push('/streaks');
    }
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handleTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: BrandCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: widget.streakDays > 0 ? _pulseAnimation.value : 1.0,
                        child: const Icon(
                          Icons.local_fire_department,
                          color: AppColors.gold500,
                          size: 44,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.streakDays} ${widget.streakDays == 1 ? 'Day' : 'Days'}',
                    style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 32),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Current Learning Streak',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: dayLabels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dayLabel = entry.value;
                  final dayFullName = dayNames[index];
                  final isActive = index < (widget.streakDays % 7 == 0 && widget.streakDays > 0 ? 7 : widget.streakDays % 7);

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isActive
                                ? '🔥 $dayFullName practice completed! Streak intact.'
                                : '⚡ $dayFullName pending practice.',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: isActive ? AppColors.forest500 : AppColors.forest700,
                        ),
                      );
                    },
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 80)),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Column(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.gold500 : AppColors.forest700,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isActive ? AppColors.gold700 : AppColors.forest300,
                                    width: 1.5,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppColors.gold500.withValues(alpha: 0.4),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Icon(
                                    isActive ? Icons.check : Icons.remove,
                                    color: isActive ? AppColors.forest900 : AppColors.creamText3,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dayLabel,
                                style: AppTypography.labelBold.copyWith(
                                  color: isActive ? AppColors.gold400 : AppColors.creamBorder,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
