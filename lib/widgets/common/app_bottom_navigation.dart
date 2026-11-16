import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import 'lumad_background.dart';

class AppBottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNavigation({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    // Provide haptic feedback for tactile responsiveness
    HapticFeedback.selectionClick();

    // Navigate to the selected branch, resetting to initial location if re-tapping current tab
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.gold500 : AppColors.forestGreen;

    return LumadBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.forest700 : AppColors.creamBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SafeArea(
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTap,
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                elevation: 0,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home, color: activeColor),
                    label: 'Home',
                    tooltip: 'Home Screen',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school, color: activeColor),
                    label: 'Learn',
                    tooltip: 'Learning Path',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.book_outlined),
                    selectedIcon: Icon(Icons.book, color: activeColor),
                    label: 'Dictionary',
                    tooltip: 'Lumad Dictionary',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person, color: activeColor),
                    label: 'Profile',
                    tooltip: 'User Profile',
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
