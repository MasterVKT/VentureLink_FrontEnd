import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:venturelink/data/models/user_model.dart';

part 'user_api_service.g.dart';

/// Service API pour les utilisateurs avec Retrofit
@RestApi(baseUrl: "http://localhost:8000/api/v1/")
abstract class UserApiService {
  factory UserApiService(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) = _UserApiService;

  /// Récupérer le profil de l'utilisateur connecté
  @GET('/users/me/')
  Future<UserModel> getCurrentUser();

  /// Mettre à jour les informations du profil
  @PATCH('/users/me/')
  Future<UserModel> updateUserProfile(@Body() Map<String, dynamic> data);

  /// Mettre à jour les informations du profil professionnel
  @PATCH('/profiles/me/')
  Future<UserModel> updateProfileDetails(@Body() Map<String, dynamic> data);

  /// Upload de la photo de profil
  @POST('/profiles/me/upload_profile_picture/')
  @MultiPart()
  Future<UserModel> uploadProfilePicture(
      @Part(name: 'profile_picture') File image);

  /// Upload de la photo de couverture
  @POST('/profiles/me/upload_cover_picture/')
  @MultiPart()
  Future<UserModel> uploadCoverPicture(@Part(name: 'cover_picture') File image);

  /// Supprimer la photo de profil
  @PATCH('/profiles/me/')
  Future<UserModel> removeProfilePicture(@Body() Map<String, dynamic> data);

  /// Supprimer la photo de couverture
  @PATCH('/profiles/me/')
  Future<UserModel> removeCoverPicture(@Body() Map<String, dynamic> data);

  /// Changer le mot de passe
  @POST('/users/me/change_password/')
  Future<void> changePassword(@Body() Map<String, dynamic> data);
}
