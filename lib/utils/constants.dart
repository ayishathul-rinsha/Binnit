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
  // Made background incredibly soft and barely off-white for a cleaner look
  static const Color background = Color(0xFFFCFCFA); 
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1E2413); // High contrast dark olive
  static const Color textSecondary = Color(0xFF6B705C); // Muted olive
  static const Color textLight = Color(0xFFA3A77E); // Light olive
  static const Color textOnDark = Color(0xFFFAF8F3);

  // Status colors - Natural tones
  static const Color success = Color(0xFF5E7A29); // Forest green
  static const Color warning = Color(0xFFD4A762); // Ochre
  static const Color error = Color(0xFFD95030); // Vibrant earthy red
  static const Color info = Color(0xFF4A5D23); // Olive

  // Functional
  static const Color divider = Color(0xFFF2EFE8); // Softer divider
  static const Color border = Color(0xFFEBE6D8); // Softer border
  static const Color disabled = Color(0xFFD4D0C4);

  // Waste Categories
  static const Color dryWaste = Color(0xFF8B7355); // Earthy brown
  static const Color recyclables = Color(0xFF4A5D23); // Dark olive
  static const Color wetWaste = Color(0xFF5E7A29); // Forest green
  static const Color hazardous = Color(0xFFD95030); // Earthy red
  static const Color eWaste = Color(0xFFD4A762); // Ochre

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A5D23), Color(0xFF5E7A29)],
  );

  static const LinearGradient primaryLightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5E7A29), Color(0xFFA3A77E)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5E7A29), Color(0xFF4A5D23)],
  );
  
  static const LinearGradient glassmorphicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x99FFFFFF), Color(0x33FFFFFF)],
  );
}

/// Radical Makeover Dimensions
class AppDimens {
  AppDimens._();

  // Padding
  static const double paddingXS = 8.0;
  static const double paddingS = 12.0;
  static const double paddingM = 20.0;
  static const double paddingL = 28.0;
  static const double paddingXL = 36.0;

  // Border radius (Sweeping and soft)
  static const double radiusS = 12.0;
  static const double radiusM = 20.0;
  static const double radiusL = 28.0;
  static const double radiusXL = 36.0;

  // Icon sizes
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button heights (Plump and tap-friendly)
  static const double buttonHeight = 60.0;
  static const double buttonHeightSmall = 46.0;

  // Premium Custom Shadows
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppColors.textPrimary.withOpacity(0.04),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
  ];
  
  static final List<BoxShadow> glowShadow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
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
}
