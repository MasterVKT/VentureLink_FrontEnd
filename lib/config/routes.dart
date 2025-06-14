import 'package:flutter/material.dart';
import 'package:venturelink/presentation/screens/auth/login_screen.dart';
import 'package:venturelink/presentation/screens/auth/register_screen.dart';
import 'package:venturelink/presentation/screens/home/home_screen.dart';
import 'package:venturelink/presentation/screens/project/project_list_screen.dart';
import 'package:venturelink/presentation/screens/project/project_detail_screen.dart';
import 'package:venturelink/presentation/screens/project/project_create_screen.dart';
import 'package:venturelink/presentation/screens/profile/profile_screen.dart';
import 'package:venturelink/presentation/screens/messaging/messaging_screen.dart';
import 'package:venturelink/presentation/screens/search/search_screen.dart';
import 'package:venturelink/presentation/screens/notifications/notifications_screen.dart';
import 'package:venturelink/presentation/screens/settings/settings_screen.dart';

class Routes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String projectList = '/projects';
  static const String projectDetail = '/project-detail';
  static const String projectCreate = '/project-create';
  static const String profile = '/profile';
  static const String messaging = '/messaging';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // Route map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      projectList: (context) => const ProjectListScreen(),
      projectDetail: (context) => const ProjectDetailScreen(projectId: ''),
      projectCreate: (context) => const ProjectCreateScreen(),
      profile: (context) => const ProfileScreen(),
      messaging: (context) => const MessagingScreen(),
      search: (context) => const SearchScreen(),
      notifications: (context) => const NotificationsScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }

  // For routes that need parameters
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case projectDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final projectId = args?['projectId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => ProjectDetailScreen(projectId: projectId),
        );
      case projectCreate:
        return MaterialPageRoute(
          builder: (context) => const ProjectCreateScreen(),
        );
      default:
        return null;
    }
  }
}
