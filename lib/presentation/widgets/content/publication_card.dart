import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/publication_model.dart';
import '../../../core/utils/logger.dart';

class PublicationCard extends StatelessWidget {
  final Publication publication;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const PublicationCard({
    super.key,
    required this.publication,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec logo et informations
            _buildHeader(context),

            // Contenu principal
            _buildContent(context),

            // Médias
            if (publication.hasMedia) _buildMedia(context),

            // Statistiques et actions
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo de l'application
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.trending_up,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Informations de publication
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom de l'application
                Text(
                  'VentureLink',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                // Date et type
                Row(
                  children: [
                    Text(
                      publication.formattedPublishedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      publication.typeDisplayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badges
          Column(
            children: [
              if (publication.isFeatured)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mis en avant',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              if (publication.isSponsored)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Sponsorisé',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            publication.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          // Domaine
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              publication.domainDisplayName,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),

          // Résumé
          if (publication.summary != null &&
              publication.summary!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              publication.summary!,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Tags
          if (publication.tagsList.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: publication.tagsList.take(3).map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Information de sponsoring
          if (publication.isSponsored && publication.sponsorName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.campaign,
                    size: 16,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sponsorisé par ${publication.sponsorName}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: _buildMediaContent(context),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    // Priorité : featured_media d'abord, sinon les médias de la liste
    PublicationMedia? mediaToShow;

    AppLogger.info(
        '[CARD] 🖼️ Début _buildMediaContent pour publication ${publication.id}');
    AppLogger.info(
        '[CARD] 💡 featuredMedia: ${publication.featuredMedia?.file ?? 'null'}');
    AppLogger.info('[CARD] 💡 media count: ${publication.media?.length ?? 0}');

    if (publication.featuredMedia != null) {
      mediaToShow = publication.featuredMedia;
      AppLogger.info(
          '[CARD] ✅ Utilisation de featuredMedia: ${mediaToShow!.file}');
      AppLogger.info('[CARD] 🔗 URL complète: ${mediaToShow.fullUrl}');
      AppLogger.info(
          '[CARD] 📷 Type: ${mediaToShow.mediaType}, isImage: ${mediaToShow.isImage}');
    } else if (publication.media != null && publication.media!.isNotEmpty) {
      // Trier les médias par ordre (si disponible)
      final sortedMedia = [...publication.media!]
        ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      mediaToShow = sortedMedia.first;
      AppLogger.info(
          '[CARD] ✅ Utilisation du premier média de la liste: ${mediaToShow.file}');
    }

    if (mediaToShow == null) {
      AppLogger.info('[CARD] ❌ Aucun média à afficher');
      return const SizedBox.shrink();
    }

    // Afficher le média
    if (mediaToShow.isImage) {
      AppLogger.info('[CARD] 🖼️ Affichage image: ${mediaToShow.fullUrl}');
      return _buildSingleImage(context, mediaToShow);
    } else if (mediaToShow.isVideo) {
      AppLogger.info('[CARD] 🎥 Affichage vidéo: ${mediaToShow.fullUrl}');
      return _buildVideoPreview(context, mediaToShow);
    } else if (mediaToShow.isDocument) {
      AppLogger.info('[CARD] 📄 Affichage document: ${mediaToShow.fullUrl}');
      return _buildDocumentPreview(context, [mediaToShow]);
    }

    AppLogger.info(
        '[CARD] ❓ Type de média non reconnu: ${mediaToShow.mediaType}');
    return const SizedBox.shrink();
  }

  Widget _buildImageGallery(
      BuildContext context, List<PublicationMedia> images) {
    if (images.length == 1) {
      return _buildSingleImage(context, images.first);
    } else if (images.length == 2) {
      return _buildTwoImages(context, images);
    } else {
      return _buildMultipleImages(context, images);
    }
  }

  Widget _buildSingleImage(BuildContext context, PublicationMedia image) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: image.fullUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }

  Widget _buildTwoImages(BuildContext context, List<PublicationMedia> images) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[0].fullUrl,
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: CachedNetworkImage(
              imageUrl: images[1].fullUrl,
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleImages(
      BuildContext context, List<PublicationMedia> images) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CachedNetworkImage(
              imageUrl: images[0].fullUrl,
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: images[1].fullUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                if (images.length > 2) ...[
                  const SizedBox(height: 2),
                  Expanded(
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: images[2].fullUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        if (images.length > 3)
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Text(
                                '+${images.length - 3}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context, PublicationMedia video) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Stack(
          children: [
            if (video.file.isNotEmpty)
              CachedNetworkImage(
                imageUrl: video.fullUrl, // Thumbnail de la vidéo
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Vidéo',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
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

  Widget _buildDocumentPreview(
      BuildContext context, List<PublicationMedia> documents) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: documents.map((doc) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    doc.title ?? 'Document',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Icon(
                  Icons.download,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Statistiques
          Row(
            children: [
              _buildStatItem(
                context,
                Icons.visibility,
                publication.viewsCount.toString(),
                'vues',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                context,
                Icons.favorite,
                publication.likesCount.toString(),
                'likes',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                context,
                Icons.comment,
                publication.commentsCount.toString(),
                'commentaires',
              ),
              const Spacer(),
              Text(
                publication.formattedPublishedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                icon: publication.userHasLiked
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: 'J\'aime',
                isActive: publication.userHasLiked,
                onTap: onLike,
              ),
              _buildActionButton(
                context,
                icon: Icons.comment_outlined,
                label: 'Commenter',
                onTap: onComment,
              ),
              _buildActionButton(
                context,
                icon: Icons.share_outlined,
                label: 'Partager',
                onTap: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
