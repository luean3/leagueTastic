import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class StravaMapWidget extends StatefulWidget {
  final String encodedPolyline;

  const StravaMapWidget({Key? key, required this.encodedPolyline}) : super(key: key);

  @override
  State<StravaMapWidget> createState() => _StravaMapWidgetState();
}

class _StravaMapWidgetState extends State<StravaMapWidget> {
  List<LatLng> routePoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _decodePolyline();
  }

  void _decodePolyline() {
    // 1. Initialize the decoder
    PolylinePoints polylinePoints = PolylinePoints();

    // 2. Decode the string
    List<PointLatLng> result = polylinePoints.decodePolyline(widget.encodedPolyline);

    // 3. Convert flutter_polyline_points to latlong2 LatLng objects
    if (result.isNotEmpty) {
      routePoints = result.map((PointLatLng point) {
        return LatLng(point.latitude, point.longitude);
      }).toList();
    }

    // 4. Update state to stop loading
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (routePoints.isEmpty) {
      return const Center(child: Text("No GPS data for this activity."));
    }

    // Calculate the camera bounds to fit the entire route
    final bounds = LatLngBounds.fromPoints(routePoints);

    return FlutterMap(
      options: MapOptions(
        // Auto-zoom and pan to fit the route with some padding
        initialCameraFit: CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(32.0),
        ),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all, // Enables pan, zoom, rotate
        ),
      ),
      children: [
        // The OpenStreetMap Map Tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yourschoolproject.app', // Best practice for OSM
        ),
        // The Strava Route Line
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              strokeWidth: 4.0,
              color: Colors.blueAccent,
            ),
          ],
        ),
        // Start and End Markers
        MarkerLayer(
          markers: [
            // Start Marker (Green Play)
            Marker(
              point: routePoints.first,
              width: 40,
              height: 40,
              child: const Icon(Icons.play_circle_fill, color: Colors.green, size: 30),
            ),
            // End Marker (Red Flag)
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