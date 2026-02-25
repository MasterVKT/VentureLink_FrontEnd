import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Bienvenue sur VentureLink',
      subtitle:
          'Votre plateforme de mise en relation entrepreneurs-investisseurs',
      description:
          'Découvrez des projets innovants ou trouvez les financements pour vos idées.',
      image: 'assets/images/onboarding/welcome.png',
      backgroundColor: AppTheme.primaryColor,
    ),
    OnboardingPageData(
      title: 'Créez et présentez vos projets',
      subtitle: 'Mettez en avant vos idées entrepreneuriales',
      description:
          'Créez des profils détaillés pour vos projets avec photos, business plan et prévisions financières.',
      image: 'assets/images/onboarding/create_project.png',
      backgroundColor: AppTheme.accentColor,
    ),
    OnboardingPageData(
      title: 'Trouvez des investisseurs',
      subtitle: 'Connectez-vous avec les bons partenaires',
      description:
          'Notre algorithme vous met en relation avec des investisseurs alignés sur vos secteurs d\'activité.',
      image: 'assets/images/onboarding/find_investors.png',
      backgroundColor: AppTheme.secondaryColor,
    ),
    OnboardingPageData(
      title: 'Découvrez des opportunités',
      subtitle: 'Explorez des projets prometteurs',
      description:
          'Parcourez une sélection de projets vérifiés et investissez dans l\'avenir.',
      image: 'assets/images/onboarding/discover_projects.png',
      backgroundColor: AppTheme.successColor,
    ),
    OnboardingPageData(
      title: 'Communiquez facilement',
      subtitle: 'Échangez en toute sécurité',
      description:
          'Messagerie intégrée, partage de documents et suivi des négociations.',
      image: 'assets/images/onboarding/communicate.png',
      backgroundColor: AppTheme.premiumGold,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header avec skip button
            Padding(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'VentureLink',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Skip button
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Passer'),
                    ),
                ],
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConfig.defaultPadding),
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? _pages[_currentPage].backgroundColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Row(
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Précédent'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _pages[_currentPage].backgroundColor,
                          side: BorderSide(
                              color: _pages[_currentPage].backgroundColor),
                        ),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),

                  if (_currentPage > 0) const SizedBox(width: 16),

                  // Next/Complete button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentPage == _pages.length - 1
                          ? _completeOnboarding
                          : _nextPage,
                      icon: Icon(_currentPage == _pages.length - 1
                          ? Icons.check
                          : Icons.arrow_forward),
                      label: Text(_currentPage == _pages.length - 1
                          ? 'Commencer'
                          : 'Suivant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].backgroundColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    page.backgroundColor.withValues(alpha: 0.1),
                    page.backgroundColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for image (would be actual image in production)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: page.backgroundColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getPageIcon(_currentPage),
                      size: 80,
                      color: page.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Content
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  page.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: page.backgroundColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  page.subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),

                // Specific features for certain pages
                if (_currentPage == 1) ...[
                  const SizedBox(height: 24),
                  _buildFeaturesList([
                    'Business plan interactif',
                    'Galerie photos/vidéos',
                    'Prévisions financières',
                    'Suivi des métriques',
                  ]),
                ] else if (_currentPage == 2) ...[
                  const SizedBox(height: 24),
                  _buildFeaturesList([
                    'Matching par secteur d\'activité',
                    'Filtres avancés',
                    'Historique d\'investissement',
                    'Scores de compatibilité',
                  ]),
                ] else if (_currentPage == 3) ...[
                  const SizedBox(height: 24),
                  _buildFeaturesList([
                    'Projets vérifiés',
                    'Due diligence simplifiée',
                    'Tableaux de bord',
                    'Suivi de portefeuille',
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(List<String> features) {
    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: _pages[_currentPage].backgroundColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  IconData _getPageIcon(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return Icons.rocket_launch;
      case 1:
        return Icons.business_center;
      case 2:
        return Icons.people;
      case 3:
        return Icons.search;
      case 4:
        return Icons.chat;
      default:
        return Icons.star;
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Marquer l'onboarding comme terminé
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Navigation vers l'écran d'authentification
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final Color backgroundColor;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.backgroundColor,
  });
}
