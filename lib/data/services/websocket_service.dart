import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/message_model.dart';
import '../../core/config/app_config.dart';
import 'auth_service.dart';

class WebSocketException implements Exception {
  final String message;
  WebSocketException(this.message);

  @override
  String toString() => 'WebSocketException: $message';
}

class WebSocketService {
  WebSocketChannel? _channel;
  final AuthService _authService;
  bool _isConnected = false;

  WebSocketService(this._authService);

  bool get isConnected => _isConnected;

  Future<void> connect(String conversationId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw WebSocketException(
            'Token non disponible. Veuillez vous reconnecter.');
      }

      final uri =
          Uri.parse('${AppConfig.websocketBaseUrl}/ws/chat/$conversationId/');

      _channel = WebSocketChannel.connect(
        uri,
        protocols: ['Bearer', token],
      );

      _isConnected = true;
      debugPrint('✅ WebSocket connecté pour conversation: $conversationId');
    } catch (e) {
      _isConnected = false;
      debugPrint('❌ Erreur connexion WebSocket: $e');
      throw WebSocketException('Erreur de connexion: $e');
    }
  }

  void sendMessage({
    required String content,
    required String recipientId,
    String type = 'chat_message',
  }) {
    if (_channel == null) {
      throw WebSocketException('WebSocket non connecté');
    }

    final message = {
      'type': type,
      'content': content,
      'recipient_id': recipientId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _channel!.sink.add(jsonEncode(message));
  }

  Stream<MessageModel>? getMessageStream() {
    if (_channel == null) return null;

    return _channel!.stream
        .map((data) => jsonDecode(data) as Map<String, dynamic>)
        .where((data) => data['type'] == 'chat_message')
        .map((data) => MessageModel.fromJson(data));
  }

  Stream<Map<String, dynamic>>? get rawStream {
    if (_channel == null) return null;

    return _channel!.stream.map((data) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('❌ Erreur décodage message WebSocket: $e');
        return {'type': 'error', 'error': e.toString(), 'raw_data': data};
      }
    });
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
      _isConnected = false;
      debugPrint('🔌 WebSocket déconnecté');
    }
  }
}
