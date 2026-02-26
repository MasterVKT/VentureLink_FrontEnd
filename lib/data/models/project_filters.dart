/// Modèle pour les filtres de recherche de projets
/// Utilisé pour la recherche et le filtrage dans ProjectListScreen
class ProjectFilters {
  final String? searchQuery;
  final String? categoryId;
  final String? stage;
  final String? locationCountry;
  final String? locationCity;
  final double? fundingMin;
  final double? fundingMax;
  final List<String> tagIds;
  final String? sortBy;
  final bool? isFeatured;
  final bool? isPremium;

  const ProjectFilters({
    this.searchQuery,
    this.categoryId,
    this.stage,
    this.locationCountry,
    this.locationCity,
    this.fundingMin,
    this.fundingMax,
    this.tagIds = const [],
    this.sortBy = 'created_at',
    this.isFeatured,
    this.isPremium,
  });

  /// Crée une copie des filtres avec les champs modifiés
  ProjectFilters copyWith({
    String? searchQuery,
    String? categoryId,
    String? stage,
    String? locationCountry,
    String? locationCity,
    double? fundingMin,
    double? fundingMax,
    List<String>? tagIds,
    String? sortBy,
    bool? isFeatured,
    bool? isPremium,
  }) {
    return ProjectFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
      stage: stage ?? this.stage,
      locationCountry: locationCountry ?? this.locationCountry,
      locationCity: locationCity ?? this.locationCity,
      fundingMin: fundingMin ?? this.fundingMin,
      fundingMax: fundingMax ?? this.fundingMax,
      tagIds: tagIds ?? this.tagIds,
      sortBy: sortBy ?? this.sortBy,
      isFeatured: isFeatured ?? this.isFeatured,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  /// Vérifie si des filtres sont actifs (hors searchQuery)
  bool get hasActiveFilters {
    return categoryId != null ||
        stage != null ||
        locationCountry != null ||
        locationCity != null ||
        fundingMin != null ||
        fundingMax != null ||
        tagIds.isNotEmpty ||
        isFeatured == true ||
        isPremium == true;
  }

  /// Vérifie si la recherche est active
  bool get hasSearchQuery => searchQuery != null && searchQuery!.isNotEmpty;

  /// Vérifie si tous les filtres sont vides
  bool get isEmpty => !hasSearchQuery && !hasActiveFilters;

  /// Nombre de filtres actifs (pour le badge)
  int get activeFiltersCount {
    int count = 0;
    if (categoryId != null) count++;
    if (stage != null) count++;
    if (locationCountry != null) count++;
    if (locationCity != null) count++;
    if (fundingMin != null) count++;
    if (fundingMax != null) count++;
    if (tagIds.isNotEmpty) count++;
    if (isFeatured == true) count++;
    if (isPremium == true) count++;
    return count;
  }

  /// Convertit les filtres en paramètres pour l'API
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }
    if (categoryId != null) {
      params['category'] = categoryId;
    }
    if (stage != null) {
      params['stage'] = stage;
    }
    if (locationCountry != null) {
      params['location_country'] = locationCountry;
    }
    if (locationCity != null) {
      params['location_city'] = locationCity;
    }
    if (fundingMin != null) {
      params['funding_min'] = fundingMin;
    }
    if (fundingMax != null) {
      params['funding_max'] = fundingMax;
    }
    if (tagIds.isNotEmpty) {
      params['tags'] = tagIds.join(',');
    }
    if (sortBy != null) {
      params['sort_by'] = sortBy;
    }
    if (isFeatured == true) {
      params['is_featured'] = 'true';
    }
    if (isPremium == true) {
      params['is_premium'] = 'true';
    }

    return params;
  }

  /// Réinitialise tous les filtres
  ProjectFilters clear() {
    return const ProjectFilters();
  }

  /// Réinitialise uniquement la recherche
  ProjectFilters clearSearch() {
    return copyWith(searchQuery: null);
  }

  /// Réinitialise tous les filtres sauf la recherche
  ProjectFilters clearFilters() {
    return copyWith(
      categoryId: null,
      stage: null,
      locationCountry: null,
      locationCity: null,
      fundingMin: null,
      fundingMax: null,
      tagIds: const [],
      isFeatured: null,
      isPremium: null,
    );
  }

  @override
  String toString() {
    return 'ProjectFilters(searchQuery: $searchQuery, categoryId: $categoryId, stage: $stage, activeFilters: $activeFiltersCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProjectFilters &&
        other.searchQuery == searchQuery &&
        other.categoryId == categoryId &&
        other.stage == stage &&
        other.locationCountry == locationCountry &&
        other.locationCity == locationCity &&
        other.fundingMin == fundingMin &&
        other.fundingMax == fundingMax &&
        other.sortBy == sortBy &&
        other.isFeatured == isFeatured &&
        other.isPremium == isPremium &&
        _listsEqual(other.tagIds, tagIds);
  }

  @override
  int get hashCode {
    return searchQuery.hashCode ^
        categoryId.hashCode ^
        stage.hashCode ^
        locationCountry.hashCode ^
        locationCity.hashCode ^
        fundingMin.hashCode ^
        fundingMax.hashCode ^
        sortBy.hashCode ^
        isFeatured.hashCode ^
        isPremium.hashCode ^
        _listHashCode(tagIds);
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _listHashCode(List<String> list) {
    int hash = 0;
    for (final item in list) {
      hash = hash ^ item.hashCode;
    }
    return hash;
  }
}
