import 'value_parser.dart';

/// Einheitlicher Zugriff auf Segment-Felder mit alten und neuen Key-Namen.
class SegmentFields {
  const SegmentFields._();

  static String id(Map<String, dynamic> segment) {
    return ValueParser.string(
      segment['segmentId'] ?? segment['id'] ?? segment['stravaSegmentId'],
    );
  }

  static String name(Map<String, dynamic> segment, {String fallback = ''}) {
    final name = ValueParser.string(segment['name']);
    return name.isNotEmpty ? name : fallback;
  }

  static String polyline(Map<String, dynamic> segment) {
    final segmentMap = segment['map'] is Map
        ? Map<String, dynamic>.from(segment['map'] as Map)
        : <String, dynamic>{};

    return ValueParser.string(
      segment['polyline'] ??
          segment['mapPolyline'] ??
          segment['encodedPolyline'] ??
          segment['polylineString'] ??
          segment['summaryPolyline'] ??
          segment['summary_polyline'] ??
          segmentMap['polyline'] ??
          segmentMap['summary_polyline'],
    );
  }
}
