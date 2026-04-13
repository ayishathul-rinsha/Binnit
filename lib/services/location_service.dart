import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Location Service for GPS functionality and live broadcasting
/// Uses active polling (Timer) as the primary mechanism for maximum
/// compatibility with mock location apps and newer Android versions.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Timer? _pollingTimer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  double? _lastLat;
  double? _lastLng;

  /// Check and request location permission
  static Future<LocationPermission> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermission.denied;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      final permission = await checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('[LOCATION] getCurrentPosition error: $e');
      return null;
    }
  }

  /// Starts live tracking and uploading coordinates to Firestore
  /// Uses active polling every 3 seconds for maximum reliability.
  Future<void> startTracking(String uid) async {
    if (_isTracking) return;

    final permission = await checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('[LOCATION] ❌ Live tracking failed: Permission denied');
      return;
    }

    _isTracking = true;
    debugPrint('[LOCATION] ✅ Starting active polling tracker for uid=$uid');

    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
    }

    // Do an immediate first push
    await _pollAndPush(uid);

    // Then poll every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollAndPush(uid);
    });
  }

  /// Poll current position and push to Firestore
  Future<void> _pollAndPush(String uid) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('[LOCATION] 📍 Polled: (${position.latitude}, ${position.longitude})');

      // Only push if location actually changed (avoid flooding Firestore)
      if (_lastLat != position.latitude || _lastLng != position.longitude) {
        _lastLat = position.latitude;
        _lastLng = position.longitude;
        await _updateFirestore(uid, position);
        debugPrint('[LOCATION] 🔥 Pushed to Firestore: (${position.latitude}, ${position.longitude})');
      } else {
        debugPrint('[LOCATION] ⏸️ Same location, skipping Firestore push');
      }
    } catch (e) {
      debugPrint('[LOCATION] ❌ Poll error: $e');
    }
  }

  /// Stops tracking location
  void stopTracking(String uid) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isTracking = false;
    _lastLat = null;
    _lastLng = null;

    debugPrint('[LOCATION] 🛑 Tracking stopped for uid=$uid');

    // Mark as offline
    _firestore.collection('collectorLocations').doc(uid).update({
      'status': 'offline',
      'lastUpdated': FieldValue.serverTimestamp(),
    }).catchError((e) => debugPrint('Error updating offline status: $e'));
  }

  Future<void> _updateFirestore(String uid, Position position) async {
    try {
      await _firestore.collection('collectorLocations').doc(uid).set({
        'uid': uid,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
        'speed': position.speed,
        'status': 'online',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[LOCATION] ❌ Firestore write error: $e');
    }
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000;
  }

  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
