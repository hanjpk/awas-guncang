import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationController with ChangeNotifier {
  final Location locationController = Location();
  LatLng? currentPosition;
  StreamSubscription<LocationData>? _locationSubscription;

  // Method to start fetching location updates
  Future<void> startFetchingLocation() async {
    if (_locationSubscription == null) {
      await fetchLocationUpdates();
    }
  }

  // Method to stop fetching location updates
  void stopFetchingLocation() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription =
        locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        currentPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        notifyListeners(); // Notify listeners about the change
      }
    });
  }
}
