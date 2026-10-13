
class AppConstants {
  static const String appName = 'CRT Quiz';
  static const String appTagline = 'Master Your Campus Placement Tests';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 1100.0;
  static const double maxFormWidth = 480.0;

  // Quiz Topics
  static const List<String> quizTopics = [
    'All Topics',
    'Quantitative Aptitude',
    'Logical Reasoning',
    'Verbal Ability',
    'Technical / CS Core',
  ];

  // Difficulty Levels
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';

  // Spacing Scale
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Animations
  static const Duration splashDuration = Duration(milliseconds: 1600);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
}
