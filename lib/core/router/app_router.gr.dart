// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AdvancedSearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AdvancedSearchScreen(),
      );
    },
    ChatRoute.name: (routeData) {
      final args = routeData.argsAs<ChatRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChatScreen(
          key: args.key,
          conversationId: args.conversationId,
          otherUserName: args.otherUserName,
        ),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardScreen(),
      );
    },
    DiscoverRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DiscoverScreen(),
      );
    },
    ForgotPasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ForgotPasswordScreen(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    InvestmentCreateRoute.name: (routeData) {
      final args = routeData.argsAs<InvestmentCreateRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: InvestmentCreateScreen(
          key: args.key,
          projectId: args.projectId,
        ),
      );
    },
    InvestmentListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InvestmentListScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainScreen(),
      );
    },
    MessagingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MessagingScreen(),
      );
    },
    NotificationsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotificationsScreen(),
      );
    },
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingScreen(),
      );
    },
    PaymentWebViewRoute.name: (routeData) {
      final args = routeData.argsAs<PaymentWebViewRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PaymentWebViewScreen(
          key: args.key,
          sessionId: args.sessionId,
          paymentUrl: args.paymentUrl,
          successUrl: args.successUrl,
          cancelUrl: args.cancelUrl,
        ),
      );
    },
    PremiumRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PremiumScreen(),
      );
    },
    ProfileEditRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileEditScreen(),
      );
    },
    ProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileScreen(),
      );
    },
    ProjectCreateRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProjectCreateScreen(),
      );
    },
    ProjectDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ProjectDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProjectDetailScreen(
          key: args.key,
          projectId: args.projectId,
        ),
      );
    },
    RegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegisterScreen(),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchScreen(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsScreen(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
  };
}

/// generated route for
/// [AdvancedSearchScreen]
class AdvancedSearchRoute extends PageRouteInfo<void> {
  const AdvancedSearchRoute({List<PageRouteInfo>? children})
      : super(
          AdvancedSearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'AdvancedSearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ChatScreen]
class ChatRoute extends PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    Key? key,
    required String conversationId,
    required String otherUserName,
    List<PageRouteInfo>? children,
  }) : super(
          ChatRoute.name,
          args: ChatRouteArgs(
            key: key,
            conversationId: conversationId,
            otherUserName: otherUserName,
          ),
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static const PageInfo<ChatRouteArgs> page = PageInfo<ChatRouteArgs>(name);
}

class ChatRouteArgs {
  const ChatRouteArgs({
    this.key,
    required this.conversationId,
    required this.otherUserName,
  });

  final Key? key;

  final String conversationId;

  final String otherUserName;

  @override
  String toString() {
    return 'ChatRouteArgs{key: $key, conversationId: $conversationId, otherUserName: $otherUserName}';
  }
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DiscoverScreen]
class DiscoverRoute extends PageRouteInfo<void> {
  const DiscoverRoute({List<PageRouteInfo>? children})
      : super(
          DiscoverRoute.name,
          initialChildren: children,
        );

  static const String name = 'DiscoverRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
      : super(
          ForgotPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ForgotPasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [InvestmentCreateScreen]
class InvestmentCreateRoute extends PageRouteInfo<InvestmentCreateRouteArgs> {
  InvestmentCreateRoute({
    Key? key,
    required String projectId,
    List<PageRouteInfo>? children,
  }) : super(
          InvestmentCreateRoute.name,
          args: InvestmentCreateRouteArgs(
            key: key,
            projectId: projectId,
          ),
          initialChildren: children,
        );

  static const String name = 'InvestmentCreateRoute';

  static const PageInfo<InvestmentCreateRouteArgs> page =
      PageInfo<InvestmentCreateRouteArgs>(name);
}

class InvestmentCreateRouteArgs {
  const InvestmentCreateRouteArgs({
    this.key,
    required this.projectId,
  });

  final Key? key;

  final String projectId;

  @override
  String toString() {
    return 'InvestmentCreateRouteArgs{key: $key, projectId: $projectId}';
  }
}

/// generated route for
/// [InvestmentListScreen]
class InvestmentListRoute extends PageRouteInfo<void> {
  const InvestmentListRoute({List<PageRouteInfo>? children})
      : super(
          InvestmentListRoute.name,
          initialChildren: children,
        );

  static const String name = 'InvestmentListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MessagingScreen]
class MessagingRoute extends PageRouteInfo<void> {
  const MessagingRoute({List<PageRouteInfo>? children})
      : super(
          MessagingRoute.name,
          initialChildren: children,
        );

  static const String name = 'MessagingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationsScreen]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
      : super(
          NotificationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
      : super(
          OnboardingRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PaymentWebViewScreen]
class PaymentWebViewRoute extends PageRouteInfo<PaymentWebViewRouteArgs> {
  PaymentWebViewRoute({
    Key? key,
    required String sessionId,
    required String paymentUrl,
    required String successUrl,
    required String cancelUrl,
    List<PageRouteInfo>? children,
  }) : super(
          PaymentWebViewRoute.name,
          args: PaymentWebViewRouteArgs(
            key: key,
            sessionId: sessionId,
            paymentUrl: paymentUrl,
            successUrl: successUrl,
            cancelUrl: cancelUrl,
          ),
          initialChildren: children,
        );

  static const String name = 'PaymentWebViewRoute';

  static const PageInfo<PaymentWebViewRouteArgs> page =
      PageInfo<PaymentWebViewRouteArgs>(name);
}

class PaymentWebViewRouteArgs {
  const PaymentWebViewRouteArgs({
    this.key,
    required this.sessionId,
    required this.paymentUrl,
    required this.successUrl,
    required this.cancelUrl,
  });

  final Key? key;

  final String sessionId;

  final String paymentUrl;

  final String successUrl;

  final String cancelUrl;

  @override
  String toString() {
    return 'PaymentWebViewRouteArgs{key: $key, sessionId: $sessionId, paymentUrl: $paymentUrl, successUrl: $successUrl, cancelUrl: $cancelUrl}';
  }
}

/// generated route for
/// [PremiumScreen]
class PremiumRoute extends PageRouteInfo<void> {
  const PremiumRoute({List<PageRouteInfo>? children})
      : super(
          PremiumRoute.name,
          initialChildren: children,
        );

  static const String name = 'PremiumRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfileEditScreen]
class ProfileEditRoute extends PageRouteInfo<void> {
  const ProfileEditRoute({List<PageRouteInfo>? children})
      : super(
          ProfileEditRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileEditRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProjectCreateScreen]
class ProjectCreateRoute extends PageRouteInfo<void> {
  const ProjectCreateRoute({List<PageRouteInfo>? children})
      : super(
          ProjectCreateRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProjectCreateRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProjectDetailScreen]
class ProjectDetailRoute extends PageRouteInfo<ProjectDetailRouteArgs> {
  ProjectDetailRoute({
    Key? key,
    required String projectId,
    List<PageRouteInfo>? children,
  }) : super(
          ProjectDetailRoute.name,
          args: ProjectDetailRouteArgs(
            key: key,
            projectId: projectId,
          ),
          initialChildren: children,
        );

  static const String name = 'ProjectDetailRoute';

  static const PageInfo<ProjectDetailRouteArgs> page =
      PageInfo<ProjectDetailRouteArgs>(name);
}

class ProjectDetailRouteArgs {
  const ProjectDetailRouteArgs({
    this.key,
    required this.projectId,
  });

  final Key? key;

  final String projectId;

  @override
  String toString() {
    return 'ProjectDetailRouteArgs{key: $key, projectId: $projectId}';
  }
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(
          RegisterRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
