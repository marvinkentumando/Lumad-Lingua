import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class LumadBackground extends StatelessWidget {
  final Widget child;

  const LumadBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.forest900, const Color(0xFF051408)]
                : [const Color(0xFFFEF8ED), const Color(0xFFF1E2C8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
