import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/presentation/widgets/discover/project_carousel_card.dart';

/// Widget de section avec carousel horizontal pour l'écran Discover
/// Affiche une section avec titre, sous-titre et liste horizontale de projets
class ProjectCarouselSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ProjectModel> projects;
  final VoidCallback? onSeeAll;

  const ProjectCarouselSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.projects,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('Voir tout'),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Carousel horizontal
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return ProjectCarouselCard(
                project: projects[index],
                onTap: () => _navigateToProjectDetail(context, projects[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToProjectDetail(BuildContext context, ProjectModel project) {
    // Navigation vers les détails du projet
    // Implémentée dans l'écran parent
  }
}
