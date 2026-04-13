import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/collector_provider.dart';
import '../../utils/constants.dart';

class SetLocationScreen extends StatefulWidget {
  const SetLocationScreen({super.key});

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  final MapController _mapController = MapController();
  
  bool _isLoading = true;
  bool _isMoving = false;
  bool _isSaving = false;
  LatLng _currentCenter = const LatLng(9.0558, 76.5350); // Karunagapally, Kollam Default
  String _currentAddress = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
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

      Position position = await Geolocator.getCurrentPosition();

      final latLng = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _currentCenter = latLng;
          _isLoading = false;
        });
        
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
            _currentAddress = parts.isNotEmpty ? parts.join(', ') : 'Unknown location';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentAddress = 'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}');
      }
    }
  }

  Future<void> _saveLocation() async {
    FocusScope.of(context).unfocus();
    final provider = Provider.of<CollectorProvider>(context, listen: false);
    final collector = provider.collector;
    
    if (collector == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collector not found. Please relogin.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      // OVERRIDE GPS - Write directly to active collectorLocations table
      await FirebaseFirestore.instance.collection('collectorLocations').doc(collector.id).set({
        'uid': collector.id,
        'latitude': _currentCenter.latitude,
        'longitude': _currentCenter.longitude,
        'status': 'online',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live location manually updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Set Live Location',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentCenter,
                          initialZoom: 16.0,
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture) {
                              setState(() {
                                _isMoving = true;
                                _currentCenter = position.center;
                              });
                            }
                          },
                          onMapEvent: (event) {
                            if (event is MapEventMoveEnd) {
                              setState(() => _isMoving = false);
                              _updateAddressFromLatLng(_currentCenter);
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.cowaste.collector_app',
                          ),
                        ],
                      ),
                      // Center Pin Overlay
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 48,
                            color: _isMoving 
                                ? AppColors.primary.withOpacity(0.5)
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      // Recenter Button
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          heroTag: 'recenter',
                          backgroundColor: Colors.white,
                          onPressed: _initCurrentLocation,
                          child: const Icon(Icons.my_location_rounded, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Marker',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentAddress,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Confirm Current Location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
