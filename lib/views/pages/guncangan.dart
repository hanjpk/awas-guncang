import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:earthquake_notification_filtering/controller/location_service.dart';
import 'package:earthquake_notification_filtering/views/pages/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class Guncangan extends StatefulWidget {
  final int initialCountdown;
  final String? eventId;

  const Guncangan({
    super.key,
    required this.initialCountdown,
    required this.eventId,
  });

  @override
  State<Guncangan> createState() => _GuncanganState();
}

class _GuncanganState extends State<Guncangan> {
  final AudioPlayer player = AudioPlayer();
  late LocationController locationController;
  late int countdown;
  late int initialCountdown;
  int distanceText = 0;
  Timer? countdownTimer;
  Timer? colorTimer; // Timer for blinking effect
  Color scaffoldColor = Colors.red; // Initial color
  String? eventId;

  @override
  void initState() {
    super.initState();
    countdown = widget.initialCountdown;
    initialCountdown = widget.initialCountdown;
    eventId = widget.eventId;
    playSound();
    startColorBlinking();
    startCountdownTimer();
  }

  void startColorBlinking() {
    colorTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        scaffoldColor =
            (scaffoldColor == Colors.red) ? Colors.black : Colors.red;
      });
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    colorTimer?.cancel(); // Cancel the color timer
    player.dispose();
    super.dispose();
  }

  void startCountdownTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (countdown > 0) {
          setState(() {
            countdown--;
          });

          if (countdown == 0) {
            timer.cancel();
          }
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve event_id from the message data
    double percent = initialCountdown > 0 ? countdown / initialCountdown : 1.0;

    // Log the event_id retrieved

    return Scaffold(
      backgroundColor: scaffoldColor, // Use the blinking color
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => SystemNavigator.pop(),
        ),
      ),
      body: Column(
        children: [
          // Red warning section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.warning_rounded,
                  //   color: Colors.white,
                  //   size: 64,
                  // ),
                  // SizedBox(height: 20),
                  const Text(
                    "Awas Guncangan!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Anda akan merasakan guncangan gempa bumi, bersiap akan guncangan dalam:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CircularPercentIndicator(
                    radius: 60,
                    lineWidth: 8,
                    percent: percent,
                    progressColor: Colors.white,
                    backgroundColor: Colors.grey.shade300,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$countdown',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'detik',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // White section with actions
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 246, 246, 246),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionItem("Merunduk", "assets/images/drop.png"),
                  _buildActionItem("Berlindung", "assets/images/cover.png"),
                  _buildActionItem("Bertahan", "assets/images/hold.png"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FeedbackPage(eventId: eventId)),
                      );
                    },
                    child: const Text("Bagikan pengalaman Anda"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, String iconPath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Image.asset(iconPath),
        ),
      ],
    );
  }

  Future<void> playSound() async {
    String audioPath = "audio/notif.mp3";
    await player.play(AssetSource(audioPath));
  }
}

// class ShelterMap extends StatelessWidget {
//   final double destLatitude;
//   final double destLongitude;

//   const ShelterMap({
//     super.key,
//     required this.destLatitude,
//     required this.destLongitude,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Shelter Map'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(destLatitude, destLongitude),
//           zoom: 14,
//         ),
//         markers: {
//           Marker(
//             markerId: const MarkerId('shelter'),
//             position: LatLng(destLatitude, destLongitude),
//           ),
//         },
//       ),
//     );
//   }
// }
