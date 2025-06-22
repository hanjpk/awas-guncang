import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeoJsonParser {
  final List<Marker> markers = [];
  final List<Polyline> polylines = [];
  final List<Polygon> polygons = [];

  GeoJsonParser();

  void parseGeoJsonAsString(String g) {
    return parseGeoJson(jsonDecode(g) as Map<String, dynamic>);
  }

  Widget markerIcon() => const Icon(Icons.location_pin, color: Colors.blue);

  void parseGeoJson(Map<String, dynamic> g) {
    final features = g['features'];
    String geometryType;
    features.forEach((f) {
      geometryType = f['geometry']['type'].toString();
      switch (geometryType) {
        case 'Point':
          {
            final coords = f['geometry']['coordinates'] as List;
            markers.add(Marker(
              point: LatLng(coords[1] as double, coords[0] as double),
              width: 10,
              height: 10,
              child: markerIcon(),
            ));
          }
          break;
        case 'LineString':
          {
            final List<LatLng> lineString = [];
            for (final coords in f['geometry']['coordinates'] as List) {
              lineString.add(LatLng(coords[1] as double, coords[0] as double));
            }
            polylines.add(Polyline(
                points: lineString,
                strokeWidth: 1,
                color: const Color.fromARGB(96, 227, 101, 92)));
          }
          break;
        case 'MultiLineString':
          {
            for (final line in f['geometry']['coordinates'] as List) {
              final List<LatLng> lineString = [];
              for (final coords in line as List) {
                lineString
                    .add(LatLng(coords[1] as double, coords[0] as double));
              }
              polylines.add(Polyline(
                  points: lineString, strokeWidth: 3, color: Colors.blue));
            }
          }
          break;
        case 'Polygon':
          {
            final properties = f['properties'] as Map<String, dynamic>;
            final List<LatLng> outerRing = [];
            final List<List<LatLng>> holeList = [];
            int pathIndex = 0;
            for (final path in f['geometry']['coordinates'] as List) {
              final List<LatLng> hole = [];
              for (final coords in path as List<dynamic>) {
                if (pathIndex == 0) {
                  outerRing
                      .add(LatLng(coords[1] as double, coords[0] as double));
                } else {
                  hole.add(LatLng(coords[1] as double, coords[0] as double));
                }
              }
              if (pathIndex > 0) {
                holeList.add(hole);
              }
              pathIndex++;
            }
            polygons.add(Polygon(
                points: outerRing,
                holePointsList: holeList,
                borderColor: Colors.black,
                color: Colors.red,
                borderStrokeWidth: 1,
                labelStyle: const TextStyle(color: Colors.black),
                label: properties['gid'].toString()));
          }
          break;
        case 'MultiPolygon':
          {
            final properties = f['properties'] as Map<String, dynamic>;
            for (final polygon in f['geometry']['coordinates'] as List) {
              final List<LatLng> outerRing = [];
              final List<List<LatLng>> holeList = [];
              int pathIndex = 0;
              for (final path in polygon as List) {
                List<LatLng> hole = [];
                for (final coords in path as List<dynamic>) {
                  if (pathIndex == 0) {
                    outerRing
                        .add(LatLng(coords[1] as double, coords[0] as double));
                  } else {
                    hole.add(LatLng(coords[1] as double, coords[0] as double));
                  }
                }
                if (pathIndex > 0) {
                  holeList.add(hole);
                }
                pathIndex++;
              }
              polygons.add(Polygon(
                  points: outerRing,
                  holePointsList: holeList,
                  borderColor: Colors.black,
                  color: Colors.red,
                  borderStrokeWidth: 1,
                  labelStyle: const TextStyle(color: Colors.black),
                  label: properties['gid'].toString()));
            }
          }
          break;
      }
    });
    return;
  }
}
