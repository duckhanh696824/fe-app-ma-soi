import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/game_provider.dart';

import 'models/game_state.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/game_detail_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/assign_screen.dart';
import 'screens/night_screen.dart';
import 'screens/morning_screen.dart';
import 'screens/day_vote_screen.dart';
import 'screens/hunter_screen.dart';
import 'screens/game_over_screen.dart';

class MaSoiApp extends StatelessWidget {
  const MaSoiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma Sói - Quản Trò',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/':
            page = const HomeScreen();
            break;
          case '/login':
            page = const LoginScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          case '/main':
            page = const MainShellScreen();
            break;
          case '/game-detail':
            page = const GameDetailScreen();
            break;
          case '/setup':
            page = const SetupScreen();
            break;
          case '/assign':
            page = const AssignScreen();
            break;
          case '/night':
            page = const NightScreen();
            break;
          case '/morning':
            page = const MorningScreen();
            break;
          case '/day':
            page = const DayVoteScreen();
            break;
          case '/hunter':
            page = const HunterScreen();
            break;
          case '/gameover':
            page = const GameOverScreen();
            break;
          default:
            page = const HomeScreen();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      },
      builder: (context, child) {
        return Consumer<GameProvider>(
          builder: (context, provider, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handlePhaseNavigation(context, provider);
            });
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }

  void _handlePhaseNavigation(BuildContext context, GameProvider provider) {
    final navigator = Navigator.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    switch (provider.phase) {
      case GamePhase.morning:
        if (currentRoute != '/morning') {
          navigator.pushReplacementNamed('/morning');
        }
        break;
      case GamePhase.gameOver:
        if (currentRoute != '/gameover') {
          navigator.pushReplacementNamed('/gameover');
        }
        break;
      case GamePhase.hunterShoot:
        if (currentRoute != '/hunter') {
          navigator.pushReplacementNamed('/hunter');
        }
        break;
      default:
        break;
    }
  }
}
