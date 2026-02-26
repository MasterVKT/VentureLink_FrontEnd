import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/core/config/config_service.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/l10n/app_localizations.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final router = context.router;

      try {
        // Désactiver le bouton de connexion pendant la tentative
        authProvider.setLoading(true);

        // Tenter de se connecter
        final success = await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );

        // Vérifier si l'utilisateur est connecté après la tentative
        if (success && mounted && authProvider.isAuthenticated) {
          debugPrint("Login réussi, redirection vers l'écran principal");
          router.replace(const MainRoute());
        } else if (mounted) {
          // Si l'authentification a échoué mais qu'elle a réussi dans Firebase
          // (cas où success est false mais authProvider.isAuthenticated est true après rafraîchissement)
          if (authProvider.isAuthenticated) {
            debugPrint("Login réussi après vérification supplémentaire");
            router.replace(const MainRoute());
          } else {
            // Afficher un snackbar avec le message d'erreur
            if (authProvider.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authProvider.error!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Une erreur inattendue est survenue: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        // S'assurer que le bouton de connexion est réactivé
        if (mounted) {
          authProvider.setLoading(false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ConfigService.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    appLocalizations.welcomeToApp(ConfigService.appName),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ConfigService.defaultPadding),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: appLocalizations.email,
                      hintText: appLocalizations.emailHint,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.enterEmail;
                      }
                      if (!RegExp(ConfigService.emailRegex).hasMatch(value)) {
                        return appLocalizations.enterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ConfigService.defaultSpacing),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: appLocalizations.password,
                      hintText: appLocalizations.passwordHint,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        tooltip: appLocalizations.passwordVisibility,
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.enterPassword;
                      }
                      if (value.length < ConfigService.minPasswordLength) {
                        return appLocalizations
                            .passwordMinLength(ConfigService.minPasswordLength);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ConfigService.defaultSpacing),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      Text(appLocalizations.rememberMe),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          context.router.push(const ForgotPasswordRoute());
                        },
                        child: Text(appLocalizations.forgotPassword),
                      ),
                    ],
                  ),
                  const SizedBox(height: ConfigService.defaultPadding),
                  if (authProvider.error != null)
                    Container(
                      padding:
                          const EdgeInsets.all(ConfigService.defaultSpacing),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(
                            ConfigService.defaultBorderRadius),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: ConfigService.defaultSpacing),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (authProvider.error != null)
                    const SizedBox(height: ConfigService.defaultSpacing),
                  FilledButton(
                    onPressed: authProvider.isLoading ? null : _login,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(appLocalizations.loginButtonText),
                  ),
                  const SizedBox(height: ConfigService.defaultSpacing),
                  OutlinedButton(
                    onPressed: () {
                      context.router.push(const RegisterRoute());
                    },
                    child: Text(appLocalizations.createAccount),
                  ),
                  const SizedBox(height: ConfigService.defaultPadding),

                  // Bouton de debug pour aider à diagnostiquer les problèmes d'authentification
                  if (ConfigService.isDebugMode)
                    TextButton(
                      onPressed: () {
                        final authProvider = context.read<AuthProvider>();
                        final state = authProvider.isAuthenticated
                            ? "Connecté (${authProvider.currentUser?.email})"
                            : "Non connecté";
                        final error = authProvider.error ?? "Aucune erreur";

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Debug Authentification'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('État: $state'),
                                const SizedBox(height: 8),
                                Text('Erreur: $error'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Fermer'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Déboguer Authentification'),
                    ),

                  // Bouton pour forcer le rafraîchissement de l'état d'authentification
                  if (ConfigService.isDebugMode)
                    TextButton(
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final router = context.router;

                        // Afficher un indicateur de chargement
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        // Rafraîchir l'état d'authentification
                        await authProvider.checkAndRefreshAuthState();

                        // Fermer l'indicateur de chargement
                        if (mounted) {
                          navigator.pop();
                        }

                        // Afficher le résultat
                        if (mounted) {
                          final state = authProvider.isAuthenticated
                              ? "Connecté (${authProvider.currentUser?.email})"
                              : "Non connecté";

                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('État d\'authentification: $state'),
                            ),
                          );

                          // Si l'utilisateur est authentifié, rediriger vers l'écran principal
                          if (authProvider.isAuthenticated && mounted) {
                            router.replace(const MainRoute());
                          }
                        }
                      },
                      child: const Text('Rafraîchir Auth'),
                    ),

                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ConfigService.defaultSpacing,
                        ),
                        child: Text(
                          appLocalizations.continueWith,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: ConfigService.defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        label: appLocalizations.googleLogin,
                        onPressed: () async {
                          final router = context.router;
                          final success = await authProvider.loginWithGoogle();
                          if (success && mounted) {
                            router.replace(const MainRoute());
                          }
                        },
                      ),
                      _buildSocialButton(
                        icon: Icons.apple,
                        label: appLocalizations.appleLogin,
                        onPressed: () async {
                          final router = context.router;
                          final success = await authProvider.loginWithApple();
                          if (success && mounted) {
                            router.replace(const MainRoute());
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(120, 40),
      ),
    );
  }
}
