class AppStrings {
  AppStrings._();

  static const String appName = 'LangGPT';
  static const String appTagline = 'Learn Nigerian languages\nthe fun way';

  // Auth
  static const String getStarted = 'Get Started';
  static const String login = 'Log In';
  static const String signUp = 'Sign Up';
  static const String continueWithGoogle = 'Continue with Google';
  static const String orContinueWith = 'or continue with';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String forgotPassword = 'Forgot password?';
  static const String createAccount = 'Create your account';
  static const String welcomeBack = 'Welcome back!';

  // Form fields
  static const String username = 'Username';
  static const String email = 'Email address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm password';
  static const String fullName = 'Full name';
  static const String emailOrUsername = 'Email or username';
  static const String dateOfBirth = 'Date of birth';
  static const String country = 'Country';

  // Onboarding
  static const String chooseLanguage = 'Which language\ndo you want to learn?';
  static const String chooseGoal = "What's your\ndaily goal?";
  static const String chooseLevel = "What's your\ncurrent level?";

  // Languages
  static const String igbo = 'Igbo';
  static const String yoruba = 'Yoruba';
  static const String hausa = 'Hausa';

  static const String igboSubtitle = 'Southeast Nigeria · ~45M speakers';
  static const String yorubaSubtitle = 'Southwest Nigeria · ~50M speakers';
  static const String hausaSubtitle = 'North Nigeria · ~80M speakers';

  // Navigation
  static const String home = 'Home';
  static const String explore = 'Explore';
  static const String practice = 'Practice';
  static const String leaderboard = 'Ranks';
  static const String account = 'Account';
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String getStarted = '/get-started';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupStep2 = '/signup/step-2';
  static const String signupStep3 = '/signup/step-3';
  static const String main = '/main';
  static const String home = '/home';
  static const String allLessons = '/all-lessons';
  static const String lessonDetail = '/lesson-detail';
}

class AppDimensions {
  AppDimensions._();

  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;
  static const double iconSize = 24.0;
  static const double iconSizeL = 32.0;
}
