import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';

/// Zeigt die Strava-Route eines Segments auf einer OpenStreetMap-Karte.
class StravaMapWidget extends StatelessWidget {
  final String encodedPolyline;

  const StravaMapWidget({super.key, required this.encodedPolyline});

  List<LatLng> _decodePolyline(String encodedPolyline) {
    final decodedPoints = PolylinePoints().decodePolyline(encodedPolyline);

    return decodedPoints.map((point) {
      return LatLng(point.latitude, point.longitude);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _decodePolyline(encodedPolyline);

    if (routePoints.isEmpty) {
      return const Center(child: Text("No GPS data for this activity."));
    }

    final bounds = LatLngBounds.fromPoints(routePoints);

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(32),
        ),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.leagueTastic.app',
          tileProvider: CachedTileProvider(
            maxStale: const Duration(days: 30),
            store: MemCacheStore(),
          ),
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              strokeWidth: 4,
              color: Colors.blueAccent,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: routePoints.first,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.play_circle_fill,
                color: Colors.green,
                size: 30,
              ),
            ),
            Marker(
              point: routePoints.last,
              width: 40,
              height: 40,
              child: const Icon(Icons.flag_circle, color: Colors.red, size: 30),
            ),
          ],
        ),
      ],
    );
  }
}
