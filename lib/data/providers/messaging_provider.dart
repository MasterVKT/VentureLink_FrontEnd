import 'dart:async';
import 'package:flutter/material.dart';
import 'package:venturelink/data/models/message_model.dart';
import 'package:venturelink/data/models/conversation_model.dart';
import 'package:venturelink/data/services/messaging_api_service.dart';
import 'package:venturelink/data/services/websocket_service.dart';

class MessagingProvider extends ChangeNotifier {
  final MessagingApiService _messagingService;
  final WebSocketService _webSocketService;

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  ConversationModel? _currentConversation;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  int _unreadCount = 0;
  bool _hasMoreMessages = true;
  int _currentMessagePage = 1;
  String? _currentUserId;
  StreamSubscription? _messageSubscription;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  ConversationModel? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasMoreMessages => _hasMoreMessages;
  String get currentUserId => _currentUserId ?? "current_user";
  bool get isWebSocketConnected => _webSocketService.isConnected;

  // Getters pour filtrer les conversations
  List<ConversationModel> get unreadConversations =>
      _conversations.where((c) => c.unreadCount > 0).toList();

  List<ConversationModel> get archivedConversations =>
      _conversations.where((c) => c.archived).toList();

  MessagingProvider(this._messagingService, this._webSocketService) {
    _init();
  }

