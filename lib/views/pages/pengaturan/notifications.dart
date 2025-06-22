import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  double _currentRangeValue = 1;
  LatLng? _circleCenter;
  Set<CircleMarker> _circles = {};
  LatLng _initialMapCenter = const LatLng(-2.5489, 118.0149); // Default center
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _initializeLocation();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentRangeValue = prefs.getDouble('notification_range') ?? 1;
      double? lat = prefs.getDouble('circle_center_lat');
      double? lng = prefs.getDouble('circle_center_lng');
      if (lat != null && lng != null) {
        _circleCenter = LatLng(lat, lng);
        _initialMapCenter = _circleCenter!; // Update initial center
        _updateCircle();
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('notification_range', _currentRangeValue);
    if (_circleCenter != null) {
      await prefs.setDouble('circle_center_lat', _circleCenter!.latitude);
      await prefs.setDouble('circle_center_lng', _circleCenter!.longitude);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan berhasil disimpan'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updateCircle() {
    if (_circleCenter != null) {
      _circles = {
        CircleMarker(
          point: _circleCenter!,
          radius: _currentRangeValue * 1000, // Convert km to meters
          useRadiusInMeter: true, // Use meters instead of pixels
          color: Colors.red.withOpacity(0.2),
          borderStrokeWidth: 1,
          borderColor: Colors.red,
        ),
      };
    } else {
      _circles.clear();
    }
  }

  void _onMapTap(LatLng tappedPoint) {
    setState(() {
      _circleCenter = tappedPoint;
      _updateCircle();
    });
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Lokasi tidak aktif. Mohon aktifkan lokasi di pengaturan perangkat.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin lokasi ditolak'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Izin lokasi ditolak secara permanen. Mohon aktifkan di pengaturan aplikasi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialMapCenter = LatLng(position.latitude, position.longitude);
        _updateCircle();
      });
      _mapController.move(_initialMapCenter, _mapController.camera.zoom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan Notifikasi',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    onTap: (tapPosition, point) {
                      _onMapTap(point);
                    },
                    initialCenter: _initialMapCenter,
                    initialZoom: 5 + (_currentRangeValue / 10),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: dotenv.get("ARCGISMAP"),
                    ),
                    CurrentLocationLayer(
                      style: const LocationMarkerStyle(
                        marker: DefaultLocationMarker(
                          color: Colors.blue,
                          // child: Icon(
                          //   Icons.navigation,
                          //   color: Colors.white,
                          //   size: 14,
                          // ),
                        ),
                        // markerSize: Size(40, 40),
                        markerDirection: MarkerDirection.heading,
                      ),
                    ),
                    CircleLayer(
                      circles: _circles.toList(),
                    ),
                  ],
                ),
                // Positioned(
                //   right: 16,
                //   bottom: 16,
                //   child: FloatingActionButton(
                //     onPressed: _initializeLocation,
                //     child: const Icon(Icons.my_location),
                //   ),
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih rentang radius notifikasi aktif (dalam kilometer)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: Colors.red, // Customize thumb color
                    activeTrackColor: Colors.red,
                    inactiveTrackColor:
                        const Color.fromARGB(255, 232, 232, 232),
                  ),
                  child: Slider(
                    value: _currentRangeValue,
                    min: 1,
                    max: 10000,
                    label: _currentRangeValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentRangeValue = value;
                        _updateCircle();
                      });
                    },
                  ),
                ),
                Text(
                  'Nilai rentang radius: ${_currentRangeValue.round()} km',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Notifikasi gempa bumi berbeda dengan notifikasi peringatan dini. Filter ini tidak akan memengaruhi notifikasi peringatan dini.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        const url = 'https://awas-guncang.hanifk.com/bantuan';
                        if (!await launchUrl(Uri.parse(url))) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Tidak dapat membuka halaman')),
                            );
                          }
                        }
                      },
                      child: const Text('Pelajari lebih lanjut'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
