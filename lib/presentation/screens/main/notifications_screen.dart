import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:venturelink/core/config/config_service.dart';

@RoutePage()
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Toutes', 'Non lues', 'Mentions'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // TODO: Marquer toutes les notifications comme lues
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) => _buildNotificationList()).toList(),
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(ConfigService.defaultPadding),
      itemCount: 10, // TODO: Remplacer par la liste réelle
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: ConfigService.defaultSpacing),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
            title: Text(
              'Notification ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: ConfigService.defaultSpacing / 2),
                Text(
                  'Description de la notification ${index + 1}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: ConfigService.defaultSpacing / 2),
                Text(
                  'Il y a ${index + 1} heures',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'read',
                  child: Text('Marquer comme lu'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer'),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'read':
                    // TODO: Marquer la notification comme lue
                    break;
                  case 'delete':
                    // TODO: Supprimer la notification
                    break;
                }
              },
            ),
            onTap: () {
              // TODO: Naviguer vers le contenu de la notification
            },
          ),
        );
      },
    );
  }
}
