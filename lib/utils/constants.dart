import 'package:flutter/material.dart';

/// App Colors - Warm Earthy Palette (No Orange)
/// Dark Olive, Forest Green, Warm Cream, Soft Ochre/Tan
class AppColors {
  AppColors._();

  // Primary - Forest/Olive Greens
  static const Color primary = Color(0xFF4A5D23); // Dark olive green
  static const Color primaryLight = Color(0xFF5E7A29); // Forest green
  static const Color primaryDark = Color(0xFF3A4A1C); // Deeper olive

  // Secondary - Ochre/Tan tones
  static const Color secondary = Color(0xFFB89B5E); // Warm tan/ochre
  static const Color secondaryLight = Color(0xFFD4B87A);

  // Accent - Cream & Ochre
  static const Color accent = Color(0xFFF5EBD7); // Warm cream
  static const Color accentLight = Color(0xFFFAF6EE); // Light cream
  static const Color ochre = Color(0xFFD4A762); // Soft ochre / tan

  // Backgrounds
  static const Color background = Color(0xFFFAF8F3); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF2D3319); // Dark olive-brown
  static const Color textSecondary = Color(0xFF6B705C); // Muted olive
  static const Color textLight = Color(0xFFA3A77E); // Light olive
  static const Color textOnDark = Color(0xFFFAF8F3);

  // Status colors - Natural tones (no orange)
  static const Color success = Color(0xFF5E7A29); // Forest green
  static const Color warning = Color(0xFFD4A762); // Ochre
  static const Color error = Color(0xFF8B4D39); // Earthy brown-red
  static const Color info = Color(0xFF4A5D23); // Olive

  // Waste category colors - Earthy variations (no orange)
  static const Color dryWaste = Color(0xFFD4A762); // Ochre
  static const Color wetWaste = Color(0xFF5E7A29); // Forest green
  static const Color eWaste = Color(0xFF6B705C); // Muted grey-olive
  static const Color recyclables = Color(0xFF4A5D23); // Dark olive
  static const Color hazardous = Color(0xFF8B4D39); // Earthy brown

  // Functional
  static const Color divider = Color(0xFFE8E4D9);
  static const Color border = Color(0xFFE0DBC8);
  static const Color disabled = Color(0xFFD4D0C4);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A5D23), Color(0xFF5E7A29)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5E7A29), Color(0xFF4A5D23)],
  );

  static const LinearGradient creamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5EBD7), Color(0xFFFAF8F3)],
  );
}

/// App Dimensions
class AppDimens {
  AppDimens._();

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 14.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 28.0;

  // Icon sizes
  static const double iconS = 18.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;

  // Button heights
  static const double buttonHeight = 54.0;
  static const double buttonHeightSmall = 42.0;

  // Card
  static const double cardElevation = 2.0;
}

/// App Strings
class AppStrings {
  AppStrings._();

  static const String appName = 'Emptyko';
  static const String tagline = 'Cleaner streets, greener planet';

  // Auth
  static const String login = 'Sign In';
  static const String signup = 'Create Account';
  static const String logout = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot password?';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String pickups = 'Pickups';
  static const String earnings = 'Earnings';
  static const String profile = 'Profile';
  static const String history = 'History';

  // Actions
  static const String accept = 'Accept';
  static const String reject = 'Decline';
  static const String complete = 'Complete';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';

  // Status
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String pending = 'Pending';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
}
