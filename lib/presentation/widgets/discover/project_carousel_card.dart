import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget de carte pour afficher un projet dans le carousel de l'écran Discover
/// Carte horizontale compacte pour les sections de découvertes
class ProjectCarouselCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ProjectCarouselCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: _buildImage(),
              ),
            ),

            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      project.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Catégorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        project.category.nameFr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Progression
                    LinearProgressIndicator(
                      value: (project.progressPercentage / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF27AE60),
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),

                    const SizedBox(height: 8),

                    // Montant
                    Text(
                      '${_formatAmount(project.fundingRaised)} / ${_formatAmount(project.fundingMax)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildImage() {
    final imageUrl = project.primaryImageFullUrl ?? project.primaryImageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.business_center_outlined,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _formatAmount(double amount, {String? currency}) {
    final currencySymbol = _getCurrencySymbol(currency ?? project.fundingCurrency);

    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M$currencySymbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K$currencySymbol';
    } else {
      return '${amount.toStringAsFixed(0)}$currencySymbol';
    }
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'XAF':
        return ' FCFA';
      case 'GBP':
        return '£';
      default:
        return ' $currencyCode';
    }
  }
}
