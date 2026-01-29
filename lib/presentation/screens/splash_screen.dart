import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/core/config/config_service.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'dart:async' as async;

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: ConfigService.defaultAnimationDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Délai pour montrer le splash screen
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();

      // 🔴 CRITICAL FIX: Ajouter un timeout strict pour éviter les boucles infinies
      // Si la vérification prend plus de 15 secondes, rediriger vers login
      try {
        await authProvider.checkAndRefreshAuthState().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint(
                "SplashScreen: Auth check timeout (>15s) - suspected infinite loop");
            throw async.TimeoutException(
              'Auth check took too long',
              const Duration(seconds: 15),
            );
          },
        );
      } on async.TimeoutException catch (e) {
        debugPrint(
            "SplashScreen: Auth verification timed out: ${e.message}. Redirecting to login.");
        if (mounted) {
          context.router.replace(const LoginRoute());
        }
        return;
      }

      // Vérifier l'état actuel de l'authentification après rafraîchissement
      debugPrint("SplashScreen: Vérification de l'état d'authentification");
      debugPrint(
          "SplashScreen: isAuthenticated = ${authProvider.isAuthenticated}");
      debugPrint(
          "SplashScreen: currentUser = ${authProvider.currentUser?.email ?? 'null'}");

      if (!mounted) return;

      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        debugPrint(
            "SplashScreen: Utilisateur authentifié, redirection vers l'écran principal");
        context.router.replace(const MainRoute());
      } else {
        // Si l'utilisateur n'est pas authentifié, aller à l'écran de connexion
        debugPrint(
            "SplashScreen: Utilisateur non authentifié, redirection vers l'écran de connexion");
        context.router.replace(const LoginRoute());
      }
    } catch (e) {
      // En cas d'erreur, rediriger vers login
      debugPrint(
          "SplashScreen: Erreur lors de la vérification d'authentification: $e");
      if (mounted) {
        context.router.replace(const LoginRoute());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),
              Text(
                ConfigService.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
