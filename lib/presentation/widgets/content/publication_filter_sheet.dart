import 'package:flutter/material.dart';

class PublicationFilterSheet extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const PublicationFilterSheet({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Titre
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Filtrer les publications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Filtres
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Général
                  _buildSectionTitle(context, 'Général'),
                  _buildFilterTile(
                    context,
                    'all',
                    'Toutes les publications',
                    Icons.all_inclusive,
                  ),
                  _buildFilterTile(
                    context,
                    'featured',
                    'Mises en avant',
                    Icons.star,
                  ),
                  _buildFilterTile(
                    context,
                    'sponsored',
                    'Sponsorisées',
                    Icons.campaign,
                  ),

                  const SizedBox(height: 24),

                  // Section Types
                  _buildSectionTitle(context, 'Types de contenu'),
                  _buildFilterTile(
                    context,
                    'tips',
                    'Conseils',
                    Icons.lightbulb_outline,
                  ),
                  _buildFilterTile(
                    context,
                    'educational',
                    'Éducatif',
                    Icons.school,
                  ),
                  _buildFilterTile(
                    context,
                    'news',
                    'Actualités',
                    Icons.newspaper,
                  ),
                  _buildFilterTile(
                    context,
                    'tutorial',
                    'Tutoriels',
                    Icons.play_lesson,
                  ),
                  _buildFilterTile(
                    context,
                    'motivational',
                    'Motivant',
                    Icons.emoji_emotions,
                  ),

                  const SizedBox(height: 24),

                  // Section Domaines
                  _buildSectionTitle(context, 'Domaines'),
                  _buildFilterTile(
                    context,
                    'entrepreneurship',
                    'Entrepreneuriat',
                    Icons.business_center,
                  ),
                  _buildFilterTile(
                    context,
                    'finance',
                    'Finances et investissements',
                    Icons.account_balance,
                  ),
                  _buildFilterTile(
                    context,
                    'technology',
                    'Technologie',
                    Icons.computer,
                  ),
                  _buildFilterTile(
                    context,
                    'marketing',
                    'Marketing et communication',
                    Icons.campaign,
                  ),
                  _buildFilterTile(
                    context,
                    'leadership',
                    'Leadership',
                    Icons.groups,
                  ),
                  _buildFilterTile(
                    context,
                    'personal_development',
                    'Développement personnel',
                    Icons.self_improvement,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildFilterTile(
    BuildContext context,
    String filterKey,
    String title,
    IconData icon,
  ) {
    final isSelected = selectedFilter == filterKey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        onTap: () {
          onFilterChanged(filterKey);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
