import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Skeleton d'une seule carte projet

class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // ✅ Un seul Shimmer englobant : effet de lumière synchronisé
      //    sur toute la carte (meilleure approche du collègue)
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image de couverture 
            const _SkeletonBox(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Titre + bouton favoris ─────────────────────────────
                  Row(
                    children: [
                      const Expanded(
                        child: _SkeletonBox(
                          width: double.infinity,
                          height: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _SkeletonBox(
                        width: 28,
                        height: 28,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Description ligne 1 ───────────────────────────────
                  const _SkeletonBox(
                    width: double.infinity,
                    height: 16,
                  ),

                  const SizedBox(height: 4),

                  // ── Description ligne 2 (70% de la largeur) ──────────
                  // ✅ FractionallySizedBox — corrige double.infinity * 0.7
                  const FractionallySizedBox(
                    widthFactor: 0.7,
                    child: _SkeletonBox(
                      width: double.infinity,
                      height: 16,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Barre de progression financement ─────────────────
                  _SkeletonBox(
                    width: double.infinity,
                    height: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),

                  const SizedBox(height: 8),

                  // ── Montants collecté / objectif ──────────────────────
                  const _SkeletonBox(width: 200, height: 16),

                  const SizedBox(height: 10),

                  // ── Chips métadonnées (catégorie + localisation) ──────
                  Row(
                    children: [
                      _SkeletonBox(
                        width: 90,
                        height: 28,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const SizedBox(width: 8),
                      _SkeletonBox(
                        width: 110,
                        height: 28,
                        borderRadius: BorderRadius.circular(20),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget interne réutilisable — un bloc gris arrondi
// ─────────────────────────────────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Liste de N skeletons — à passer directement à firstPageProgressIndicatorBuilder
//
// Utilisation dans ProjectListScreen :
//   firstPageProgressIndicatorBuilder: (context) =>
//       const ProjectCardSkeletonList(),
// ─────────────────────────────────────────────────────────────────────────────

class ProjectCardSkeletonList extends StatelessWidget {
  /// Nombre de cartes skeleton à afficher (défaut : 5)
  final int count;

  const ProjectCardSkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => const ProjectCardSkeleton(),
    );
  }
}