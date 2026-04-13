import 'package:flutter/material.dart';

// Auth Screens
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';

// Onboarding Screens
import '../screens/onboarding/permissions_screen.dart';
import '../screens/onboarding/language_screen.dart';
import '../screens/onboarding/user_type_screen.dart';
import '../screens/onboarding/become_rider_screen.dart';
import '../screens/onboarding/registration_complete_screen.dart';

// Main Screens
import '../screens/dashboard/main_navigation.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/pickups/pickup_requests_screen.dart';
import '../screens/pickups/active_pickups_screen.dart';
import '../screens/pickups/history_screen.dart';
import '../screens/pickups/pickup_details_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/hours_screen.dart';
import '../screens/profile/set_location_screen.dart';

/// Route names
class Routes {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // Onboarding
  static const String permissions = '/permissions';
  static const String languageSelection = '/language-selection';
  static const String userType = '/user-type';
  static const String becomeRider = '/become-rider';
  static const String registrationComplete = '/registration-complete';

  // Main
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String pickupRequests = '/pickup-requests';
  static const String activePickups = '/active-pickups';
  static const String history = '/history';
  static const String pickupDetails = '/pickup-details';
  static const String earnings = '/earnings';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String hours = '/hours';
  static const String setLocation = '/set-location';
}

/// Route generator
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case Routes.splash:
        return _buildRoute(const SplashScreen());
      case Routes.login:
        return _buildRoute(const LoginScreen());
      case Routes.signup:
        return _buildRoute(const SignupScreen());

      // Onboarding routes
      case Routes.permissions:
        return _buildRoute(const PermissionsScreen());
      case Routes.languageSelection:
        return _buildRoute(const LanguageScreen());
      case Routes.userType:
        return _buildRoute(const UserTypeScreen());
      case Routes.becomeRider:
        return _buildRoute(const BecomeRiderScreen());
      case Routes.registrationComplete:
        return _buildRoute(const RegistrationCompleteScreen());

      // Main routes
      case Routes.main:
        return _buildRoute(const MainNavigation());
      case Routes.dashboard:
        return _buildRoute(const DashboardScreen());
      case Routes.pickupRequests:
        return _buildRoute(const PickupRequestsScreen());
      case Routes.activePickups:
        return _buildRoute(const ActivePickupsScreen());
      case Routes.history:
        return _buildRoute(const HistoryScreen());
      case Routes.pickupDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(PickupDetailsScreen(pickup: args?['pickup']));
      case Routes.earnings:
        return _buildRoute(const EarningsScreen());
      case Routes.profile:
        return _buildRoute(const ProfileScreen());
      case Routes.editProfile:
        return _buildRoute(const EditProfileScreen());
      case Routes.hours:
        return _buildRoute(const HoursScreen());
      case Routes.setLocation:
        return _buildRoute(const SetLocationScreen());

      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
