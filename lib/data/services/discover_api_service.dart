import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/domain/services/i_api_service.dart';

/// Service API pour l'écran de découverte (Discover)
/// Gère les appels vers l'endpoint /discover/
class DiscoverApiService {
  final IApiService _apiService;

  DiscoverApiService(this._apiService);

  /// Récupère toutes les sections de l'écran de découverte
  /// Retourne les projets recommandés, tendance, nouveaux et presque financés
  Future<DiscoverResponse> getDiscoverData() async {
    final response = await _apiService.get('/discover/');
    return DiscoverResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Modèle de réponse pour l'écran de découverte
class DiscoverResponse {
  final List<ProjectModel> recommended;
  final List<ProjectModel> trending;
  final List<ProjectModel> newProjects;
  final List<ProjectModel> almostFunded;

  DiscoverResponse({
    required this.recommended,
    required this.trending,
    required this.newProjects,
    required this.almostFunded,
  });

  factory DiscoverResponse.fromJson(Map<String, dynamic> json) {
    return DiscoverResponse(
      recommended: _parseProjectList(json['recommended']),
      trending: _parseProjectList(json['trending']),
      newProjects: _parseProjectList(json['new']),
      almostFunded: _parseProjectList(json['almost_funded']),
    );
  }

  static List<ProjectModel> _parseProjectList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((p) => ProjectModel.fromJson(p))
        .toList();
  }
}
