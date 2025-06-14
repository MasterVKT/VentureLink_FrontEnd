import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/notification_provider.dart';
import 'package:venturelink/data/models/notification_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

@RoutePage()
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filtres
  String _currentFilter = 'all';
  final List<String> _availableFilters = [
    'all',
    'unread',
    'message',
    'investment',
    'project',
    'system'
  ];

  // Tri
  String _currentSort = 'newest';
  final List<String> _availableSorts = ['newest', 'oldest', 'important'];

  // Recherche
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Charger les notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive ? _buildSearchBar() : Text(l10n.notifications),
        actions: [
          // Bouton recherche
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          // Bouton menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  context.read<NotificationProvider>().markAllAsRead();
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
                case 'settings':
                  _showSettingsDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_read),
                    const SizedBox(width: 8),
                    Text(l10n.markAllRead),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep),
                    const SizedBox(width: 8),
                    Text(l10n.clearAll),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings),
                    const SizedBox(width: 8),
                    Text(l10n.settings),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.all),
            Tab(text: l10n.unread),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!_isSearchActive) _buildFilterChips(),
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.errorLoadingNotifications,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.loadNotifications();
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrer les notifications selon l'onglet
                List<NotificationModel> tabNotifications =
                    _tabController.index == 0
                        ? provider.notifications
                        : provider.unreadNotifications;

                // Filtrer selon le filtre actif
                tabNotifications = _filterNotifications(tabNotifications);

                // Filtrer selon la recherche
                if (_searchQuery.isNotEmpty) {
                  tabNotifications = tabNotifications.where((n) {
                    return n.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        n.message
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                // Trier les notifications
                _sortNotifications(tabNotifications);

                if (tabNotifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: theme.colorScheme.secondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _tabController.index == 0
                              ? l10n.noNotifications
                              : l10n.noUnreadNotifications,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: tabNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(tabNotifications[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.searchNotifications,
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildFilterChips() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Map<String, String> filterLabels = {
      'all': l10n.all,
      'unread': l10n.unread,
      'message': l10n.messages,
      'investment': l10n.investments,
      'project': l10n.projects,
      'system': l10n.system,
    };

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _availableFilters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(filterLabels[filter]!),
                    selected: _currentFilter == filter,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _currentFilter = filter;
                        });
                      }
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primaryContainer,
                  ),
                );
              }).toList(),
            ),
          ),
          // Bouton de tri
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: l10n.sort,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConfig.defaultPadding,
        vertical: 4,
      ),
      child: ListTile(
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.notificationType)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.notificationType),
                color: _getNotificationColor(notification.notificationType),
                size: 24,
              ),
            ),
            if (!notification.isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatNotificationTime(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                context
                    .read<NotificationProvider>()
                    .markAsRead(notification.id);
                break;
              case 'delete':
                context
                    .read<NotificationProvider>()
                    .deleteNotification(notification.id);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_read),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.markAsRead),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.delete),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'MESSAGE':
        return Icons.message_outlined;
      case 'INVESTMENT':
        return Icons.account_balance_wallet_outlined;
      case 'PROJECT_UPDATE':
        return Icons.update_outlined;
      case 'SYSTEM':
        return Icons.info_outline;
      case 'MATCH':
        return Icons.handshake_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'MESSAGE':
        return Colors.blue;
      case 'INVESTMENT':
        return Colors.green;
      case 'PROJECT_UPDATE':
        return Colors.orange;
      case 'SYSTEM':
        return Colors.grey;
      case 'MATCH':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Marquer comme lu
    context.read<NotificationProvider>().markAsRead(notification.id);

    // Navigation selon le type
    switch (notification.notificationType) {
      case 'MESSAGE':
        context.router.push(const MessagingRoute());
        break;
      case 'INVESTMENT':
        context.router.push(const InvestmentListRoute());
        break;
      case 'PROJECT_UPDATE':
        if (notification.relatedObjectId != null) {
          context.router.push(
              ProjectDetailRoute(projectId: notification.relatedObjectId!));
        }
        break;
      case 'MATCH':
        // Naviguer vers l'écran de matching
        context.router.push(const DiscoverRoute());
        break;
      default:
        // Vérifier s'il y a une URL d'action définie
        if (notification.actionUrl != null &&
            notification.actionUrl!.isNotEmpty) {
          // Traiter l'URL d'action (dépend de la structure de l'URL)
          // Ex: /projects/:id -> ProjectDetailRoute(projectId: id)
          final parts = notification.actionUrl!.split('/');
          if (parts.length >= 3 && parts[1] == 'projects') {
            context.router.push(ProjectDetailRoute(projectId: parts[2]));
          }
        }
        break;
    }
  }

  // Méthode pour filtrer les notifications
  List<NotificationModel> _filterNotifications(
      List<NotificationModel> notifications) {
    switch (_currentFilter) {
      case 'unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'message':
        return notifications
            .where((n) => n.notificationType == 'MESSAGE')
            .toList();
      case 'investment':
        return notifications
            .where((n) => n.notificationType == 'INVESTMENT')
            .toList();
      case 'project':
        return notifications
            .where((n) => n.notificationType == 'PROJECT_UPDATE')
            .toList();
      case 'system':
        return notifications
            .where((n) => n.notificationType == 'SYSTEM')
            .toList();
      case 'all':
      default:
        return notifications;
    }
  }

  // Méthode pour trier les notifications
  void _sortNotifications(List<NotificationModel> notifications) {
    switch (_currentSort) {
      case 'oldest':
        notifications.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'important':
        notifications.sort((a, b) {
          if (a.isImportant && !b.isImportant) return -1;
          if (!a.isImportant && b.isImportant) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case 'newest':
      default:
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  // Dialogue de tri
  void _showSortDialog() {
    final l10n = AppLocalizations.of(context)!;

    Map<String, String> sortLabels = {
      'newest': l10n.newest,
      'oldest': l10n.oldest,
      'important': l10n.important,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sortBy),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableSorts.map((sort) {
            return RadioListTile<String>(
              title: Text(sortLabels[sort]!),
              value: sort,
              groupValue: _currentSort,
              onChanged: (value) {
                setState(() {
                  _currentSort = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  // Dialogue de confirmation pour effacer toutes les notifications
  void _showClearAllDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllNotifications),
        content: Text(l10n.clearAllNotificationsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationProvider>().clearAllNotifications();
              Navigator.pop(context);
            },
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  // Dialogue des paramètres de notification
  void _showSettingsDialog() {
    final l10n = AppLocalizations.of(context)!;

    // État local pour les paramètres
    bool pushEnabled = true;
    bool emailEnabled = true;
    bool messageNotifications = true;
    bool investmentNotifications = true;
    bool projectNotifications = true;
    bool systemNotifications = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.notificationSettings),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Canaux de livraison
                  Text(
                    l10n.deliveryChannels,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SwitchListTile(
                    title: Text(l10n.pushNotifications),
                    value: pushEnabled,
                    onChanged: (value) {
                      setState(() {
                        pushEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(l10n.emailNotifications),
                    value: emailEnabled,
                    onChanged: (value) {
                      setState(() {
                        emailEnabled = value;
                      });
                    },
                  ),
                  const Divider(),

                  // Types de notifications
                  Text(
                    l10n.notificationTypes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SwitchListTile(
                    title: Text(l10n.messages),
                    value: messageNotifications,
                    onChanged: (value) {
                      setState(() {
                        messageNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(l10n.investments),
                    value: investmentNotifications,
                    onChanged: (value) {
                      setState(() {
                        investmentNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(l10n.projectUpdates),
                    value: projectNotifications,
                    onChanged: (value) {
                      setState(() {
                        projectNotifications = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text(l10n.systemNotifications),
                    value: systemNotifications,
                    onChanged: (value) {
                      setState(() {
                        systemNotifications = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Sauvegarder les paramètres
                  // Pour l'instant, on ferme simplement le dialogue
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.settingsSaved),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }
}
