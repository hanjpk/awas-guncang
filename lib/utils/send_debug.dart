import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:device_info_plus/device_info_plus.dart';

void sendDebug(String eventId, double pga, LatLng location) async {
  String deviceId = (await DeviceInfoPlugin().androidInfo).id;
  try {
    await FirebaseFirestore.instance
        .collection('alphatest')
        .doc(deviceId)
        .collection('debugs')
        .doc(eventId)
        .set({
      'event_id': eventId,
      'pga': pga,
      'lokasi': {
        'latitude': location.latitude,
        'longitude': location.longitude
      },
      'timestamp': FieldValue.serverTimestamp(),
    });
    // print('Debug sent successfully');
  } catch (e) {
    // print('Error sending debug: $e');
  }
}
