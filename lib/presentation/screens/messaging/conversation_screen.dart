import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/messaging_provider.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import '../../common_widgets/vl_loading_indicator.dart';

// Extensions pour adapter les modèles aux propriétés attendues
extension UserModelExtension on UserModel {
  String get displayName => fullName;
  String? get profilePictureUrl => profile?.profilePicture;
  bool get isOnline =>
      lastLogin != null &&
      DateTime.now().difference(lastLogin!).inMinutes <
          5; // Considéré en ligne si actif dans les 5 dernières minutes
}

class ConversationScreen extends StatefulWidget {
  final ConversationModel conversation;
  final String? initialMessage;

  const ConversationScreen({
    super.key,
    required this.conversation,
    this.initialMessage,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  late MessagingProvider _messagingProvider;

  @override
  void initState() {
    super.initState();
    _messagingProvider = Provider.of<MessagingProvider>(context, listen: false);

    // Charger les messages
    _loadMessages();

    // Initialiser avec un message si fourni
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _messageController.text = widget.initialMessage!;
      _isComposing = true;
    }

    // Marquer la conversation comme lue
    _messagingProvider.markConversationAsRead(widget.conversation.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    await _messagingProvider.loadMessages(widget.conversation.id);

    // Faire défiler automatiquement vers le bas après chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Effacer le champ de texte
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    // Envoyer le message
    await _messagingProvider.sendMessage(
      widget.conversation.id,
      text,
    );

    // Faire défiler automatiquement vers le bas
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        title: _buildAppBarTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showConversationInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    final otherParticipant = widget.conversation.otherParticipant;

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: otherParticipant?.profilePictureUrl != null
              ? CachedNetworkImageProvider(
                  otherParticipant!.profilePictureUrl!,
                )
              : null,
          child: otherParticipant?.profilePictureUrl == null
              ? Text(
                  otherParticipant?.displayName.substring(0, 1).toUpperCase() ??
                      '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                otherParticipant?.displayName ?? widget.conversation.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (otherParticipant?.isOnline == true)
                const Text(
                  'En ligne',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Consumer<MessagingProvider>(
      builder: (context, messagingProvider, child) {
        if (messagingProvider.isLoading) {
          return const Center(
            child: VLLoadingIndicator(),
          );
        }

        final messages = messagingProvider.messages;
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'Aucun message. Commencez la conversation !',
              style: TextStyle(
                color: Theme.of(context)
                    .extension<AppThemeExtension>()!
                    .textSecondaryColor,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final bool isMe =
                message.senderId == messagingProvider.currentUserId;

            // Afficher l'en-tête de date si nécessaire
            final showDateHeader = index == 0 ||
                !_isSameDay(
                  messages[index].createdAt,
                  messages[index - 1].createdAt,
                );

            return Column(
              children: [
                if (showDateHeader) _buildDateHeader(message.createdAt),
                _buildMessageItem(message, isMe),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            _formatHeaderDate(date),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .extension<AppThemeExtension>()!
                  .textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(MessageModel message, bool isMe) {
    final theme = Theme.of(context).extension<AppThemeExtension>()!;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 16.0 : 4.0),
            topRight: Radius.circular(isMe ? 4.0 : 16.0),
            bottomLeft: const Radius.circular(16.0),
            bottomRight: const Radius.circular(16.0),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : theme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.white.withOpacity(0.7)
                    : theme.textSecondaryColor,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color:
            Theme.of(context).extension<AppThemeExtension>()!.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                // TODO: Implémenter l'envoi de fichiers
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Écrivez un message...',
                  border: InputBorder.none,
                ),
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.trim().isNotEmpty;
                  });
                },
                onSubmitted: (_) => _isComposing ? _sendMessage() : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: _isComposing ? AppTheme.primaryBlue : Colors.grey,
              onPressed: _isComposing ? _sendMessage : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationInfo() {
    // TODO: Afficher les informations de la conversation
  }

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Aujourd'hui";
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Hier';
    } else {
      return DateFormat('d MMMM yyyy').format(date);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
