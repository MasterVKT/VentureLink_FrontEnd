// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VentureLink';

  @override
  String get welcomeMessage => 'Welcome to VentureLink';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Login';

  @override
  String get createAccount => 'Create an account';

  @override
  String get fullName => 'Full name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get registerButton => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get home => 'Home';

  @override
  String get discover => 'Discover';

  @override
  String get create => 'Create';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get projectTitle => 'Project title';

  @override
  String get projectDescription => 'Project description';

  @override
  String get sector => 'Sector';

  @override
  String get stage => 'Project stage';

  @override
  String get fundingNeeded => 'Funding needed';

  @override
  String get partnersNeeded => 'Partners needed';

  @override
  String get saveAsDraft => 'Save draft';

  @override
  String get publishProject => 'Publish';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get myProjects => 'My projects';

  @override
  String get favorites => 'Favorites';

  @override
  String get interests => 'Interests';

  @override
  String get activity => 'Activity';

  @override
  String get contactButton => 'Contact';

  @override
  String get showInterest => 'Show interest';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get comments => 'Comments';

  @override
  String get writeComment => 'Write a comment';

  @override
  String get send => 'Send';

  @override
  String get search => 'Search';

  @override
  String get filters => 'Filters';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get language => 'Language';

  @override
  String get languageDescription =>
      'Choose the application language. The change will be applied immediately.';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get privacySettings => 'Privacy settings';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get changePassword => 'Change password';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get help => 'Help and support';

  @override
  String get logout => 'Logout';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters long';

  @override
  String get projectTitleRequired => 'Please enter a title for your project';

  @override
  String get projectDescriptionRequired =>
      'Please enter a description for your project';

  @override
  String get sectorRequired => 'Please select a sector';

  @override
  String get stageRequired => 'Please select your project stage';

  @override
  String get noProjects => 'No projects found';

  @override
  String get noMessages => 'No messages';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get startConversation => 'Start a conversation';

  @override
  String get typeMessage => 'Type your message...';

  @override
  String get premium => 'Premium';

  @override
  String get upgrade => 'Upgrade to Premium';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get viewAll => 'View all';

  @override
  String get readMore => 'Read more';

  @override
  String get showLess => 'Show less';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get success => 'Success';

  @override
  String get confirm => 'Confirm';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get thisActionCannot => 'This action cannot be undone';

  @override
  String get featuredProjects => 'Featured Projects';

  @override
  String get recentProjects => 'Recent Projects';

  @override
  String get interestShown => 'You have shown interest in this project';

  @override
  String get addedToFavorites => 'Project added to favorites';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String get aboutMe => 'About me';

  @override
  String get expertise => 'Areas of expertise';

  @override
  String get professionalExperience => 'Professional experience';

  @override
  String get education => 'Education';

  @override
  String get present => 'Present';

  @override
  String get reviews => 'reviews';

  @override
  String get projectTags => 'Tags';

  @override
  String get viewsCount => 'views';

  @override
  String get likesCount => 'likes';

  @override
  String get commentsCount => 'comments';

  @override
  String get projectDetails => 'Project details';

  @override
  String get fundingAmount => 'Funding amount';

  @override
  String get duration => 'Duration';

  @override
  String get location => 'Location';

  @override
  String get createdBy => 'Created by';

  @override
  String get similarProjects => 'Similar projects';

  @override
  String get projectActions => 'Actions';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get noNotificationsDescription =>
      'You don\'t have any notifications at the moment.';

  @override
  String get returnHome => 'Return to home';

  @override
  String xDaysAgo(String days) {
    return '$days day(s) ago';
  }

  @override
  String xHoursAgo(String hours) {
    return '$hours hour(s) ago';
  }

  @override
  String xMinutesAgo(String minutes) {
    return '$minutes minute(s) ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get allNotificationsRead =>
      'All notifications have been marked as read';

  @override
  String get projectDetail => 'Project details';

  @override
  String get projectCreator => 'Project creator';

  @override
  String get contact => 'Contact';

  @override
  String get views => 'Views';

  @override
  String get interested => 'Interested';

  @override
  String get projectInfo => 'Project information';

  @override
  String get creationDate => 'Creation date';

  @override
  String get description => 'Description';

  @override
  String get partnersAndSkills => 'Partners and skills needed';

  @override
  String get partnerTypes => 'Partner types';

  @override
  String get requiredSkills => 'Required skills';

  @override
  String get tags => 'Tags';

  @override
  String get actions => 'Actions';

  @override
  String get favorite => 'Favorite';

  @override
  String get commentPlaceholder => 'Add a comment...';

  @override
  String get publish => 'Publish';

  @override
  String get noComments => 'No comments yet';

  @override
  String get projectInterestShown => 'You have shown interest in this project';

  @override
  String get projectInterestRemoved =>
      'You have removed your interest from this project';

  @override
  String get projectAddedToFavorites => 'Project added to favorites';

  @override
  String get projectRemovedFromFavorites => 'Project removed from favorites';

  @override
  String get ideaStage => 'Idea';

  @override
  String get prototypeStage => 'Prototype';

  @override
  String get developmentStage => 'Development';

  @override
  String get growthStage => 'Growth';

  @override
  String get investorPartner => 'Investor';

  @override
  String get associatePartner => 'Associate';

  @override
  String get mentorPartner => 'Mentor';

  @override
  String welcomeToApp(String appName) {
    return 'Welcome to\n$appName';
  }

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get loginButtonText => 'Login';

  @override
  String get continueWith => 'Or continue with';

  @override
  String get googleLogin => 'Google';

  @override
  String get appleLogin => 'Apple';

  @override
  String get passwordVisibility => 'Show/hide password';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String passwordMinLength(int length) {
    return 'Password must be at least $length characters';
  }

  @override
  String get registration => 'Registration';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get joinCommunity => 'Join the VentureLink community';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get enterFirstName => 'Please enter your first name';

  @override
  String get enterLastName => 'Please enter your last name';

  @override
  String get enterConfirmPassword => 'Please confirm your password';

  @override
  String get agreeToTerms => 'I agree to the ';

  @override
  String get termsOfUse => 'terms of use';

  @override
  String get and => ' and the ';

  @override
  String get privacyPolicy => 'privacy policy';

  @override
  String get or => 'or';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get signUpWithApple => 'Sign up with Apple';

  @override
  String get newProject => 'New';

  @override
  String get notifNewInterest => 'New Interest';

  @override
  String get notifNewMessage => 'New Message';

  @override
  String get notifNewComment => 'New Comment';

  @override
  String get notifSystemUpdate => 'System Update';

  @override
  String notifInterestMessage(String userName, String projectName) {
    return '$userName has shown interest in your project \"$projectName\"';
  }

  @override
  String notifMessageReceived(String userName) {
    return 'You have received a new message from $userName';
  }

  @override
  String notifCommentMessage(String userName, String projectName) {
    return '$userName commented on your project \"$projectName\"';
  }

  @override
  String get notifSystemUpdateMessage =>
      'Discover the new features of VentureLink in our latest update!';

  @override
  String get deleteNotification => 'Delete notification';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get clearAll => 'Clear all';

  @override
  String get all => 'All';

  @override
  String get unread => 'Unread';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get noUnreadNotifications => 'No unread notifications';

  @override
  String get searchNotifications => 'Search notifications';

  @override
  String get investments => 'Investments';

  @override
  String get projects => 'Projects';

  @override
  String get system => 'System';

  @override
  String get sort => 'Sort';

  @override
  String get sortBy => 'Sort by';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get important => 'Important';

  @override
  String get clearAllNotifications => 'Clear all notifications';

  @override
  String get clearAllNotificationsConfirm =>
      'Are you sure you want to delete all notifications? This action cannot be undone.';

  @override
  String get clear => 'Clear';

  @override
  String get deliveryChannels => 'Delivery channels';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get emailNotifications => 'Email notifications';

  @override
  String get notificationTypes => 'Notification types';

  @override
  String get projectUpdates => 'Project updates';

  @override
  String get systemNotifications => 'System notifications';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get yesterday => 'Yesterday';
}
