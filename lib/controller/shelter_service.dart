// shelter_service.dart
import 'package:geolocator/geolocator.dart';

List<List<dynamic>> shelterList = [
  [
    'Balai Desa Pagubugan Kulon',
    'https://img.icons8.com/color/2x/amazon.png',
    'TES',
    '-7.692874',
    '109.304'
  ],
  [
    'SDN 02 Pagubugan Kulon',
    'https://img.icons8.com/color/2x/amazon.png',
    'TES',
    '-7.68965853',
    '109.308'
  ],
  [
    'SDN 04 Pagubugan Kulon',
    'https://img.icons8.com/color/2x/amazon.png',
    'TES',
    '-7.6887347',
    '109.298'
  ],
];

Future<Map<String, dynamic>> calculateDistance(
    double startLat, double startLon, List<dynamic> shelter) async {
  double distance = Geolocator.distanceBetween(
      startLat, startLon, double.parse(shelter[3]), double.parse(shelter[4]));
  return {
    'shelter': shelter,
    'distance': distance,
  };
}

Future<List<Map<String, dynamic>>> getNearestShelters(
    double currentLat, double currentLon) async {
  List<Future<Map<String, dynamic>>> futures = shelterList
      .map((shelter) => calculateDistance(currentLat, currentLon, shelter))
      .toList();

  List<Map<String, dynamic>> sheltersWithDistances = await Future.wait(futures);

  sheltersWithDistances.sort((a, b) => a['distance'].compareTo(b['distance']));

  return sheltersWithDistances;
}
