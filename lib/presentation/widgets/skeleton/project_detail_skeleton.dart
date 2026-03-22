import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:venturelink/core/config/app_config.dart';

/// Skeleton loader pour ProjectDetailScreen
/// Affiche un effet de chargement shimmer qui mime la structure détaillée d'un projet
class ProjectDetailSkeleton extends StatelessWidget {
  const ProjectDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar skeleton
          SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 280,
                width: double.infinity,
                color: Colors.grey[300],
              ),
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  _buildSkeletonLine(width: double.infinity * 0.8, height: 28),

                  const SizedBox(height: 16),

                  // Description courte
                  _buildSkeletonLine(width: double.infinity * 0.9, height: 18),
                  _buildSkeletonLine(width: double.infinity * 0.7, height: 18),

                  const SizedBox(height: 24),

                  // Statistiques
                  Row(
                    children: [
                      _buildStatChip(),
                      const SizedBox(width: 16),
                      _buildStatChip(),
                      const SizedBox(width: 16),
                      _buildStatChip(),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: _buildSkeletonButton(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSkeletonButton(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section Description
                  _buildSectionTitle(),

                  const SizedBox(height: 16),

                  _buildSkeletonLine(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  _buildSkeletonLine(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  _buildSkeletonLine(width: double.infinity * 0.9, height: 16),
                  const SizedBox(height: 8),
                  _buildSkeletonLine(width: double.infinity * 0.8, height: 16),
                  const SizedBox(height: 8),
                  _buildSkeletonLine(width: double.infinity * 0.6, height: 16),

                  const SizedBox(height: 32),

                  // Section Informations
                  _buildSectionTitle(),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(),
                        const Divider(height: 24),
                        _buildInfoRow(),
                        const Divider(height: 24),
                        _buildInfoRow(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section Tags
                  _buildSectionTitle(),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      5,
                      (index) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const SizedBox(
                            width: 60,
                            height: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section Créateur
                  _buildSectionTitle(),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSkeletonLine(width: 150, height: 18),
                              const SizedBox(height: 8),
                              _buildSkeletonLine(width: 100, height: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 140,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLine({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 200,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildStatChip() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 40,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonButton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 3,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
