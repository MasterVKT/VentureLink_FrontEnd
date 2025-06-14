import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/core/config/config_service.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/data/providers/auth_provider.dart';

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

      // Forcer un rafraîchissement de l'état d'authentification
      await authProvider.checkAndRefreshAuthState();

      // Vérifier l'état actuel de l'authentification après rafraîchissement
      print("SplashScreen: Vérification de l'état d'authentification");
      print("SplashScreen: isAuthenticated = ${authProvider.isAuthenticated}");
      print(
          "SplashScreen: currentUser = ${authProvider.currentUser?.email ?? 'null'}");

      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        print(
            "SplashScreen: Utilisateur authentifié, redirection vers l'écran principal");
        context.router.replace(const MainRoute());
      } else {
        // Si l'utilisateur n'est pas authentifié, aller à l'écran de connexion
        print(
            "SplashScreen: Utilisateur non authentifié, redirection vers l'écran de connexion");
        context.router.replace(const LoginRoute());
      }
    } catch (e) {
      // En cas d'erreur, rediriger vers login
      print(
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
