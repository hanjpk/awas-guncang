import 'package:flutter/material.dart';
import 'package:earthquake_notification_filtering/models/gempa_event.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:provider/provider.dart';
import 'package:earthquake_notification_filtering/controller/location_service.dart';
import 'package:earthquake_notification_filtering/views/components/blowing_circle.dart';
import 'package:flutter/cupertino.dart';

class DetailGempa extends StatefulWidget {
  final GempaEvent gempaEvent;

  const DetailGempa({
    required this.gempaEvent,
    super.key,
  });

  @override
  State<DetailGempa> createState() => _DetailGempaState();
}

class _DetailGempaState extends State<DetailGempa> {
  final MapController _mapController = MapController();
  LocationController? locationController;
  final latlong.Distance _distance = const latlong.Distance();
  String? _distanceText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locationController =
        Provider.of<LocationController>(context, listen: false);
    _calculateDistance();
  }

  void _calculateDistance() {
    if (locationController?.currentPosition != null) {
      final userLatLng = latlong.LatLng(
        locationController!.currentPosition!.latitude,
        locationController!.currentPosition!.longitude,
      );
      final eventLatLng = latlong.LatLng(
        double.parse(widget.gempaEvent.lintang),
        double.parse(widget.gempaEvent.bujur),
      );

      final distanceInMeters = _distance.as(
        latlong.LengthUnit.Meter,
        userLatLng,
        eventLatLng,
      );

      setState(() {
        if (distanceInMeters < 1000) {
          _distanceText = '${distanceInMeters.toStringAsFixed(0)} meter';
        } else {
          _distanceText = '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
        }
      });
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = double.parse(widget.gempaEvent.lintang);
    final lng = double.parse(widget.gempaEvent.bujur);
    final magnitude = double.parse(widget.gempaEvent.mag);

    Color iconColor;
    if (magnitude < 3) {
      iconColor = const Color.fromARGB(255, 227, 227, 92);
    } else if (magnitude >= 3 && magnitude <= 5) {
      iconColor = const Color.fromARGB(255, 243, 165, 76);
    } else {
      iconColor = const Color.fromARGB(255, 227, 101, 92);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Gempa'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: latlong.LatLng(lat, lng),
                initialZoom: 4.0,
                onMapReady: () {
                  _mapController.move(latlong.LatLng(lat, lng), 4.0);
                  // Force tile loading by moving the map slightly
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _mapController.move(
                      latlong.LatLng(lat + 0.0001, lng + 0.0001),
                      4.0,
                    );
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: dotenv.get("ARCGISMAP"),
                  tileProvider: NetworkTileProvider(),
                  userAgentPackageName:
                      'com.example.earthquake_notification_filtering',
                  maxZoom: 19,
                  minZoom: 1,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlong.LatLng(lat, lng),
                      width: 15,
                      height: 15,
                      child: BlowingCircle(
                        color: iconColor,
                        size: const Size(15, 15),
                      ),
                    ),
                  ],
                ),
                CurrentLocationLayer(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor,
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.5),
                            blurRadius: 0,
                            spreadRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                          BoxShadow(
                            color: iconColor.withOpacity(0.3),
                            blurRadius: 0,
                            spreadRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.gempaEvent.mag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.gempaEvent.area,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.gempaEvent.waktu,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  CupertinoIcons.location_solid,
                  'Koordinat',
                  '${widget.gempaEvent.lintang}, ${widget.gempaEvent.bujur}',
                ),
                _buildDetailRow(
                  CupertinoIcons.arrow_down_circle_fill,
                  'Kedalaman',
                  '${widget.gempaEvent.dalam} KM',
                ),
                if (_distanceText != null)
                  _buildDetailRow(
                    CupertinoIcons.location_fill,
                    'Jarak dari lokasi Anda',
                    _distanceText!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
