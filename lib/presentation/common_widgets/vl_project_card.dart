import 'package:flutter/material.dart';
import 'package:venturelink/constants/design_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class VLProjectCard extends StatelessWidget {
  final String title;
  final String shortDescription;
  final String creatorName;
  final String? creatorImageUrl;
  final String sector;
  final String fundingRange;
  final List<String> tags;
  final String? imageUrl;
  final bool isPremium;
  final int interestCount;
  final int favoriteCount;
  final int commentCount;
  final VoidCallback onTap;
  final VoidCallback onInterestTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onCommentTap;

  const VLProjectCard({
    super.key,
    required this.title,
    required this.shortDescription,
    required this.creatorName,
    this.creatorImageUrl,
    required this.sector,
    required this.fundingRange,
    required this.tags,
    this.imageUrl,
    this.isPremium = false,
    required this.interestCount,
    required this.favoriteCount,
    required this.commentCount,
    required this.onTap,
    required this.onInterestTap,
    required this.onFavoriteTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Card(
      margin: const EdgeInsets.only(bottom: DesignConstants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignConstants.radiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignConstants.radiusMedium),
                ),
                child: Image.network(
                  imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(DesignConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignConstants.paddingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(
                              DesignConstants.radiusSmall,
                            ),
                          ),
                          child: Text(
                            appLocalizations.premium,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: DesignConstants.bodySmall,
                              fontWeight: DesignConstants.medium,
                            ),
                          ),
                        ),
                      const SizedBox(width: DesignConstants.paddingSmall),
                      Text(
                        sector,
                        style: const TextStyle(
                          color: DesignConstants.darkGrey,
                          fontSize: DesignConstants.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignConstants.paddingSmall),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: DesignConstants.titleMedium,
                      fontWeight: DesignConstants.semiBold,
                    ),
                  ),
                  const SizedBox(height: DesignConstants.paddingSmall),
                  Text(
                    shortDescription,
                    style: const TextStyle(
                      fontSize: DesignConstants.bodyMedium,
                      color: DesignConstants.darkGrey,
                    ),
                  ),
                  const SizedBox(height: DesignConstants.paddingMedium),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: DesignConstants.lightGrey,
                        backgroundImage: creatorImageUrl != null
                            ? NetworkImage(creatorImageUrl!)
                            : null,
                        child: creatorImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 16,
                                color: DesignConstants.darkGrey,
                              )
                            : null,
                      ),
                      const SizedBox(width: DesignConstants.paddingSmall),
                      Text(
                        creatorName,
                        style: const TextStyle(
                          fontSize: DesignConstants.bodySmall,
                          fontWeight: DesignConstants.medium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignConstants.paddingMedium),
                  Wrap(
                    spacing: DesignConstants.paddingSmall,
                    runSpacing: DesignConstants.paddingSmall,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignConstants.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: DesignConstants.lightGrey,
                          borderRadius: BorderRadius.circular(
                            DesignConstants.radiusSmall,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: DesignConstants.bodySmall,
                            color: DesignConstants.darkGrey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: DesignConstants.paddingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fundingRange,
                        style: const TextStyle(
                          fontSize: DesignConstants.bodyMedium,
                          fontWeight: DesignConstants.semiBold,
                          color: DesignConstants.primaryBlue,
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionButton(
                            context: context,
                            icon: Icons.thumb_up_outlined,
                            count: interestCount,
                            onTap: onInterestTap,
                          ),
                          const SizedBox(width: DesignConstants.paddingSmall),
                          _buildActionButton(
                            context: context,
                            icon: Icons.favorite_border,
                            count: favoriteCount,
                            onTap: onFavoriteTap,
                          ),
                          const SizedBox(width: DesignConstants.paddingSmall),
                          _buildActionButton(
                            context: context,
                            icon: Icons.comment_outlined,
                            count: commentCount,
                            onTap: onCommentTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    final locale = Localizations.localeOf(context);
    final numberFormat = NumberFormat.compact(locale: locale.toString());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignConstants.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: DesignConstants.darkGrey,
            ),
            const SizedBox(width: 4),
            Text(
              numberFormat.format(count),
              style: const TextStyle(
                fontSize: DesignConstants.bodySmall,
                color: DesignConstants.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
