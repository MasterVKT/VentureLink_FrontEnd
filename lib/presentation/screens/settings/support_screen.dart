import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_center,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Centre d\'aide VentureLink',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Trouvez des réponses à vos questions ou contactez notre équipe',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions rapides
            _buildSection(
              context,
              'Actions rapides',
              [
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Chat en direct'),
                  subtitle: const Text('Discutez avec notre équipe support'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'En ligne',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    _showComingSoonDialog(context, 'Chat en direct');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Envoyer un email'),
                  subtitle: const Text('support@venturelink.com'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _launchEmail();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Appeler le support'),
                  subtitle: const Text('+33 1 23 45 67 89'),
                  trailing: const Icon(Icons.call),
                  onTap: () {
                    _launchPhone();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // FAQ
            _buildSection(
              context,
              'Questions fréquentes',
              [
                _buildFAQTile(
                  context,
                  'Comment créer un projet ?',
                  'Pour créer un projet, allez dans l\'onglet "Projets" et appuyez sur le bouton "+" en haut à droite. Remplissez les informations demandées et soumettez votre projet pour validation.',
                ),
                _buildFAQTile(
                  context,
                  'Comment investir dans un projet ?',
                  'Parcourez les projets disponibles, sélectionnez celui qui vous intéresse, et cliquez sur "Investir". Vous pourrez choisir le montant et le type d\'investissement.',
                ),
                _buildFAQTile(
                  context,
                  'Comment modifier mon profil ?',
                  'Allez dans votre profil, appuyez sur "Modifier le profil" et mettez à jour vos informations. N\'oubliez pas de sauvegarder vos modifications.',
                ),
                _buildFAQTile(
                  context,
                  'Comment devenir Premium ?',
                  'Accédez aux abonnements depuis votre profil ou les paramètres. Choisissez l\'abonnement qui vous convient et suivez les étapes de paiement.',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Ressources
            _buildSection(
              context,
              'Ressources',
              [
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Guide de démarrage'),
                  subtitle: const Text('Apprenez les bases de VentureLink'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showComingSoonDialog(context, 'Guide de démarrage');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library_outlined),
                  title: const Text('Tutoriels vidéo'),
                  subtitle: const Text('Regardez nos tutoriels pas à pas'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _showComingSoonDialog(context, 'Tutoriels vidéo');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('Blog & Actualités'),
                  subtitle:
                      const Text('Restez informé des dernières nouveautés'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _showComingSoonDialog(context, 'Blog & Actualités');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Communauté
            _buildSection(
              context,
              'Communauté',
              [
                ListTile(
                  leading: const Icon(Icons.forum_outlined),
                  title: const Text('Forum communautaire'),
                  subtitle: const Text('Échangez avec d\'autres utilisateurs'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _showComingSoonDialog(context, 'Forum communautaire');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('Groupes d\'entrepreneurs'),
                  subtitle: const Text('Rejoignez des groupes thématiques'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showComingSoonDialog(context, 'Groupes d\'entrepreneurs');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Informations sur l'app
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations sur l\'application',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Version'),
                        Text(
                          '1.0.0',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Dernière mise à jour'),
                        Text(
                          '15 décembre 2024',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQTile(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@venturelink.com',
      query: 'subject=Support VentureLink',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email';
      }
    } catch (e) {
      // Fallback: copier l'email dans le presse-papier
      debugPrint('Erreur lors de l\'ouverture de l\'email: $e');
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+33123456789',
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch phone';
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture du téléphone: $e');
    }
  }
}
