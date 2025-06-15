import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/notification_provider.dart';
import 'package:venturelink/data/models/notification_model.dart';

import 'package:venturelink/core/router/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:async';

@RoutePage()
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  Timer? _searchDebounce;
  String? _selectedFilter;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive ? _buildSearchBar() : Text(l10n.notifications),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        titleSpacing: _isSearchActive ? 0 : null,
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearchActive ? 'Fermer la recherche' : l10n.search,
            iconSize: 24,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Plus d\'options',
            iconSize: 24,
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: _buildMenuRow(
                  Icons.mark_email_read,
                  l10n.markAllRead,
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: _buildMenuRow(
                  Icons.settings,
                  l10n.notificationSettings,
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: _buildMenuRow(
                  Icons.refresh,
                  'Actualiser',
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            if (!_isSearchActive) _buildFilterChips(),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return _buildLoadingWidget();
                  }

                  if (provider.error != null) {
                    return _buildErrorWidget(provider.error!, provider);
                  }

                  final notifications = _getFilteredNotifications(provider);

                  if (notifications.isEmpty) {
                    return _buildEmptyWidget();
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadNotifications(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: isTablet ? 24 : 16,
                      ),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(
                          notifications[index],
                          index,
                          isTablet,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }

  Widget _buildFilterChips() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final filters = <Map<String, String?>>[
      {'value': null, 'label': l10n.all},
      {'value': 'PROJECT', 'label': l10n.projects},
      {'value': 'INVESTMENT', 'label': l10n.investments},
      {'value': 'MESSAGE', 'label': l10n.messages},
      {'value': 'PAYMENT', 'label': 'Paiements'},
      {'value': 'SYSTEM', 'label': l10n.system},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter =
                      selected ? filter['value'] as String? : null;
                });
                HapticFeedback.lightImpact();
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  List<NotificationModel> _getFilteredNotifications(
      NotificationProvider provider) {
    List<NotificationModel> notifications;

    if (_isSearchActive && provider.searchQuery.isNotEmpty) {
      notifications = provider.searchResults;
    } else {
      notifications = provider.notifications;
    }

    if (_selectedFilter != null) {
      notifications =
          notifications.where((n) => n.category == _selectedFilter).toList();
    }

    return notifications;
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des notifications...'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: l10n.searchNotifications,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      onChanged: _onSearchChanged,
    );
  }

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      context.read<NotificationProvider>().searchNotifications(value);
    });
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    int index,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final isUnread = notification.isUnread;

    // Taille responsive pour l'icône
    final iconSize = isTablet ? 44.0 : 40.0;
    final iconContainerSize = isTablet ? 52.0 : 48.0;

    return Container(
      margin: EdgeInsets.only(
        bottom: index == 0 ? 12 : 8, // Plus d'espace pour la première carte
      ),
      decoration: BoxDecoration(
        color: isUnread
            ? theme.colorScheme.primaryContainer.withOpacity(0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.outline.withOpacity(0.12),
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(
                  notification,
                  iconContainerSize,
                  iconSize,
                  isUnread,
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: _buildNotificationContent(
                    notification,
                    isUnread,
                    isTablet,
                  ),
                ),
                _buildNotificationMenu(notification, isUnread),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
    NotificationModel notification,
    double containerSize,
    double iconSize,
    bool isUnread,
  ) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: notification.categoryColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.categoryIcon,
            color: notification.categoryColor,
            size: iconSize * 0.6, // Taille proportionnelle au container
          ),
        ),
        if (isUnread)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationContent(
    NotificationModel notification,
    bool isUnread,
    bool isTablet,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
            height: 1.3,
          ),
          maxLines: isTablet ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          notification.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color:
                theme.colorScheme.onSurface.withOpacity(isUnread ? 0.75 : 0.65),
            height: 1.4,
          ),
          maxLines: isTablet ? 4 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        _buildNotificationMetadata(notification),
      ],
    );
  }

  Widget _buildNotificationMetadata(NotificationModel notification) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          _formatNotificationTime(notification.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: notification.categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getCategoryLabel(notification.category),
            style: theme.textTheme.bodySmall?.copyWith(
              color: notification.categoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (notification.isHighPriority) ...[
          const SizedBox(width: 8),
          Icon(
            notification.isUrgent ? Icons.priority_high : Icons.star,
            size: 16,
            color: notification.priorityColor,
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationMenu(NotificationModel notification, bool isUnread) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      width: 48,
      height: 48,
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
        tooltip: 'Plus d\'options',
        onSelected: (value) => _handleNotificationAction(value, notification),
        itemBuilder: (context) => [
          if (isUnread)
            PopupMenuItem(
              value: 'mark_read',
              child: _buildMenuRow(Icons.mark_email_read, l10n.markAsRead),
            ),
          PopupMenuItem(
            value: 'archive',
            child: _buildMenuRow(Icons.archive_outlined, 'Archiver'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, NotificationProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingNotifications,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                provider.clearError();
                provider.loadNotifications();
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isSearchActive ? Icons.search_off : Icons.notifications_none,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _isSearchActive ? 'Aucun résultat' : l10n.noNotifications,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (_isSearchActive) ...[
            const SizedBox(height: 8),
            Text(
              'Essayez d\'autres mots-clés',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _searchDebounce?.cancel();
        context.read<NotificationProvider>().clearSearch();
      }
    });
    HapticFeedback.lightImpact();
  }

  void _handleMenuAction(String action) {
    final provider = context.read<NotificationProvider>();
    final l10n = AppLocalizations.of(context)!;

    switch (action) {
      case 'mark_all_read':
        _showConfirmationDialog(
          title: l10n.markAllRead,
          content:
              'Êtes-vous sûr de vouloir marquer toutes les notifications comme lues ?',
          confirmText: l10n.markAsRead,
          onConfirm: () {
            provider.markAllAsRead();
            _showFeedback(
                'Toutes les notifications ont été marquées comme lues');
          },
        );
        break;
      case 'settings':
        _showNotificationSettings();
        break;
      case 'refresh':
        provider.loadNotifications();
        HapticFeedback.lightImpact();
        break;
    }
  }

  void _handleNotificationAction(
      String action, NotificationModel notification) {
    final provider = context.read<NotificationProvider>();
    final l10n = AppLocalizations.of(context)!;

    switch (action) {
      case 'mark_read':
        provider.markAsRead(notification.id);
        _showFeedback('Notification marquée comme lue');
        HapticFeedback.lightImpact();
        break;
      case 'archive':
        provider.archiveNotification(notification.id);
        _showFeedback('Notification archivée');
        HapticFeedback.lightImpact();
        break;
      case 'delete':
        _showConfirmationDialog(
          title: 'Supprimer la notification',
          content: 'Êtes-vous sûr de vouloir supprimer cette notification ?',
          confirmText: l10n.delete,
          isDestructive: true,
          onConfirm: () {
            provider.deleteNotification(notification.id);
            _showFeedback('Notification supprimée');
          },
        );
        break;
    }
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (notification.isUnread) {
      context.read<NotificationProvider>().markAsRead(notification.id);
    }

    HapticFeedback.lightImpact();

    // Navigation selon la catégorie
    switch (notification.category) {
      case 'PROJECT':
        if (notification.objectId != null) {
          context.router
              .push(ProjectDetailRoute(projectId: notification.objectId!));
        } else {
          context.router.push(const HomeRoute());
        }
        break;
      case 'INVESTMENT':
        // Rediriger vers la liste des investissements ou détail si objectId disponible
        context.router
            .push(const HomeRoute()); // TODO: Créer InvestmentListRoute
        break;
      case 'MESSAGE':
        // Rediriger vers la messagerie ou conversation spécifique si objectId disponible
        context.router.push(const HomeRoute()); // TODO: Créer MessagingRoute
        break;
      case 'PAYMENT':
        // Rediriger vers les paiements
        context.router.push(const SubscriptionRoute());
        break;
      default:
        context.router.push(const HomeRoute());
    }
  }

  void _showNotificationSettings() {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<NotificationProvider>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.notificationSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPreferenceSwitch(
                  l10n.pushNotifications,
                  'enable_push',
                  provider,
                  setDialogState,
                  Icons.notifications,
                ),
                _buildPreferenceSwitch(
                  l10n.emailNotifications,
                  'enable_email',
                  provider,
                  setDialogState,
                  Icons.email,
                ),
                const Divider(),
                Text(
                  l10n.notificationTypes,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _buildPreferenceSwitch(
                  'Notifications de projet',
                  'project_notifications',
                  provider,
                  setDialogState,
                  Icons.work,
                ),
                _buildPreferenceSwitch(
                  'Notifications d\'investissement',
                  'investment_notifications',
                  provider,
                  setDialogState,
                  Icons.attach_money,
                ),
                _buildPreferenceSwitch(
                  'Notifications de message',
                  'message_notifications',
                  provider,
                  setDialogState,
                  Icons.message,
                ),
                _buildPreferenceSwitch(
                  'Notifications de paiement',
                  'payment_notifications',
                  provider,
                  setDialogState,
                  Icons.payment,
                ),
                _buildPreferenceSwitch(
                  'Notifications système',
                  'system_notifications',
                  provider,
                  setDialogState,
                  Icons.settings,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch(
    String title,
    String key,
    NotificationProvider provider,
    StateSetter setDialogState,
    IconData icon,
  ) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      value: provider.preferences[key] ?? true,
      onChanged: (value) {
        provider.updateNotificationPreferences({key: value});
        setDialogState(() {});
        HapticFeedback.lightImpact();
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatNotificationTime(DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  String _getCategoryLabel(String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'PROJECT':
        return l10n.projects;
      case 'INVESTMENT':
        return l10n.investments;
      case 'MESSAGE':
        return l10n.messages;
      case 'PAYMENT':
        return 'Paiements';
      case 'SYSTEM':
        return l10n.system;
      default:
        return 'Général';
    }
  }
}
