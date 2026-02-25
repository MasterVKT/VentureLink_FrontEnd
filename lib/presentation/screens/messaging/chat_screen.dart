import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/messaging_provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/models/message_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversation(widget.conversationId);
      context
          .read<MessagingProvider>()
          .markConversationAsRead(widget.conversationId);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Charger plus de messages quand on approche du haut
      context.read<MessagingProvider>().loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.otherUserName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    'En ligne',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: _startVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: _startVoiceCall,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'view_profile':
                  _viewProfile();
                  break;
                case 'mute':
                  _muteConversation();
                  break;
                case 'block':
                  _blockUser();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Voir le profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.volume_off_outlined),
                    SizedBox(width: 8),
                    Text('Mettre en sourdine'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_outlined, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Bloquer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, messagingProvider, child) {
          if (messagingProvider.isLoading &&
              messagingProvider.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messagingProvider.error != null &&
              messagingProvider.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    messagingProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      messagingProvider.loadConversation(widget.conversationId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: _buildMessagesList(messagingProvider.messages),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages) {
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commencez la conversation !',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isMyMessage =
            message.senderId == context.read<AuthProvider>().currentUser?.id;
        final showAvatar = index == 0 ||
            messages[messages.length - index].senderId != message.senderId;

        return _buildMessageBubble(message, isMyMessage, showAvatar);
      },
    );
  }

  Widget _buildMessageBubble(
      MessageModel message, bool isMyMessage, bool showAvatar) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final otherUserInitial = widget.otherUserName.isNotEmpty
        ? widget.otherUserName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  otherUserInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMyMessage
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMyMessage ? 16 : 4),
                  bottomRight: Radius.circular(isMyMessage ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.hasAttachment) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16,
                          color: isMyMessage
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            message.attachmentName ?? 'Fichier',
                            style: TextStyle(
                              color: isMyMessage
                                  ? Colors.white
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (message.content.isNotEmpty) const SizedBox(height: 4),
                  ],
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMyMessage
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatMessageTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMyMessage
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.grey[600],
                        ),
                      ),
                      if (isMyMessage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.read ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.read
                              ? Colors.blue[300]
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  currentUser != null && currentUser.firstName.isNotEmpty
                      ? currentUser.firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _showAttachmentOptions,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Tapez votre message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.trim().isNotEmpty;
                  });
                },
                onSubmitted: _isComposing ? (_) => _sendMessage() : null,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: Icon(
                  _isComposing ? Icons.send : Icons.mic,
                  color: _isComposing
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: _isComposing ? _sendMessage : _startVoiceRecording,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Maintenant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('dd/MM HH:mm').format(dateTime);
    }
  }

  void _sendMessage() async {
    if (!_isComposing) return;

    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    final message = await context
        .read<MessagingProvider>()
        .sendMessage(widget.conversationId, content);

    if (message == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi du message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Prendre une photo'),
            onTap: () {
              Navigator.pop(context);
              _takePicture();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choisir une image'),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('Joindre un fichier'),
            onTap: () {
              Navigator.pop(context);
              _pickFile();
            },
          ),
        ],
      ),
    );
  }

  void _takePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité photo à venir')),
    );
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité image à venir')),
    );
  }

  void _pickFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité fichier à venir')),
    );
  }

  void _startVoiceRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité vocal à venir')),
    );
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité vidéo à venir')),
    );
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité appel à venir')),
    );
  }

  void _viewProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voir profil à venir')),
    );
  }

  void _muteConversation() {
    context.read<MessagingProvider>().muteConversation(widget.conversationId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conversation mise en sourdine')),
    );
  }

  void _blockUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquer l\'utilisateur'),
        content: Text(
          'Êtes-vous sûr de vouloir bloquer ${widget.otherUserName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.otherUserName} a été bloqué')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Bloquer'),
          ),
        ],
      ),
    );
  }
}
