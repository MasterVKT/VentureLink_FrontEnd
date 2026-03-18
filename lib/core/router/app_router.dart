import 'package:auto_route/auto_route.dart';
import 'package:venturelink/presentation/screens/project/project_list_screen.dart';
import 'package:venturelink/presentation/screens/splash_screen.dart';
import 'package:venturelink/presentation/screens/auth/login_screen.dart';
import 'package:venturelink/presentation/screens/auth/register_screen.dart';
import 'package:venturelink/presentation/screens/auth/forgot_password_screen.dart';
import 'package:venturelink/presentation/screens/main/main_screen.dart';
import 'package:venturelink/presentation/screens/home/home_screen.dart';
import 'package:venturelink/presentation/screens/home/home_screen_enhanced.dart';
import 'package:venturelink/presentation/screens/discover/discover_screen.dart';
import 'package:venturelink/presentation/screens/content/content_screen.dart';
import 'package:venturelink/presentation/screens/content/publication_detail_screen.dart';
import 'package:venturelink/presentation/screens/messaging/messaging_screen.dart';
import 'package:venturelink/presentation/screens/messaging/chat_screen.dart';
import 'package:venturelink/presentation/screens/messaging/new_conversation_screen.dart';
import 'package:venturelink/presentation/screens/notifications/notifications_screen.dart';
import 'package:venturelink/presentation/screens/profile/profile_screen.dart';
import 'package:venturelink/presentation/screens/profile/profile_edit_screen.dart';
import 'package:venturelink/presentation/screens/profile/public_profile_screen.dart';
import 'package:venturelink/presentation/screens/settings/settings_screen.dart';
import 'package:venturelink/presentation/screens/search/search_screen.dart';
import 'package:venturelink/presentation/screens/project/project_create_screen.dart';
import 'package:venturelink/presentation/screens/project/project_create_screen_enhanced.dart';
import 'package:venturelink/presentation/screens/project/project_detail_screen.dart';
import 'package:venturelink/presentation/screens/project/project_list_screen.dart';
import 'package:venturelink/presentation/screens/project/favorites_screen.dart';
import 'package:venturelink/presentation/screens/investment/investment_list_screen.dart';
import 'package:venturelink/presentation/screens/investment/investment_create_screen.dart';
import 'package:venturelink/presentation/screens/investment/investment_detail_screen.dart';
import 'package:venturelink/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:venturelink/presentation/screens/subscription/premium_screen.dart';
import 'package:venturelink/presentation/screens/subscription/payment_webview_screen.dart';
import 'package:venturelink/presentation/screens/subscription/subscription_screen.dart';
import 'package:venturelink/presentation/screens/subscription/payment_screen.dart';
import 'package:venturelink/presentation/screens/subscription/simple_subscription_screen.dart';
import 'package:venturelink/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:venturelink/presentation/screens/search/advanced_search_screen.dart';
import 'package:venturelink/presentation/screens/settings/privacy_screen.dart';
import 'package:venturelink/presentation/screens/settings/support_screen.dart';
import 'package:venturelink/data/models/subscription_plan_model.dart';
import 'package:flutter/widgets.dart';
import 'package:venturelink/data/models/user_model.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  AppRouter() : super();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: SplashRoute.page,
          initial: true,
        ),
        AutoRoute(
          path: '/login',
          page: LoginRoute.page,
        ),
        AutoRoute(
          path: '/register',
          page: RegisterRoute.page,
        ),
        AutoRoute(
          path: '/forgot-password',
          page: ForgotPasswordRoute.page,
        ),
        AutoRoute(
          path: '/main',
          page: MainRoute.page,
          children: [
            AutoRoute(
              path: 'home',
              page: HomeRoute.page,
            ),
            AutoRoute(
              path: 'discover',
              page: DiscoverRoute.page,
            ),
            AutoRoute(
              path: 'content',
              page: ContentRoute.page,
            ),
            AutoRoute(
              path: 'investments',
              page: InvestmentListRoute.page,
            ),
            AutoRoute(
              path: 'messaging',
              page: MessagingRoute.page,
            ),
            AutoRoute(
              path: 'notifications',
              page: NotificationsRoute.page,
            ),
            AutoRoute(
              path: 'profile',
              page: ProfileRoute.page,
            ),
          ],
        ),
        AutoRoute(
          path: '/publication-detail/:publicationId',
          page: PublicationDetailRoute.page,
        ),
        AutoRoute(
          path: '/chat/:conversationId/:otherUserName',
          page: ChatRoute.page,
        ),
        AutoRoute(
          path: '/notifications',
          page: NotificationsRoute.page,
        ),
        AutoRoute(
          path: '/settings',
          page: SettingsRoute.page,
        ),
        AutoRoute(
          path: '/privacy',
          page: PrivacyRoute.page,
        ),
        AutoRoute(
          path: '/support',
          page: SupportRoute.page,
        ),
        AutoRoute(
          path: '/profile-edit',
          page: ProfileEditRoute.page,
        ),
        AutoRoute(
          path: '/project-create',
          page: ProjectCreateRoute.page,
        ),
        AutoRoute(
          path: '/project-list',
          page: ProjectListRoute.page,
        ),
        AutoRoute(
          path: '/search',
          page: SearchRoute.page,
        ),
        AutoRoute(
          path: '/project-detail',
          page: ProjectDetailRoute.page,
        ),
        AutoRoute(
          path: '/favorites',
          page: FavoritesRoute.page,
        ),
        AutoRoute(
          path: '/investment-create/:projectId',
          page: InvestmentCreateRoute.page,
        ),
        AutoRoute(
          path: '/investment-detail/:investmentId',
          page: InvestmentDetailRoute.page,
        ),
        AutoRoute(
          path: '/onboarding',
          page: OnboardingRoute.page,
        ),
        AutoRoute(
          path: '/premium',
          page: PremiumRoute.page,
        ),
        AutoRoute(
          path: '/subscription',
          page: SimpleSubscriptionRoute.page,
        ),
        AutoRoute(
          path: '/payment',
          page: PaymentRoute.page,
        ),
        AutoRoute(
          path: '/payment-webview',
          page: PaymentWebViewRoute.page,
        ),
        AutoRoute(
          path: '/dashboard',
          page: DashboardRoute.page,
        ),
        AutoRoute(
          path: '/advanced-search',
          page: AdvancedSearchRoute.page,
        ),
        AutoRoute(
          path: '/public-profile',
          page: PublicProfileRoute.page,
        ),
      ];
}