  Future<void> _init() async {
    await loadConversations();
    await loadUnreadCount();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Charger les conversations
  Future<void> loadConversations({bool refresh = false}) async {
    if (refresh) {
      _conversations.clear();
    }

    _setLoading(true);
    _setError(null);

    try {
      final response = await _messagingService.getConversations();
      _conversations = response.conversations;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Charger une conversation spécifique
  Future<void> loadConversation(String conversationId) async {
    _setLoading(true);
    _setError(null);

    try {
      final conversation =
          await _messagingService.getConversationById(conversationId);
      _currentConversation = conversation;
      await loadMessages(conversationId, refresh: true);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les messages d'une conversation
  Future<void> loadMessages(String conversationId,
      {bool refresh = false}) async {
    if (refresh) {
      _messages.clear();
      _currentMessagePage = 1;
      _hasMoreMessages = true;
    }

    if (!_hasMoreMessages && !refresh) return;

    _setLoading(true);
    _setError(null);

    try {
      final response = await _messagingService.getMessages(
        conversationId,
        page: _currentMessagePage,
      );

      if (refresh) {
        _messages = response.messages;
      } else {
        _messages.addAll(response.messages);
      }

      _hasMoreMessages = response.hasMoreMessages;
      _currentMessagePage++;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Créer une nouvelle conversation
  Future<ConversationModel?> createConversation(
      String recipientId, String initialMessage) async {
    _setLoading(true);
    _setError(null);

    try {
      final conversation = await _messagingService.createConversation(
        recipientId,
        initialMessage,
      );

      // Ajouter à la liste locale
      _conversations.add(conversation);
      notifyListeners();

      return conversation;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Envoyer un message
  Future<MessageModel?> sendMessage(
      String conversationId, String content) async {
    _isSending = true;
    notifyListeners();

    try {
      final message = await _messagingService.sendMessage(
        conversationId,
        content.trim(),
      );

      // Ajouter à la liste locale
      _messages.add(message);
      notifyListeners();

      return message;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Envoyer un fichier
  Future<bool> sendFileMessage(String conversationId, String filePath,
      {String? content}) async {
    try {
      // TODO: Implémenter l'upload de fichier avec FormData
      // final formData = FormData.fromMap({
      //   'file': await MultipartFile.fromFile(filePath),
      //   'content': content ?? '',
      //   'message_type': 'FILE',
      // });

      // final message = await _messagingService.sendFileMessage(
      //   conversationId: conversationId,
      //   formData: formData,
      //   content: content,
      // );

      // if (message != null) {
      //   _messages.add(message);
      //   notifyListeners();
      //   return true;
      // }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Marquer une conversation comme lue
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _messagingService.markAsRead(conversationId);

      // Mettre à jour localement
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        final oldUnreadCount = _conversations[index].unreadCount;
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
        _unreadCount =
            (_unreadCount - oldUnreadCount).clamp(0, double.infinity).toInt();

        if (_currentConversation?.id == conversationId) {
          _currentConversation = _currentConversation!.copyWith(unreadCount: 0);
        }

        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Marquer un message comme lu
  Future<void> markMessageAsRead(
      String conversationId, String messageId) async {
    try {
      await _messagingService.markMessageAsRead(conversationId, messageId);

      // Mettre à jour localement
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final updatedMessage = _messages[index].copyWith(
          read: true,
          readAt: DateTime.now(),
        );
        _messages[index] = updatedMessage;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Supprimer un message
  Future<bool> deleteMessage(String conversationId, String messageId) async {
    try {
      final success =
          await _messagingService.deleteMessage(conversationId, messageId);

      if (success) {
        _messages.removeWhere((m) => m.id == messageId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Archiver une conversation
  Future<bool> archiveConversation(String conversationId) async {
    try {
      await _messagingService.updateConversation(
        conversationId,
        isArchived: true,
      );

      // Mettre à jour localement
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(archived: true);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Mettre en sourdine une conversation
  Future<bool> muteConversation(String conversationId) async {
    try {
      await _messagingService.updateConversation(
        conversationId,
        isMuted: true,
      );

      // Mettre à jour localement
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(muted: true);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Retirer la sourdine d'une conversation
  Future<bool> unmuteConversation(String conversationId) async {
    try {
      await _messagingService.updateConversation(
        conversationId,
        isMuted: false,
      );

      // Mettre à jour localement
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(muted: false);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Rechercher dans les conversations
  Future<void> searchConversations(String query) async {
    if (query.trim().isEmpty) {
      await loadConversations(refresh: true);
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final conversations =
          await _messagingService.searchConversations(query.trim());
      _conversations = conversations;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Charger le nombre de messages non lus
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _messagingService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs pour le compteur
    }
  }

  /// Charger plus de messages (pagination)
  Future<void> loadMoreMessages() async {
    if (_currentConversation != null && !_isLoading && _hasMoreMessages) {
      await loadMessages(_currentConversation!.id);
    }
  }

  /// Marquer toutes les conversations comme lues
  Future<void> markAllAsRead() async {
    try {
      // TODO: Implémenter dans l'API service
      // final success = await _messagingService.markAllAsRead();
      const success = true; // Temporaire
      if (success) {
        for (int i = 0; i < _conversations.length; i++) {
          _conversations[i] = _conversations[i].copyWith(unreadCount: 0);
        }
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Archiver toutes les conversations
  Future<void> archiveAllConversations() async {
    try {
      // TODO: Implémenter dans l'API service
      // final success = await _messagingService.archiveAllConversations();
      const success = true; // Temporaire
      if (success) {
        _conversations.clear();
        _currentConversation = null;
        _messages.clear();
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearCurrentConversation() {
    _currentConversation = null;
    _messages.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Ouvrir une conversation et se connecter au WebSocket
  Future<void> openConversation(String conversationId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Fermer la connexion WebSocket existante
      _closeWebSocketConnection();

      // Charger les détails de la conversation
      final conversation =
          await _messagingService.getConversationById(conversationId);
      _currentConversation = conversation;

      // Charger les messages de la conversation
      await loadMessages(conversationId, refresh: true);

      // Ouvrir une connexion WebSocket pour cette conversation
      await _webSocketService.connect(conversationId);

      // Écouter les nouveaux messages
      _listenForMessages();

      // Marquer la conversation comme lue
      if (conversation.unreadCount > 0) {
        await markConversationAsRead(conversationId);
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Écouter les messages WebSocket
  void _listenForMessages() {
    _messageSubscription?.cancel();

    final stream = _webSocketService.getMessageStream();
    if (stream == null) return;

    _messageSubscription = stream.listen((message) {
      // Ajouter le message à la liste locale
      _messages.add(message);
      notifyListeners();
    });
  }

  // Fermer la connexion WebSocket
  void _closeWebSocketConnection() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _webSocketService.disconnect();
  }

  @override
  void dispose() {
    _closeWebSocketConnection();
    super.dispose();
  }

  /// Supprimer une conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      // Appeler l'API pour supprimer la conversation
      // Note: Cette méthode n'existe pas encore dans l'API service
      // Pour l'instant, on simule la suppression locale

      // Supprimer localement
      _conversations.removeWhere((c) => c.id == conversationId);

      // Si c'est la conversation courante, la vider
      if (_currentConversation?.id == conversationId) {
        _currentConversation = null;
        _messages.clear();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
}

// Note: Les extensions ont été supprimées car elles ne sont plus nécessaires.
// Les classes ConversationModel et MessageModel ont déjà leurs méthodes copyWith intégrées.
