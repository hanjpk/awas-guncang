import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:earthquake_notification_filtering/controller/location_service.dart';

Widget makeMap() {
  return Transform.translate(
    offset: const Offset(0, -100),
    child: Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(33, 0, 0, 0),
            blurRadius: 20,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Consumer<LocationController>(
          // Added Consumer to access LocationController
          builder: (context, locationController, child) {
            if (locationController.currentPosition == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(6.1750, 106.8283),
                initialZoom: 3,
              ),
              children: [
                TileLayer(
                  urlTemplate: dotenv.env['ARCGISMAP'] ?? '',
                ),
                MarkerLayer(
                  // Added MarkerLayer to display markers
                  markers: [
                    Marker(
                        point: LatLng(
                          locationController.currentPosition!.latitude,
                          locationController.currentPosition!.longitude,
                        ),
                        child: const Icon(Icons.my_location_rounded,
                            color: Colors.blue, size: 30)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
