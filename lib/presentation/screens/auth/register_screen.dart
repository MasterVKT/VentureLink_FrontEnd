import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.registration),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Titre
                Text(
                  appLocalizations.createYourAccount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: AppTheme.defaultSpacing),
                Text(
                  appLocalizations.joinCommunity,
                  style: const TextStyle(
                    color: AppTheme.darkGrey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: AppTheme.defaultPadding * 2),

                // Champs du formulaire
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: appLocalizations.firstName,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return appLocalizations.enterFirstName;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.defaultSpacing),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: appLocalizations.lastName,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return appLocalizations.enterLastName;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.defaultPadding),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: appLocalizations.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.enterEmail;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return appLocalizations.enterValidEmail;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.defaultPadding),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: appLocalizations.password,
                    prefixIcon: const Icon(Icons.lock_outline),
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
                    if (value.length < 6) {
                      return appLocalizations.passwordMinLength(6);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.defaultPadding),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: appLocalizations.confirmPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      tooltip: appLocalizations.passwordVisibility,
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.enterConfirmPassword;
                    }
                    if (value != _passwordController.text) {
                      return appLocalizations.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.defaultPadding),

                // Conditions d'utilisation
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: appLocalizations.agreeToTerms,
                          style: const TextStyle(color: AppTheme.darkGrey),
                          children: [
                            TextSpan(
                              text: appLocalizations.termsOfUse,
                              style: const TextStyle(
                                color: AppTheme.primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: Afficher les conditions d'utilisation
                                },
                            ),
                            TextSpan(text: appLocalizations.and),
                            TextSpan(
                              text: appLocalizations.privacyPolicy,
                              style: const TextStyle(
                                color: AppTheme.primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: Afficher la politique de confidentialité
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.defaultPadding * 2),

                // Bouton d'inscription
                ElevatedButton(
                  onPressed: _acceptTerms ? _handleRegister : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.defaultPadding,
                    ),
                  ),
                  child: Text(
                    appLocalizations.registerButton,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: AppTheme.defaultPadding),

                // Séparateur
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.lightGrey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.defaultSpacing,
                      ),
                      child: Text(
                        appLocalizations.or,
                        style: const TextStyle(color: AppTheme.darkGrey),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppTheme.lightGrey)),
                  ],
                ),

                const SizedBox(height: AppTheme.defaultPadding),

                // Boutons d'inscription sociale
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter l'inscription avec Google
                  },
                  icon: const Icon(Icons.g_mobiledata),
                  label: Text(appLocalizations.signUpWithGoogle),
                ),

                const SizedBox(height: AppTheme.defaultSpacing),

                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter l'inscription avec Apple
                  },
                  icon: const Icon(Icons.apple),
                  label: Text(appLocalizations.signUpWithApple),
                ),

                const SizedBox(height: AppTheme.defaultPadding * 2),

                // Lien de connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appLocalizations.alreadyHaveAccount,
                      style: const TextStyle(color: AppTheme.darkGrey),
                    ),
                    TextButton(
                      onPressed: () {
                        context.router.pop();
                      },
                      child: Text(appLocalizations.loginButtonText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implémenter la logique d'inscription
      context.router.replace(const MainRoute());
    }
  }
}
