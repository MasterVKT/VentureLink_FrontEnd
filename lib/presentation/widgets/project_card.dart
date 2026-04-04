// lib/presentation/widgets/project_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/core/theme/app_theme.dart';

/// Widget de carte pour afficher un projet dans la liste
/// Mis à jour Sprint 2 - US2.2 : Système de favoris avec animation
class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final bool showStats;
  final Future<dynamic> Function() onFavoriteToggle;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.showStats = true,
    required this.onFavoriteToggle,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with SingleTickerProviderStateMixin {
  // ── Animation ────────────────────────────────────────────────────────────
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // ── État local ────────────────────────────────────────────────────────────
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    // Initialiser depuis le modèle
    _isFavorite = widget.project.isFavorite;

    // Le cœur "pulse" au clic (scale 1.0 → 1.3 → 1.0)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ── BUILD PRINCIPAL ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de couverture + bouton favori superposé
            Stack(
              children: [
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
                // ── FAVORI (Sprint 2 : animé + auto-géré) ──
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildFavoriteButton(),
                ),
              ],
            ),

            // Contenu principal (inchangé depuis Sprint 1)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(context),
                  const SizedBox(height: 8),
                  _buildMetadataRow(context),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 16),
                  _buildFundingSection(context),
                  if (widget.showStats) ...[
                    const SizedBox(height: 12),
                    _buildStatsRow(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BOUTON FAVORI (NOUVEAU - Sprint 2) ────────────────────────────────────

  Widget _buildFavoriteButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _toggleFavorite,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? const Color(0xFFE74C3C) : Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    // 1. Animation pulse
    await _animationController.forward();
    await _animationController.reverse();

    // 2. Mise à jour locale immédiate (UX réactive, pas d'attente réseau)
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // 3. Synchronisation backend via Provider
    final provider = Provider.of<ProjectProvider>(context, listen: false);

    try {
      if (_isFavorite) {
        await provider.addToFavorites(widget.project.id);
        _showSnackBar('coeur Ajouté aux favoris');
      } else {
        await provider.removeFromFavorites(widget.project.id);
        _showSnackBar('Retiré des favoris');
      }
    } catch (_) {
      // 4. Rollback si erreur réseau
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        _showSnackBar('Erreur, réessaie plus tard');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ── BUILD METHODS (identiques au Sprint 1) ────────────────────────────────

  Widget _buildCoverImage() {
    final imageUrl =
        widget.project.primaryImageFullUrl ?? widget.project.primaryImageUrl;

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
        Expanded(
          child: Text(
            widget.project.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.project.isVerified) ...[
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.project.category.nameFr,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (widget.project.location.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.project.location,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      widget.project.shortDescription,
      style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFundingSection(BuildContext context) {
    final fundingProgress =
        (widget.project.progressPercentage / 100.0).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Objectif',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    _formatAmount(widget.project.fundingMax),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF757575)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collecté',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    _formatAmount(widget.project.fundingRaised),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF27AE60)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Progression',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.project.progressPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: fundingProgress,
          minHeight: 6,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Icon(Icons.visibility_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text('${widget.project.viewsCount} vues',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(width: 16),
        Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text('${widget.project.interestsCount} intéressés',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const Spacer(),
        Text(
          _formatDate(widget.project.createdAt ?? DateTime.now()),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ── UTILITAIRES (identiques au Sprint 1) ─────────────────────────────────

  String _formatAmount(double amount, {String? currency}) {
    final symbol =
        _getCurrencySymbol(currency ?? widget.project.fundingCurrency);
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M$symbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K$symbol';
    }
    return '${amount.toStringAsFixed(0)}$symbol';
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
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) {
      return 'il y a ${(diff.inDays / 30).floor()} mois';
    } else if (diff.inDays > 0) {
      return 'il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return 'il y a ${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
    } else if (diff.inMinutes > 0) {
      return 'il y a ${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    }
    return 'à l\'instant';
  }
}
