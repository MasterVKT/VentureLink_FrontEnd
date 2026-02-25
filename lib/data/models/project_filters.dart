
class ProjectFilters {
  String? category;       // Catégorie sélectionnée (ex: "Tech", "Agriculture")
  String? location;       // Localisation (ex: "Cameroun", "Sénégal")
  double? minBudget;      // Budget minimum
  double? maxBudget;      // Budget maximum
  String? status;         // Statut du projet (ex: "ACTIVE", "FUNDED")

  ProjectFilters({
    this.category,
    this.location,
    this.minBudget,
    this.maxBudget,
    this.status,
  });

  // Créer une copie avec des modifications
  ProjectFilters copyWith({
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
    String? status,
  }) {
    return ProjectFilters(
      category: category ?? this.category,
      location: location ?? this.location,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      status: status ?? this.status,
    );
  }

  // Est-ce qu'il y a des filtres actifs ?
  bool get hasActiveFilters {
    return category != null ||
        location != null ||
        (minBudget != null && minBudget! > 0) ||
        (maxBudget != null && maxBudget! < 1000000) ||
        status != null;
  }

  // Compter le nombre de filtres actifs
  int get activeFilterCount {
    int count = 0;
    if (category != null) count++;
    if (location != null) count++;
    if (minBudget != null && minBudget! > 0) count++;
    if (maxBudget != null && maxBudget! < 1000000) count++;
    if (status != null) count++;
    return count;
  }

  // Convertir en paramètres pour l'API
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (location != null) params['location'] = location;
    if (minBudget != null) params['min_budget'] = minBudget;
    if (maxBudget != null) params['max_budget'] = maxBudget;
    if (status != null) params['status'] = status;
    return params;
  }

  // Réinitialiser tous les filtres
  void clear() {
    category = null;
    location = null;
    minBudget = null;
    maxBudget = null;
    status = null;
  }

  @override
  String toString() {
    return 'ProjectFilters(category: $category, location: $location, '
        'minBudget: $minBudget, maxBudget: $maxBudget, status: $status)';
  }
}