import 'package:device_info_plus/device_info_plus.dart';
import 'package:earthquake_notification_filtering/views/components/blowing_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:location/location.dart';

class FeedbackPage extends StatefulWidget {
  final String? eventId;

  const FeedbackPage({super.key, this.eventId});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _currentQuestionIndex = 0; // Track the current question index
  final List<String> _questions = [
    'Seberapa parah gempa menurut anda?',
    'Apakah anda merasa aman?',
  ];
  double _sliderValue = 0; // Default value
  LatLng? _markerPosition; // Variable to store the marker position
  LocationData? _currentLocation;
  final Location _location = Location();
  String? _eventId; // Add this variable to store eventId

  // Initial position for the map
  static const LatLng _initialPosition =
      LatLng(-6.200000, 106.816666); // Example: Jakarta coordinates

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Get eventId from RouteSettings if widget.eventId is null
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        setState(() {
          _eventId = args;
        });
      } else {
        setState(() {
          _eventId = widget.eventId;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _currentLocation = locationData;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Stack(
        // Use Stack to overlay buttons on the map
        children: [
          // Display the Flutter map or slider based on the current question index
          if (_currentQuestionIndex == 0) // Show the map for the first question
            Column(
              children: [
                const Padding(
                  padding:
                      EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Text(
                    'Di mana lokasi Anda berada saat guncangan terjadi? Ketuk pada peta untuk menandai.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: _currentLocation != null
                          ? () async {
                              await _getCurrentLocation(); // Refresh location
                              if (_currentLocation != null) {
                                setState(() {
                                  _markerPosition = LatLng(
                                    _currentLocation!.latitude!,
                                    _currentLocation!.longitude!,
                                  );
                                });
                                debugPrint(
                                    'Location set to: ${_markerPosition?.latitude}, ${_markerPosition?.longitude}');
                              }
                            }
                          : null,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Gunakan Lokasi Saat Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _currentLocation != null
                          ? LatLng(_currentLocation!.latitude!,
                              _currentLocation!.longitude!)
                          : _initialPosition,
                      initialZoom: 10.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _markerPosition = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: dotenv.env['ARCGISMAP'] ??
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      CurrentLocationLayer(),
                      if (_markerPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _markerPosition!,
                              child: const Center(
                                child: BlowingCircle(
                                  color: Colors.red,
                                  size: Size(20, 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            )
          else if (_currentQuestionIndex ==
              1) // Show the slider for the second question
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Text(
                    'Berdasarkan deskripsi berikut, seberapa parah guncangan di lokasi Anda?',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20), // Space between question and slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: Colors.red, // Customize thumb color
                          activeTrackColor: Colors.red,
                          inactiveTrackColor:
                              const Color.fromARGB(255, 232, 232, 232),
                          showValueIndicator:
                              ShowValueIndicator.never, // Hide value indicator
                        ),
                        child: Slider(
                          value: _sliderValue,
                          onChanged: _handleSliderChange,
                          min: 0,
                          max: 4,
                          divisions: 4, // Remove divisions
                        ),
                      ),
                      // Add description below the slider
                      Text(
                        _getIntensityValue(
                            _sliderValue), // Get description based on slider value
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                          height: 20), // Space between question and slider
                      Text(
                        _getIntensityDescription(
                            _sliderValue), // Get description based on slider value
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          // Floating buttons
          Positioned(
            left: 16.0,
            bottom: 16.0,
            child: Visibility(
              visible: _currentQuestionIndex >
                  0, // Show only if not on the first question
              child: ElevatedButton(
                onPressed: () {
                  _previousQuestion(); // Move to the previous question
                },
                child: const Text('Previous'),
              ),
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: ElevatedButton(
              onPressed: () {
                _nextQuestion(); // Move to the next question
              },
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitFeedback() async {
    // Log the event_id before submitting
    String deviceId = (await DeviceInfoPlugin().androidInfo).id;

    // Debug print to check location before submission
    debugPrint(
        'Submitting feedback with location: ${_markerPosition?.latitude}, ${_markerPosition?.longitude}');
    debugPrint(
        'Submitting feedback with eventId: ${_eventId ?? widget.eventId}');

    // Create a feedback document
    await FirebaseFirestore.instance
        .collection('alphatest')
        .doc(deviceId)
        .collection('feedback')
        .add({
      'event_id': _eventId ?? widget.eventId,
      'mmi': _sliderValue,
      'lokasi': _markerPosition != null
          ? {
              'latitude': _markerPosition!.latitude,
              'longitude': _markerPosition!.longitude
            }
          : null,
      'timestamp': FieldValue.serverTimestamp(),
      'deviceId': deviceId,
    });
    // Close the activity after submitting
    Navigator.pop(context);
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++; // Increment question index
      } else {
        _submitFeedback(); // Submit feedback when done
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (_currentQuestionIndex > 0) {
        _currentQuestionIndex--; // Decrement question index
      }
    });
  }

  void _handleSliderChange(double value) {
    setState(() {
      _sliderValue = value; // Update slider value
    });
  }

  String _getIntensityValue(double value) {
    if (value == 0) {
      return 'I - II MMI  Tidak Terasa'; // Not felt
    } else if (value <= 1) {
      return 'III - V MMI  Sedikit Terasa'; // Light
    } else if (value <= 2) {
      return 'VI MMI  Kerusakan Ringan'; // Moderate
    } else if (value <= 3) {
      return 'VII - VIII MMI  Kerusakan Sedang'; // Strong
    } else {
      return 'IX - XII MMI  Kerusakan Berat'; // Very Strong
    }
  }

  String _getIntensityDescription(double value) {
    if (value == 0) {
      return 'Getaran tidak dirasakan kecuali dalam keadaan luarbiasa oleh beberapa orang'; // Not felt
    } else if (value <= 1) {
      return 'Dirasakan oleh orang banyak, tetapi tidak menimbulkan kerusakan. Benda-benda ringan yang digantung bergoyang dan jendela kaca bergetar'; // Light
    } else if (value <= 2) {
      return 'Bagian non struktur bangunan mengalami kerusakan ringan, seperti retak rambut pada dinding, genteng bergeser ke bawah dan sebagian berjatuhan'; // Moderate
    } else if (value <= 3) {
      return 'Banyak retakan terjadi pada dinding bangunan sederhana, sebagian roboh, kaca pecah. Sebagian plester dinding lepas. Hampir sebagian besar genteng bergeser ke bawah atau jatuh. Struktur bangunan mengalami kerusakan ringan sampai sedang.'; // Strong
    } else {
      return 'Tidak dapat berdiri maupun berjalan, sebagain besar dinding permanen roboh. Struktur bangunan mengalami kerusakan berat. Jalan rusak parah, rel kereta dan jembatan bisa hancur.'; // Very Strong
    }
  }
}
