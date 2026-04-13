import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _baseUrl = 'http://router.project-osrm.org/route/v1/driving';

  /// Fetches a route between two points using OSRM
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'];

        if (routes != null && routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          List<LatLng> routePoints = [];
          for (var coord in coordinates) {
            // OSRM returns [longitude, latitude]
            routePoints.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
          }
          return routePoints;
        }
      }
    } catch (e) {
      print('OSRM Routing Error: $e');
    }
    // Return empty list on failure
    return [];
  }
}
