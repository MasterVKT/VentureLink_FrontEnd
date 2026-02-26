// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter();

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
    ContentRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContentScreen(),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardScreen(),
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
    HomeRouteEnhanced.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreenEnhanced(),
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
    InvestmentDetailRoute.name: (routeData) {
      final args = routeData.argsAs<InvestmentDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: InvestmentDetailScreen(
          key: args.key,
          investmentId: args.investmentId,
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
    NewConversationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NewConversationScreen(),
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
    PaymentRoute.name: (routeData) {
      final args = routeData.argsAs<PaymentRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PaymentScreen(
          key: args.key,
          plan: args.plan,
          selectedCurrency: args.selectedCurrency,
        ),
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
    PrivacyRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PrivacyScreen(),
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
    ProjectCreateRouteEnhanced.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProjectCreateScreenEnhanced(),
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
    PublicProfileRoute.name: (routeData) {
      final args = routeData.argsAs<PublicProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PublicProfileScreen(
          key: args.key,
          user: args.user,
        ),
      );
    },
    PublicationDetailRoute.name: (routeData) {
      final args = routeData.argsAs<PublicationDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PublicationDetailScreen(
          key: args.key,
          publicationId: args.publicationId,
          tab: args.tab,
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
    SimpleSubscriptionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SimpleSubscriptionScreen(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    SubscriptionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SubscriptionScreen(),
      );
    },
    SupportRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SupportScreen(),
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
/// [ContentScreen]
class ContentRoute extends PageRouteInfo<void> {
  const ContentRoute({List<PageRouteInfo>? children})
      : super(
          ContentRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContentRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
/// [HomeScreenEnhanced]
class HomeRouteEnhanced extends PageRouteInfo<void> {
  const HomeRouteEnhanced({List<PageRouteInfo>? children})
      : super(
          HomeRouteEnhanced.name,
          initialChildren: children,
        );

  static const String name = 'HomeRouteEnhanced';

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
/// [InvestmentDetailScreen]
class InvestmentDetailRoute extends PageRouteInfo<InvestmentDetailRouteArgs> {
  InvestmentDetailRoute({
    Key? key,
    required String investmentId,
    List<PageRouteInfo>? children,
  }) : super(
          InvestmentDetailRoute.name,
          args: InvestmentDetailRouteArgs(
            key: key,
            investmentId: investmentId,
          ),
          initialChildren: children,
        );

  static const String name = 'InvestmentDetailRoute';

  static const PageInfo<InvestmentDetailRouteArgs> page =
      PageInfo<InvestmentDetailRouteArgs>(name);
}

class InvestmentDetailRouteArgs {
  const InvestmentDetailRouteArgs({
    this.key,
    required this.investmentId,
  });

  final Key? key;

  final String investmentId;

  @override
  String toString() {
    return 'InvestmentDetailRouteArgs{key: $key, investmentId: $investmentId}';
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
/// [NewConversationScreen]
class NewConversationRoute extends PageRouteInfo<void> {
  const NewConversationRoute({List<PageRouteInfo>? children})
      : super(
          NewConversationRoute.name,
          initialChildren: children,
        );

  static const String name = 'NewConversationRoute';

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
/// [PaymentScreen]
class PaymentRoute extends PageRouteInfo<PaymentRouteArgs> {
  PaymentRoute({
    Key? key,
    required SubscriptionPlanModel plan,
    String? selectedCurrency,
    List<PageRouteInfo>? children,
  }) : super(
          PaymentRoute.name,
          args: PaymentRouteArgs(
            key: key,
            plan: plan,
            selectedCurrency: selectedCurrency,
          ),
          initialChildren: children,
        );

  static const String name = 'PaymentRoute';

  static const PageInfo<PaymentRouteArgs> page =
      PageInfo<PaymentRouteArgs>(name);
}

class PaymentRouteArgs {
  const PaymentRouteArgs({
    this.key,
    required this.plan,
    this.selectedCurrency,
  });

  final Key? key;

  final SubscriptionPlanModel plan;

  final String? selectedCurrency;

  @override
  String toString() {
    return 'PaymentRouteArgs{key: $key, plan: $plan, selectedCurrency: $selectedCurrency}';
  }
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
/// [PrivacyScreen]
class PrivacyRoute extends PageRouteInfo<void> {
  const PrivacyRoute({List<PageRouteInfo>? children})
      : super(
          PrivacyRoute.name,
          initialChildren: children,
        );

  static const String name = 'PrivacyRoute';

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
/// [ProjectCreateScreenEnhanced]
class ProjectCreateRouteEnhanced extends PageRouteInfo<void> {
  const ProjectCreateRouteEnhanced({List<PageRouteInfo>? children})
      : super(
          ProjectCreateRouteEnhanced.name,
          initialChildren: children,
        );

  static const String name = 'ProjectCreateRouteEnhanced';

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
/// [PublicProfileScreen]
class PublicProfileRoute extends PageRouteInfo<PublicProfileRouteArgs> {
  PublicProfileRoute({
    Key? key,
    required UserModel user,
    List<PageRouteInfo>? children,
  }) : super(
          PublicProfileRoute.name,
          args: PublicProfileRouteArgs(
            key: key,
            user: user,
          ),
          initialChildren: children,
        );

  static const String name = 'PublicProfileRoute';

  static const PageInfo<PublicProfileRouteArgs> page =
      PageInfo<PublicProfileRouteArgs>(name);
}

class PublicProfileRouteArgs {
  const PublicProfileRouteArgs({
    this.key,
    required this.user,
  });

  final Key? key;

  final UserModel user;

  @override
  String toString() {
    return 'PublicProfileRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [PublicationDetailScreen]
class PublicationDetailRoute extends PageRouteInfo<PublicationDetailRouteArgs> {
  PublicationDetailRoute({
    Key? key,
    required String publicationId,
    String? tab,
    List<PageRouteInfo>? children,
  }) : super(
          PublicationDetailRoute.name,
          args: PublicationDetailRouteArgs(
            key: key,
            publicationId: publicationId,
            tab: tab,
          ),
          initialChildren: children,
        );

  static const String name = 'PublicationDetailRoute';

  static const PageInfo<PublicationDetailRouteArgs> page =
      PageInfo<PublicationDetailRouteArgs>(name);
}

class PublicationDetailRouteArgs {
  const PublicationDetailRouteArgs({
    this.key,
    required this.publicationId,
    this.tab,
  });

  final Key? key;

  final String publicationId;

  final String? tab;

  @override
  String toString() {
    return 'PublicationDetailRouteArgs{key: $key, publicationId: $publicationId, tab: $tab}';
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
/// [SimpleSubscriptionScreen]
class SimpleSubscriptionRoute extends PageRouteInfo<void> {
  const SimpleSubscriptionRoute({List<PageRouteInfo>? children})
      : super(
          SimpleSubscriptionRoute.name,
          initialChildren: children,
        );

  static const String name = 'SimpleSubscriptionRoute';

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

/// generated route for
/// [SubscriptionScreen]
class SubscriptionRoute extends PageRouteInfo<void> {
  const SubscriptionRoute({List<PageRouteInfo>? children})
      : super(
          SubscriptionRoute.name,
          initialChildren: children,
        );

  static const String name = 'SubscriptionRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SupportScreen]
class SupportRoute extends PageRouteInfo<void> {
  const SupportRoute({List<PageRouteInfo>? children})
      : super(
          SupportRoute.name,
          initialChildren: children,
        );

  static const String name = 'SupportRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
