import 'package:dio/dio.dart';
import 'package:venturelink/data/models/message_model.dart';
import 'package:venturelink/data/models/conversation_model.dart';
import 'package:venturelink/domain/services/i_api_service.dart';

class ConversationsResponse {
  final List<ConversationModel> conversations;
  final int totalCount;
  final String? nextUrl;
  final String? previousUrl;

  ConversationsResponse({
    required this.conversations,
    required this.totalCount,
    this.nextUrl,
    this.previousUrl,
  });

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) {
    return ConversationsResponse(
      conversations: (json['results'] as List)
          .map((item) => ConversationModel.fromJson(item))
          .toList(),
      totalCount: json['count'] ?? 0,
      nextUrl: json['next'],
      previousUrl: json['previous'],
    );
  }
}

class MessagesResponse {
  final List<MessageModel> messages;
  final int totalCount;
  final String? nextUrl;
  final String? previousUrl;
  final bool hasMoreMessages;

  MessagesResponse({
    required this.messages,
    required this.totalCount,
    this.nextUrl,
    this.previousUrl,
    this.hasMoreMessages = false,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['results'] as List)
          .map((item) => MessageModel.fromJson(item))
          .toList(),
      totalCount: json['count'] ?? 0,
      nextUrl: json['next'],
      previousUrl: json['previous'],
      hasMoreMessages: json['next'] != null,
    );
  }
}

class MessagingApiService {
  final IApiService _apiService;

  MessagingApiService(this._apiService);

  /// Récupérer la liste des conversations
  Future<ConversationsResponse> getConversations({
    int page = 1,
    int pageSize = 20,
    bool? isArchived,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (isArchived != null) queryParams['is_archived'] = isArchived;

      final response = await _apiService.get('/conversations/',
          queryParameters: queryParams);

      return ConversationsResponse.fromJson(response.data);
    } catch (e) {
      return ConversationsResponse(conversations: [], totalCount: 0);
    }
  }

  /// Récupérer une conversation par son ID
  Future<ConversationModel> getConversationById(String conversationId) async {
    try {
      final response = await _apiService.get('/conversations/$conversationId/');
      return ConversationModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la conversation: $e');
    }
  }

  /// Créer une nouvelle conversation
  Future<ConversationModel> createConversation(
    String recipientId,
    String initialMessage,
  ) async {
    try {
      final response = await _apiService.post('/conversations/', data: {
        'recipient_id': recipientId,
        'initial_message': initialMessage,
      });
      return ConversationModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la création de la conversation: $e');
    }
  }

  /// Mettre à jour une conversation (archive, sourdine)
  Future<ConversationModel> updateConversation(
    String conversationId, {
    bool? isArchived,
    bool? isMuted,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (isArchived != null) data['is_archived'] = isArchived;
      if (isMuted != null) data['is_muted'] = isMuted;

      final response = await _apiService.patch(
        '/conversations/$conversationId/',
        data: data,
      );
      return ConversationModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la conversation: $e');
    }
  }

  /// Marquer une conversation comme lue
  Future<void> markAsRead(String conversationId) async {
    try {
      await _apiService.post('/conversations/$conversationId/mark_read/');
    } catch (e) {
      throw Exception('Erreur lors du marquage comme lu: $e');
    }
  }

  /// Récupérer les messages d'une conversation
  Future<MessagesResponse> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      final response = await _apiService.get(
        '/conversations/$conversationId/messages/',
        queryParameters: queryParams,
      );

      return MessagesResponse.fromJson(response.data);
    } catch (e) {
      return MessagesResponse(messages: [], totalCount: 0);
    }
  }

  /// Envoyer un message
  Future<MessageModel> sendMessage(
    String conversationId,
    String content, {
    String? attachmentUrl,
    String? attachmentType,
    String? attachmentName,
  }) async {
    try {
      final data = {
        'content': content,
        'message_type': attachmentUrl != null ? 'FILE' : 'TEXT',
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
        if (attachmentType != null) 'attachment_type': attachmentType,
        if (attachmentName != null) 'attachment_name': attachmentName,
      };

      final response = await _apiService
          .post('/conversations/$conversationId/messages/', data: data);
      return MessageModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  /// Envoyer un fichier
  Future<MessageModel> sendFileMessage(
    String conversationId,
    FormData formData, {
    String? content,
  }) async {
    try {
      final response = await _apiService.upload(
          '/conversations/$conversationId/messages/', formData);
      return MessageModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du fichier: $e');
    }
  }

  /// Marquer un message comme lu
  Future<void> markMessageAsRead(
      String conversationId, String messageId) async {
    try {
      await _apiService.post(
          '/conversations/$conversationId/messages/$messageId/mark_read/');
    } catch (e) {
      throw Exception('Erreur lors du marquage du message comme lu: $e');
    }
  }

  /// Supprimer un message
  Future<bool> deleteMessage(String conversationId, String messageId) async {
    try {
      await _apiService
          .delete('/conversations/$conversationId/messages/$messageId/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Modifier un message
  Future<MessageModel> updateMessage(
    String conversationId,
    String messageId,
    String content,
  ) async {
    try {
      final response = await _apiService.patch(
        '/conversations/$conversationId/messages/$messageId/',
        data: {'content': content},
      );
      return MessageModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du message: $e');
    }
  }

  /// Rechercher dans les conversations
  Future<List<ConversationModel>> searchConversations(String query) async {
    try {
      final response =
          await _apiService.get('/conversations/search/', queryParameters: {
        'q': query,
      });

      return (response.data['results'] as List)
          .map((json) => ConversationModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Rechercher dans les messages
  Future<List<MessageModel>> searchMessages(
    String conversationId,
    String query,
  ) async {
    try {
      final response = await _apiService.get(
        '/conversations/$conversationId/messages/search/',
        queryParameters: {'q': query},
      );

      return (response.data['results'] as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtenir le nombre de messages non lus
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/conversations/unread_count/');
      return response.data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
