import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VLProfileCard extends StatelessWidget {
  final String name;
  final String title;
  final String? photoUrl;
  final String? bio;
  final List<String> expertise;
  final bool isPremium;
  final bool isVerified;
  final VoidCallback onContactTap;
  final VoidCallback onProfileTap;

  const VLProfileCard({
    super.key,
    required this.name,
    required this.title,
    this.photoUrl,
    this.bio,
    this.expertise = const [],
    this.isPremium = false,
    this.isVerified = false,
    required this.onContactTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo de profil, nom et badges
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: AppTheme.primaryBlue,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.darkGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.premiumGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // Bio
            if (bio != null && bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                bio!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.black,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Domaines d'expertise
            if (expertise.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Domaines d\'expertise',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: expertise
                    .take(5)
                    .map((domain) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            domain,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],

            // Actions
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onContactTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: const BorderSide(color: AppTheme.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Contacter'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onProfileTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Voir profil'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
