import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/messaging_provider.dart';
import 'package:venturelink/data/models/conversation_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../common_widgets/vl_app_bar.dart';
import '../../common_widgets/vl_loading_indicator.dart';
import 'conversation_screen.dart';

@RoutePage()
class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConversations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessagingProvider>(context, listen: false)
          .loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      appBar: VLAppBar(
        title: _isSearching ? null : 'Messages',
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () => _showNewConversationDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques rapides
          _buildQuickStats(),

          // Onglets
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: context.appTheme.textSecondaryColor,
              indicatorColor: AppTheme.primaryColor,
              tabs: const [
                Tab(text: 'Toutes'),
                Tab(text: 'Non lues'),
                Tab(text: 'Archivées'),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllConversationsTab(),
                _buildUnreadConversationsTab(),
                _buildArchivedConversationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Rechercher des conversations...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        // TODO: Implémenter la recherche
        Provider.of<MessagingProvider>(context, listen: false)
            .searchConversations(value);
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<MessagingProvider>(
      builder: (context, provider, child) {
        final unreadCount =
            provider.conversations.where((c) => c.unreadCount > 0).length;

        final totalMessages = provider.conversations
            .fold<int>(0, (sum, c) => sum + c.messageCount);

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatItem(
                Icons.mark_email_unread,
                '$unreadCount',
                'Non lues',
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                Icons.message,
                '${provider.conversations.length}',
                'Conversations',
                Colors.blue,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                Icons.chat_bubble_outline,
                '$totalMessages',
                'Messages',
                Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.appTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllConversationsTab() {
    return Consumer<MessagingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: VLLoadingIndicator());
        }

        if (provider.conversations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Aucune conversation',
            subtitle: 'Commencez une nouvelle conversation',
            action: () => _showNewConversationDialog(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadConversations();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.conversations.length,
            itemBuilder: (context, index) {
              final conversation = provider.conversations[index];
              return _buildConversationCard(conversation);
            },
          ),
        );
      },
    );
  }

  Widget _buildUnreadConversationsTab() {
    return Consumer<MessagingProvider>(
      builder: (context, provider, child) {
        final unreadConversations =
            provider.conversations.where((c) => c.unreadCount > 0).toList();

        if (provider.isLoading) {
          return const Center(child: VLLoadingIndicator());
        }

        if (unreadConversations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.mark_email_read,
            title: 'Tout est lu !',
            subtitle: 'Aucun message non lu',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: unreadConversations.length,
          itemBuilder: (context, index) {
            final conversation = unreadConversations[index];
            return _buildConversationCard(conversation);
          },
        );
      },
    );
  }

  Widget _buildArchivedConversationsTab() {
    return Consumer<MessagingProvider>(
      builder: (context, provider, child) {
        final archivedConversations =
            provider.conversations.where((c) => c.archived).toList();

        if (provider.isLoading) {
          return const Center(child: VLLoadingIndicator());
        }

        if (archivedConversations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.archive,
            title: 'Aucune conversation archivée',
            subtitle: 'Les conversations archivées apparaîtront ici',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadConversations();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: archivedConversations.length,
            itemBuilder: (context, index) {
              final conversation = archivedConversations[index];
              return _buildConversationCard(conversation);
            },
          ),
        );
      },
    );
  }

  Widget _buildConversationCard(ConversationModel conversation) {
    final otherParticipant = conversation.otherParticipant;
    final lastMessage = conversation.lastMessage;

    Widget avatarWidget;
    if (otherParticipant != null) {
      if (otherParticipant.profile?.profilePicture != null) {
        avatarWidget = CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            otherParticipant.profile!.profilePicture!,
          ),
          radius: 28,
        );
      } else {
        avatarWidget = CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          radius: 28,
          child: Text(
            otherParticipant.firstName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    } else {
      avatarWidget = const CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 28,
        child: Icon(
          Icons.group,
          color: Colors.white,
          size: 28,
        ),
      );
    }

    final isMuted = conversation.muted;
    final isUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: () => _navigateToConversation(conversation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isUnread ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            avatarWidget,
            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et heure
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherParticipant?.fullName ?? conversation.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.w500,
                            color: context.appTheme.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatDate(conversation.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Message
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage?.content ?? 'Pas de message',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.appTheme.textSecondaryColor,
                            fontWeight:
                                isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isMuted)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 16,
                            color: Colors.grey,
                          ),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.appTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.appTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.appTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: action,
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle conversation'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}j';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }

  void _navigateToConversation(ConversationModel conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(conversation: conversation),
      ),
    );
  }

  void _showConversationOptions(ConversationModel conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildConversationOptionsSheet(conversation),
    );
  }

  Widget _buildConversationOptionsSheet(ConversationModel conversation) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            conversation.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(
              conversation.muted ? Icons.volume_up : Icons.volume_off,
              color: AppTheme.primaryColor,
            ),
            title: Text(
              conversation.muted ? 'Réactiver' : 'Mettre en sourdine',
            ),
            onTap: () {
              Navigator.pop(context);
              _toggleMuteConversation(conversation);
            },
          ),
          ListTile(
            leading: Icon(
              conversation.archived ? Icons.unarchive : Icons.archive,
              color: AppTheme.primaryColor,
            ),
            title: Text(
              conversation.archived ? 'Désarchiver' : 'Archiver',
            ),
            onTap: () {
              Navigator.pop(context);
              _toggleArchiveConversation(conversation);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.mark_email_read,
              color: Colors.blue,
            ),
            title: const Text('Marquer comme lu'),
            onTap: () {
              Navigator.pop(context);
              _markAsRead(conversation);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Supprimer'),
            onTap: () {
              Navigator.pop(context);
              _deleteConversation(conversation);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showNewConversationDialog() {
    // TODO: Implémenter la création de nouvelle conversation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nouvelle conversation en cours de développement'),
      ),
    );
  }

  void _toggleMuteConversation(ConversationModel conversation) {
    final provider = Provider.of<MessagingProvider>(context, listen: false);
    if (conversation.muted) {
      provider.unmuteConversation(conversation.id);
    } else {
      provider.muteConversation(conversation.id);
    }
  }

  void _toggleArchiveConversation(ConversationModel conversation) {
    Provider.of<MessagingProvider>(context, listen: false)
        .archiveConversation(conversation.id);
  }

  void _markAsRead(ConversationModel conversation) {
    Provider.of<MessagingProvider>(context, listen: false)
        .markConversationAsRead(conversation.id);
  }

  void _deleteConversation(ConversationModel conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette conversation ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<MessagingProvider>(context, listen: false)
                  .archiveConversation(conversation.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
