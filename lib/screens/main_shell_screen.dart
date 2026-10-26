import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

import 'roles_tab.dart';
import 'games_tab.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    GamesTab(),
    RolesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark.withValues(alpha: 0.9),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: AppColors.accentPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MA SÓI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
          if (auth.isLoggedIn) ...[
            // User info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.accentPurple.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.accentPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, color: AppColors.accentPurple, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    auth.username,
                    style: const TextStyle(
                      color: AppColors.accentPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.logout, color: AppColors.textMuted, size: 20),
              tooltip: 'Đăng xuất',
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  color: AppColors.accentPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: AppColors.primaryDeep.withValues(alpha: 0.95),
            selectedItemColor: AppColors.accentPurple,
            unselectedItemColor: AppColors.textMuted,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: _currentIndex == 0
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.accentPurple.withValues(alpha: 0.15),
                        )
                      : null,
                  child: const Icon(Icons.sports_esports),
                ),
                label: 'Ván Chơi',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: _currentIndex == 1
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.accentPurple.withValues(alpha: 0.15),
                        )
                      : null,
                  child: const Icon(Icons.theater_comedy),
                ),
                label: 'Vai Trò',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
