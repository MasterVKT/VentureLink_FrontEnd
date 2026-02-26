
import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget de carte pour afficher un projet dans la liste
/// Conforme aux spécifications Sprint 1 - Tâche 1.1.1
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle; //  Action quand on clique sur le cœur
  final bool showStats;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onFavoriteToggle,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture (ratio 16:9, height 200px)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: _buildCoverImage(),
              ),
            ),

            // Contenu principal
            // 
            //  MODIFIÉ : Image + Bouton Favori superposé
            // 
            Stack(
              children: [
                // Image du projet (code existant)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: project.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: project.images.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.business_center,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),

                //  NOUVEAU : Bouton Favori en haut à droite
                if (onFavoriteToggle != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          // Cœur plein si favori, vide sinon
                          project.isFavorite 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          color: const Color(0xFFE74C3C), // Rouge selon Sprint
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Contenu de la carte (code existant - inchangé)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et bouton favoris
                  _buildTitleRow(context),
                  const SizedBox(height: 8),

                  // Catégorie et localisation
                  _buildMetadataRow(context),
                  const SizedBox(height: 12),

                  // Description (2 lignes max)
                  _buildDescription(),
                  const SizedBox(height: 16),

                  // Barre de progression et infos financement
                  _buildFundingSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUILD METHODS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildCoverImage() {
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
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        // Titre du projet
        Expanded(
          child: Text(
            project.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Badge "Vérifié" si premium/featured
        if (project.isVerified) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Vérifié',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          project.category.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (project.location.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            project.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Bouton favoris (cœur)
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onFavoriteToggle,
          child: Icon(
            project.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: project.isFavorite ? const Color(0xFFE74C3C) : Colors.grey,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
      children: [
        // Chip catégorie
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            project.category.nameFr,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Localité (si disponible)
        if (project.location.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.location_on_outlined,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              project.location,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      project.shortDescription,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFundingSection(BuildContext context) {
    // Calcul de la progression
    final fundingProgress = project.fundingMax > 0
        ? (project.fundingRaised / project.fundingMax).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        // Infos de financement
        Row(
          children: [
            // Objectif
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Objectif',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Objectif de financement et progression
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Objectif',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatAmount(project.fundingMax),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collecté',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatAmount(project.fundingRaised),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Progression',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${project.progressPercentage.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

                  const SizedBox(height: 12),

                  // Barre de progression
                  LinearProgressIndicator(
                    value: project.progressPercentage / 100.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatAmount(project.fundingRaised),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ],
              ),
            ),

            // Progression %
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Progression',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(fundingProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Barre de progression
        LinearProgressIndicator(
          value: fundingProgress,
          minHeight: 6,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(
            Color(0xFF27AE60),
          ),
          borderRadius: BorderRadius.circular(3),
        ),

        // Statistiques (optionnel)
        if (showStats) ...[
          const SizedBox(height: 16),
          _buildStatsRow(),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Vues
        Icon(Icons.visibility_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${project.viewsCount} vues',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),

        const SizedBox(width: 16),

        // Intéressés
        Icon(Icons.favorite_outline, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${project.interestsCount} intéressés',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),

        const Spacer(),

        // Date
        Text(
          _formatDate(project.createdAt ?? DateTime.now()),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UTILITAIRES
  // ───────────────────────────────────────────────────────────────────────────

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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }
}