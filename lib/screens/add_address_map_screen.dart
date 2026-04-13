import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class AddAddressMapScreen extends StatefulWidget {
  const AddAddressMapScreen({super.key});

  @override
  State<AddAddressMapScreen> createState() => _AddAddressMapScreenState();
}

class _AddAddressMapScreenState extends State<AddAddressMapScreen> {
  final MapController _mapController = MapController();
  final FirestoreService _firestoreService = FirestoreService();
  
  final TextEditingController _landmarkController = TextEditingController();
  
  bool _isLoading = true;
  bool _isMoving = false;
  LatLng _currentCenter = const LatLng(12.9716, 77.5946); // Default: Bangalore
  String _currentAddress = 'Fetching location...';
  String _selectedLabel = 'Home';
  
  final List<String> _labels = ['Home', 'Office', 'Other'];

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _initCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _currentCenter = latLng;
          _isLoading = false;
        });
        
        // Wait for map to be ready before moving
        _mapController.move(latLng, 16.0);
        await _updateAddressFromLatLng(latLng);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        await _updateAddressFromLatLng(_currentCenter);
      }
    }
  }

  Future<void> _updateAddressFromLatLng(LatLng pos) async {
    try {
      if (!mounted) return;
      setState(() => _currentAddress = 'Fetching address...');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude, pos.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode
        ].where((e) => e != null && e.isNotEmpty).toList();
        
        if (mounted) {
          setState(() {
            _currentAddress = parts.join(', ');
            if (_currentAddress.isEmpty) {
              _currentAddress = 'Location selected';
            }
          });
        }
      } else {
        if (mounted) setState(() => _currentAddress = 'Unknown location');
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = 'Could not fetch address');
    }
  }

  Future<void> _saveAddress() async {
    if (_currentAddress.isEmpty || _currentAddress.startsWith('Fetching')) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      await _firestoreService.saveAddress(
        label: _selectedLabel,
        address: _currentAddress,
        latitude: _currentCenter.latitude,
        longitude: _currentCenter.longitude,
        landmark: _landmarkController.text.trim(),
        isDefault: true, // we set new ones as default to make UX nice
      );

      if (mounted) {
        Navigator.pop(context); // close dialog
        Navigator.pop(context, true); // return success
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e')),
        );
      }
    }
  }

  void _onMapPositionChanged(MapCamera position, bool hasGesture) {
    setState(() {
      _currentCenter = position.center;
      _isMoving = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery Address'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. The Map
          if (!_isLoading)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 16.0,
                onPositionChanged: _onMapPositionChanged,
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd) {
                    setState(() => _isMoving = false);
                    _updateAddressFromLatLng(_currentCenter);
                  }
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.binnit.user',
                ),
              ],
            ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),

          // 2. Center Static Pin (It bounces slightly when moving)
          if (!_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0), // Offset so pin tip points to exact center
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _isMoving ? -15 : 0, 0),
                  child: const Icon(
                    Icons.location_on,
                    size: 50,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ),
            
          // Floating targeting icon
          if (!_isLoading)
            Positioned(
              right: 16,
              bottom: 300,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryGreen,
                child: const Icon(Icons.my_location),
                onPressed: () => _initCurrentLocation(),
              ),
            ),

          // 3. Bottom Action Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Address Text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Location',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentAddress,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Tags (Home, Office, Other)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _labels.map((lbl) {
                        final isSelected = _selectedLabel == lbl;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(lbl),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedLabel = lbl);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Landmark
                  TextField(
                    controller: _landmarkController,
                    decoration: InputDecoration(
                      hintText: 'House/Flat No, Landmark (Optional)',
                      hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      filled: true,
                      fillColor: AppTheme.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                     onPressed: _isMoving ? null : () async { await _saveAddress(); },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Address',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
