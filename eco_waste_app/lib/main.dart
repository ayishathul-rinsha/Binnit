import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const EcoWasteApp());
}

class EcoWasteApp extends StatelessWidget {
  const EcoWasteApp({super.key});

  bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    // Show device frame on both web and desktop for iPhone preview
    final showDeviceFrame = kIsWeb || _isDesktop;
    
    if (showDeviceFrame) {
      // Outer MaterialApp just for the dark background shell
      return MaterialApp(
        title: 'EcoWaste',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const DeviceFrameWrapper(),
      );
    }

    // On mobile devices, run the app normally
    return MaterialApp(
      title: 'EcoWaste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const LoginScreen(),
    );
  }
}

/// Wrapper widget that displays the app in an iPhone 13 device frame.
/// Contains its own MaterialApp so ALL navigation stays inside the frame.
class DeviceFrameWrapper extends StatelessWidget {
  const DeviceFrameWrapper({super.key});
  
  // iPhone 13 dimensions
  static const double deviceWidth = 390;
  static const double deviceHeight = 844;
  static const double frameThickness = 12;
  static const double borderRadius = 44;
  static const double notchWidth = 160;
  static const double notchHeight = 34;
  static const double homeIndicatorWidth = 134;
  static const double homeIndicatorHeight = 5;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // App title
              const Text(
                '📱 EcoWaste App Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'iPhone 13 • ${deviceWidth.toInt()} × ${deviceHeight.toInt()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              // Device frame
              Container(
                width: deviceWidth + (frameThickness * 2),
                height: deviceHeight + (frameThickness * 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D3A),
                  borderRadius: BorderRadius.circular(borderRadius + frameThickness),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: const Color(0xFF4A6741).withOpacity(0.2),
                      blurRadius: 60,
                      spreadRadius: -10,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF3D3D4D),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(frameThickness),
                  child: Stack(
                    children: [
                      // Screen content — nested MaterialApp so all navigation stays in frame
                      ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: SizedBox(
                          width: deviceWidth,
                          height: deviceHeight,
                          child: MaterialApp(
                            title: 'EcoWaste',
                            debugShowCheckedModeBanner: false,
                            theme: AppTheme.themeData,
                            home: const LoginScreen(),
                            builder: (context, child) {
                              return MediaQuery(
                                data: const MediaQueryData(
                                  size: Size(deviceWidth, deviceHeight),
                                  devicePixelRatio: 3.0,
                                  padding: EdgeInsets.only(top: 47, bottom: 34),
                                ),
                                child: child ?? const SizedBox.shrink(),
                              );
                            },
                          ),
                        ),
                      ),
                      // Dynamic Island / Notch
                      Positioned(
                        top: 12,
                        left: (deviceWidth - notchWidth) / 2,
                        child: IgnorePointer(
                          child: Container(
                            width: notchWidth,
                            height: notchHeight,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(notchHeight / 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Camera
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1a1a2e),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF2D2D3A),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Home indicator
                      Positioned(
                        bottom: 8,
                        left: (deviceWidth - homeIndicatorWidth) / 2,
                        child: IgnorePointer(
                          child: Container(
                            width: homeIndicatorWidth,
                            height: homeIndicatorHeight,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(homeIndicatorHeight / 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Interaction hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Interactive Preview - Click and scroll to test',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
