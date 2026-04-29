import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../features/home/screens/home_screen.dart';
import '../features/explore/screens/explore_screen.dart';
import '../features/practice/screens/practice_screen.dart';
import '../features/account/screens/account_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    PracticeScreen(),
    AccountScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: AppStrings.home,
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: AppStrings.explore,
    ),
    _NavItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: AppStrings.practice,
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: AppStrings.account,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final selectedColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final unselectedColor = isDark ? AppColors.textHintDark : AppColors.textHint;
    final indicatorColor = isDark
        ? AppColors.textHintDark.withValues(alpha: 0.15)
        : AppColors.textHint.withValues(alpha: 0.2);

    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: dividerColor.withValues(alpha: 0.65),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0x1A1F6B40),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      splashColor: AppColors.primary.withValues(alpha: 0.08),
                      highlightColor: Colors.transparent,
                      onTap: () => setState(() => _currentIndex = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutBack,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  key: ValueKey('${item.label}_$isSelected'),
                                  size: 24,
                                  color: isSelected
                                      ? selectedColor
                                      : unselectedColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? selectedColor
                                    : unselectedColor,
                              ),
                              child: Text(item.label),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              width: isSelected ? 16 : 6,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor
                                    : indicatorColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}
