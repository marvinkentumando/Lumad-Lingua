import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';

enum BrandButtonType { primary, secondary, success, danger, small, text }

class BrandButton extends StatefulWidget {
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
  State<BrandButton> createState() => _BrandButtonState();
}

class _BrandButtonState extends State<BrandButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _isDebouncing = false;

  void _handleTap() async {
    if (_isDebouncing || widget.isLoading || widget.onPressed == null) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Debounce 500ms
    setState(() => _isDebouncing = true);
    widget.onPressed!();

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isDebouncing = false);
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() => _scale = 1.0);
    _handleTap();
  }

  void _onTapCancel() {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    switch (widget.type) {
      case BrandButtonType.primary:
        bgColor = isDark ? AppColors.gold500 : AppColors.forest500;
        fgColor = isDark ? AppColors.forest900 : Colors.white;
        break;
      case BrandButtonType.secondary:
        bgColor = Colors.transparent;
        fgColor = isDark ? Colors.white : AppColors.forest500;
        borderSide = BorderSide(color: isDark ? AppColors.gold500 : AppColors.forest500, width: 2);
        break;
      case BrandButtonType.success:
        bgColor = AppColors.semanticGreen;
        fgColor = Colors.white;
        break;
      case BrandButtonType.danger:
        bgColor = AppColors.semanticRed;
        fgColor = Colors.white;
        break;
      case BrandButtonType.small:
        bgColor = AppColors.forest500;
        fgColor = Colors.white;
        break;
      case BrandButtonType.text:
        bgColor = Colors.transparent;
        fgColor = isDark ? AppColors.gold500 : AppColors.forest500;
        break;
    }

    final buttonHeight = widget.type == BrandButtonType.small ? 40.0 : AppSpacing.buttonHeight;
    final borderRadius = BorderRadius.circular(AppRadius.button);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            color: widget.onPressed == null ? AppColors.disabled : bgColor,
            borderRadius: borderRadius,
            border: borderSide != null ? Border.all(color: borderSide.color, width: borderSide.width) : null,
            boxShadow: widget.type == BrandButtonType.text || widget.onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: (isDark ? Colors.black : AppColors.creamShadow).withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 20, color: fgColor),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTypography.labelBold.copyWith(
                              color: fgColor,
                              fontSize: widget.type == BrandButtonType.small ? 13 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
