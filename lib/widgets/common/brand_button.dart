import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_radius.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';
import '../../providers/theme_provider.dart';
import '../../utils/audio_helper.dart';

enum BrandButtonType { primary, secondary, gold, success, danger, small, text }

class BrandButton extends ConsumerStatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final BrandButtonType type;
  final IconData? icon;
  final bool isLoading;

  const BrandButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = BrandButtonType.primary,
    this.icon,
    this.isLoading = false,
  });

  @override
  ConsumerState<BrandButton> createState() => _BrandButtonState();
}

class _BrandButtonState extends ConsumerState<BrandButton> {
  bool _isPressed = false;
  bool _isDebouncing = false;

  void _handleTap() async {
    if (_isDebouncing || widget.isLoading || widget.onPressed == null) return;

    HapticFeedback.lightImpact();
    AudioHelper.playSfx(AudioHelper.sfxClick, enabled: ref.read(soundEffectsProvider));

    setState(() => _isDebouncing = true);
    widget.onPressed!();

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isDebouncing = false);
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _handleTap();
  }

  void _onTapCancel() {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCustomActive = ref.watch(customThemeAccentProvider);

    Color? bgColor;
    Gradient? bgGradient;
    Color fgColor;
    Color lipColor;
    double lipHeight = 3.0;
    Border? border;

    switch (widget.type) {
      case BrandButtonType.primary:
      case BrandButtonType.small:
        bgColor = isCustomActive ? const Color(0xFFA91D3A) : AppColors.forest500;
        fgColor = Colors.white;
        lipColor = isCustomActive ? const Color(0xFF5C0E1E) : AppColors.forest700;
        break;
      case BrandButtonType.gold:
        bgGradient = const LinearGradient(
          colors: [Color(0xFFFFD54F), AppColors.gold500, Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        fgColor = AppColors.forest900;
        lipColor = const Color(0xFFC78C00);
        border = Border.all(color: AppColors.gold700, width: 1.0);
        break;
      case BrandButtonType.secondary:
        bgColor = AppColors.creamSurface;
        fgColor = AppColors.creamText;
        lipColor = AppColors.creamBorder;
        lipHeight = 2.0;
        border = Border.all(color: AppColors.creamBorder, width: 1.0);
        break;
      case BrandButtonType.success:
        bgColor = AppColors.semanticGreen;
        fgColor = Colors.white;
        lipColor = AppColors.successDark;
        break;
      case BrandButtonType.danger:
        bgColor = AppColors.semanticRed;
        fgColor = Colors.white;
        lipColor = AppColors.errorDark;
        break;
      case BrandButtonType.text:
        bgColor = Colors.transparent;
        fgColor = isDark ? AppColors.gold500 : (isCustomActive ? const Color(0xFFA91D3A) : AppColors.forest500);
        lipColor = Colors.transparent;
        lipHeight = 0.0;
        break;
    }

    if (widget.onPressed == null) {
      bgColor = AppColors.disabled;
      bgGradient = null;
      lipColor = AppColors.creamBorder;
    }

    final buttonHeight = widget.type == BrandButtonType.small ? 40.0 : AppSpacing.buttonHeight;
    final borderRadius = BorderRadius.circular(AppRadius.button);

    // Tactile press offset: shifts down by 2px when pressed, lip height shrinks from 3px/2px to 1px
    final translateY = _isPressed ? 2.0 : 0.0;
    final activeLipHeight = _isPressed ? 1.0 : lipHeight;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, translateY, 0),
        height: buttonHeight,
        decoration: BoxDecoration(
          color: bgGradient == null ? bgColor : null,
          gradient: bgGradient,
          borderRadius: borderRadius,
          border: border,
          boxShadow: widget.type == BrandButtonType.text || widget.onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: lipColor,
                    offset: Offset(0, activeLipHeight),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.type == BrandButtonType.small ? 8 : 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20, color: fgColor),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.text,
                            style: AppTypography.labelBold.copyWith(
                              color: fgColor,
                              fontSize: widget.type == BrandButtonType.small ? 13 : 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
