import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double durationMinutes; // real ETA from OSRM
  final double distanceKm;

  RouteResult({required this.points, required this.durationMinutes, required this.distanceKm});

  static RouteResult empty() => RouteResult(points: [], durationMinutes: 0, distanceKm: 0);
}

class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Fetches a route between two points using OSRM — returns points + real ETA
  static Future<RouteResult> getRouteWithETA(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&overview=full');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'];

        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;
          final double durationSec = (route['duration'] ?? 0).toDouble();
          final double distanceM = (route['distance'] ?? 0).toDouble();

          List<LatLng> routePoints = [];
          for (var coord in coordinates) {
            routePoints.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
          }

          return RouteResult(
            points: routePoints,
            durationMinutes: (durationSec / 60).ceilToDouble(),
            distanceKm: distanceM / 1000,
          );
        }
      }
    } catch (e) {
      print('OSRM Routing Error: $e');
    }
    return RouteResult.empty();
  }

  /// Legacy method — returns just points (for backward compatibility)
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final result = await getRouteWithETA(start, end);
    return result.points;
  }
}
