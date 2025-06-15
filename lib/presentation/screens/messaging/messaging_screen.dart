import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/messaging_provider.dart';
import 'package:venturelink/data/models/conversation_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../common_widgets/vl_app_bar.dart';
import '../../common_widgets/vl_loading_indicator.dart';
import 'conversation_screen.dart';
import 'new_conversation_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  bool _isProcessing = false;
  Timer? _searchDebounce;

  // Cache pour les statistiques
  _ConversationStats? _cachedStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConversations();

    // Écouter les changements de recherche avec debounce
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        _loadConversations();
      }
    });
  }

  void _performSearch(String query) {
    Provider.of<MessagingProvider>(context, listen: false)
        .searchConversations(query);
  }

  void _loadConversations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessagingProvider>(context, listen: false)
          .loadConversations();
    });
  }

  void _invalidateStatsCache() {
    _cachedStats = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      appBar: VLAppBar(
        title: _isSearching ? null : l10n.messages,
        // titleWidget: _isSearching ? _buildSearchField() : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Fermer' : 'Rechercher',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _loadConversations();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment),
            tooltip: 'Nouvelle conversation',
            onPressed: () => _showNewConversationDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques rapides
          _buildQuickStats(),

          // Onglets
          _buildTabBar(),

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
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Rechercher dans les conversations...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: context.appTheme.textSecondaryColor,
        ),
      ),
      style: TextStyle(
        color: context.appTheme.textPrimaryColor,
      ),
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;

        return Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: isCompact,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: context.appTheme.textSecondaryColor,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: isCompact ? l10n.all : 'Toutes les conversations'),
              Tab(text: 'Non lues'),
              Tab(text: 'Archivées'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<MessagingProvider>(
      builder: (context, provider, child) {
        // Utiliser le cache pour éviter les recalculs
        if (_cachedStats == null) {
          final unreadCount =
              provider.conversations.where((c) => c.unreadCount > 0).length;
          final totalMessages = provider.conversations
              .fold<int>(0, (sum, c) => sum + c.messageCount);

          _cachedStats = _ConversationStats(
            unreadCount: unreadCount,
            totalConversations: provider.conversations.length,
            totalMessages: totalMessages,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 400) {
              return _buildCompactStats(_cachedStats!);
            } else {
              return _buildFullStats(_cachedStats!);
            }
          },
        );
      },
    );
  }

  Widget _buildCompactStats(_ConversationStats stats) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.mark_email_unread,
                  '${stats.unreadCount}',
                  'Non lues',
                  AppTheme.primaryColor,
                  semanticsLabel: '${stats.unreadCount} conversations non lues',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  Icons.message,
                  '${stats.totalConversations}',
                  'Total',
                  Colors.blue,
                  semanticsLabel:
                      '${stats.totalConversations} conversations au total',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullStats(_ConversationStats stats) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.mark_email_unread,
              '${stats.unreadCount}',
              'Non lues',
              AppTheme.primaryColor,
              semanticsLabel: '${stats.unreadCount} conversations non lues',
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildStatItem(
              Icons.message,
              '${stats.totalConversations}',
              'Conversations',
              Colors.blue,
              semanticsLabel:
                  '${stats.totalConversations} conversations au total',
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildStatItem(
              Icons.chat_bubble_outline,
              '${stats.totalMessages}',
              'Messages',
              Colors.green,
              semanticsLabel: '${stats.totalMessages} messages au total',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color, {
    String? semanticsLabel,
  }) {
    return Semantics(
      label: semanticsLabel ?? '$value $label',
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

        if (provider.error != null) {
          return _buildErrorState(provider.error!, () => _loadConversations());
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
            _invalidateStatsCache();
            await provider.loadConversations();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.conversations.length,
            itemExtent: 80.0, // Hauteur fixe pour optimisation
            cacheExtent: 1000,
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

        if (provider.error != null) {
          return _buildErrorState(provider.error!, () => _loadConversations());
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
          itemExtent: 80.0,
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

        if (provider.error != null) {
          return _buildErrorState(provider.error!, () => _loadConversations());
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
            _invalidateStatsCache();
            await provider.loadConversations();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: archivedConversations.length,
            itemExtent: 80.0,
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
    final isMuted = conversation.muted;
    final isUnread = conversation.unreadCount > 0;

    Widget avatarWidget = _buildAvatar(otherParticipant);

    return Semantics(
      label:
          'Conversation avec ${otherParticipant?.fullName ?? conversation.title}. ${isUnread ? '${conversation.unreadCount} messages non lus' : 'Aucun message non lu'}. ${isMuted ? 'Conversation en sourdine' : ''}',
      button: true,
      child: InkWell(
        onTap: () => _navigateToConversation(conversation),
        onLongPress: () => _showConversationOptions(conversation),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding:
              EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 16 : 12),
          decoration: BoxDecoration(
            color: isUnread
                ? AppTheme.primaryColor.withOpacity(0.05)
                : Colors.white,
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
                          _buildDateText(conversation.lastMessageAt!),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Message et badges
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getLastMessagePreview(lastMessage),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              color: context.appTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isMuted)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.volume_off,
                              size: 16,
                              color: context.appTheme.textSecondaryColor,
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
      ),
    );
  }

  Widget _buildAvatar(dynamic otherParticipant) {
    if (otherParticipant != null) {
      if (otherParticipant.profile?.profilePicture != null) {
        return CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            otherParticipant.profile!.profilePicture!,
          ),
          radius: 28,
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback en cas d'erreur de chargement
          },
        );
      } else {
        return CircleAvatar(
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
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 28,
        child: Icon(
          Icons.group,
          color: Colors.white,
          size: 28,
        ),
      );
    }
  }

  String _getLastMessagePreview(dynamic lastMessage) {
    if (lastMessage == null) return 'Pas de message';

    // Prévisualisation enrichie selon le type de message
    if (lastMessage.attachments != null && lastMessage.attachments.isNotEmpty) {
      final attachment = lastMessage.attachments.first;
      if (attachment.isImage) return '📷 Image';
      if (attachment.isVideo) return '🎥 Vidéo';
      if (attachment.isAudio) return '🎵 Audio';
      if (attachment.isPdf) return '📄 Document PDF';
      return '📎 Fichier joint';
    }

    return lastMessage.content ?? 'Message';
  }

  Widget _buildDateText(DateTime dateTime) {
    return Tooltip(
      message: DateFormat('dd/MM/yyyy à HH:mm').format(dateTime),
      child: Text(
        _formatDate(dateTime),
        style: TextStyle(
          fontSize: 12,
          color: context.appTheme.textSecondaryColor,
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
        return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
      } else {
        return DateFormat('dd/MM').format(dateTime);
      }
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToConversation(ConversationModel conversation) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(conversation: conversation),
      ),
    );
  }

  void _showConversationOptions(ConversationModel conversation) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildConversationOptionsSheet(conversation),
    );
  }

  Widget _buildConversationOptionsSheet(ConversationModel conversation) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Titre
          Text(
            conversation.otherParticipant?.fullName ?? conversation.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Options
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
              _showDeleteConfirmation(conversation);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showNewConversationDialog() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewConversationScreen(),
      ),
    ).then((result) {
      if (result == true) {
        // Rafraîchir la liste si une nouvelle conversation a été créée
        _invalidateStatsCache();
        _loadConversations();
      }
    });
  }

  void _showDeleteConfirmation(ConversationModel conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement cette conversation ? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteConversation(conversation);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMuteConversation(ConversationModel conversation) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final provider = Provider.of<MessagingProvider>(context, listen: false);
      final success = conversation.muted
          ? await provider.unmuteConversation(conversation.id)
          : await provider.muteConversation(conversation.id);

      if (success && mounted) {
        _invalidateStatsCache();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conversation.muted
                ? 'Conversation réactivée'
                : 'Conversation mise en sourdine'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _toggleArchiveConversation(
      ConversationModel conversation) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final provider = Provider.of<MessagingProvider>(context, listen: false);
      final success = await provider.archiveConversation(conversation.id);

      if (success && mounted) {
        _invalidateStatsCache();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conversation.archived
                ? 'Conversation désarchivée'
                : 'Conversation archivée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _markAsRead(ConversationModel conversation) async {
    try {
      final provider = Provider.of<MessagingProvider>(context, listen: false);
      await provider.markConversationAsRead(conversation.id);
      _invalidateStatsCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversation marquée comme lue'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteConversation(ConversationModel conversation) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final provider = Provider.of<MessagingProvider>(context, listen: false);
      final success = await provider.deleteConversation(conversation.id);

      if (success && mounted) {
        _invalidateStatsCache();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversation supprimée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

// Classe pour le cache des statistiques
class _ConversationStats {
  final int unreadCount;
  final int totalConversations;
  final int totalMessages;

  _ConversationStats({
    required this.unreadCount,
    required this.totalConversations,
    required this.totalMessages,
  });
}
