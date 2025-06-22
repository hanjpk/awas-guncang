import 'dart:async';
import 'dart:convert';
import 'package:earthquake_notification_filtering/utils/iasp91.dart';
import 'package:earthquake_notification_filtering/utils/send_debug.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:earthquake_notification_filtering/utils/pga_zhao2006.dart';
import 'package:earthquake_notification_filtering/main.dart';
import 'package:earthquake_notification_filtering/views/pages/guncangan.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:earthquake_notification_filtering/models/gempa_event.dart';
import 'package:earthquake_notification_filtering/views/detail_gempa.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _handleEventTopic(RemoteMessage message) async {
  // final String eventid = message.data['eventid'];
  final String waktu = message.data['waktu'];
  final String lintang = message.data['lintang'];
  final String bujur = message.data['bujur'];
  final String mag = message.data['mag'];
  final String area = message.data['area'];

  final double latitude = double.parse(lintang);
  final double longitude = double.parse(bujur);

  try {
    // Get saved notification settings
    final prefs = await SharedPreferences.getInstance();
    final double? savedLat = prefs.getDouble('circle_center_lat');
    final double? savedLng = prefs.getDouble('circle_center_lng');
    final double notificationRange = prefs.getDouble('notification_range') ??
        10000.0; // Default to 50km if not set

    // If no location is saved, don't show notification
    if (savedLat == null || savedLng == null) {
      return;
    }

    // Calculate distance between earthquake and saved location
    double distanceInMeters = Geolocator.distanceBetween(
      savedLat,
      savedLng,
      latitude,
      longitude,
    );
    double distanceInKm = distanceInMeters / 1000;

    // Only show notification if earthquake is within the saved range
    if (distanceInKm <= notificationRange) {
      // print("User di rentang");
      _showEventNotification(mag, area, waktu, message);
    } else {
      // print("User di luar rentang");
    }
  } catch (e) {
    // If any error occurs, don't show notification
    return;
  }
}

void _showEventNotification(
    String mag, String area, String waktu, RemoteMessage message) async {
  try {
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // print("Attempting to show notification with ID: $notificationId");

    // Parse UTC time - handle the space in the format
    DateFormat utcFormat = DateFormat("yyyy/MM/dd  HH:mm:ss.SSS");
    DateTime utcTime = utcFormat.parse(waktu);
    // print("Parsed UTC time: $utcTime");

    // Get timezone offset in hours
    int offsetHours = DateTime.now().timeZoneOffset.inHours;
    // print("Timezone offset: $offsetHours hours");

    // Convert to local time by adding the offset
    DateTime localTime = utcTime.add(Duration(hours: offsetHours));
    // print("Converted to local time: $localTime");

    // Determine Indonesian timezone
    String timezone;
    if (offsetHours == 7) {
      timezone = "WIB";
    } else if (offsetHours == 8) {
      timezone = "WITA";
    } else if (offsetHours == 9) {
      timezone = "WIT";
    } else {
      timezone = "UTC+$offsetHours";
    }

    // Format local time for display
    DateFormat localFormat = DateFormat("dd MMMM yyyy HH:mm:ss");
    String formattedLocalTime = "${localFormat.format(localTime)} $timezone";
    // print("Formatted local time: $formattedLocalTime");

    String initialNotificationTitle = "Gempa bumi M$mag di $area";
    String initialNotificationBody =
        "Telah terjadi gempa bumi di $area pada $formattedLocalTime";

    // print(
    // "Notification content - Title: $initialNotificationTitle, Body: $initialNotificationBody");

    // Create GempaEvent object for navigation
    final gempaEvent = GempaEvent(
      eventId: message.data['eventid'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      status: message.data['status'] ?? 'automatic',
      waktu: waktu,
      lintang: message.data['lintang'] ?? '0',
      bujur: message.data['bujur'] ?? '0',
      mag: mag,
      dalam: message.data['dalam'] ?? '0',
      fokal: message.data['fokal'] ?? 'normal',
      area: area,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_channel',
      'Informasi Gempa Bumi',
      channelDescription:
          'Notifikasi untuk informasi peristiwa gempa bumi terbaru di daerah yang diinginkan.',
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: false,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      initialNotificationTitle,
      initialNotificationBody,
      platformChannelSpecifics,
      payload: json.encode(gempaEvent.toJson()),
    );
    // print("Notification shown successfully");
  } catch (e) {
    // print("Error showing notification: $e");
    // print("Problematic time string: $waktu");
  }
}

void _handleInfoTopic(RemoteMessage message) {
  final String judul = message.data['judul'];
  final String pesan = message.data['pesan'];
  String initialNotificationTitle = judul;
  String initialNotificationBody = pesan;

  // Generate a unique ID based on current timestamp
  int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'event_channel',
    'Informasi Gempa Bumi',
    channelDescription:
        'Notifikasi untuk informasi peristiwa gempa bumi terbaru di daerah yang diinginkan.',
    playSound: true,
    // sound: RawResourceAndroidNotificationSound('notif'),
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: false,
    showWhen: true,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(
    notificationId,
    initialNotificationTitle,
    initialNotificationBody,
    platformChannelSpecifics,
    payload: message.data.toString(),
  );
}

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // Ensure Firebase is initialized
  try {
    await Firebase.initializeApp();
    // print('Firebase initialized successfully on Background');
  } catch (e) {
    // print('Error initializing Firebase on Background: $e');
    return; // Exit if Firebase initialization fails
  }

  final String? from = message.from;
  if (from != null && from.startsWith('/topics/')) {
    final topic = from.replaceFirst('/topics/', '');

    if (topic == 'event') {
      _handleEventTopic(message);
    } else if (topic == 'info') {
      _handleInfoTopic(message);
    } else if (topic == 'warning') {
      final String? magnitudeStr = message.data['magnitude'];
      final String? lat = message.data['latitude'];
      final String? lon = message.data['longitude'];
      final String? depthStr = message.data['depth'];
      final String? waktu = message.data['s_time'];
      final String? eventId = message.data['event_id'];

      // print('Received message data: ${message.data}');
      // print('lat: $lat, lon: $lon, depthStr: $depthStr, eventId: $eventId');

      if (lat != null &&
          lon != null &&
          depthStr != null &&
          waktu != null &&
          magnitudeStr != null &&
          eventId != null) {
        final double latitude = double.parse(lat);
        final double longitude = double.parse(lon);
        final double depth = double.parse(depthStr);
        final double magnitude = double.parse(magnitudeStr);

        try {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          // print('User position: ${position.latitude}, ${position.longitude}');

          // Retrieve siteClass from the server
          final response = await http.post(
            Uri.parse('http://203.81.248.137:5000/api/vs30'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "latitude": position.latitude,
              "longitude": position.longitude,
            }),
          );

          double distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            latitude,
            longitude,
          );
          double distanceInKm = distanceInMeters / 1000;

          double mW = magnitude;
          double rRup = distanceInKm;
          double h = depth;
          String mechanism = "interface";

          double timeInSeconds = getIasp91STravelTime(h, distanceInKm);

          DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss.SSS");
          DateTime eventTime = dateFormat.parse(waktu);
          DateTime currentTime = DateTime.now();
          Duration difference = eventTime.difference(currentTime);
          int countdown = timeInSeconds.toInt() + difference.inSeconds;

          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('countdown_seconds', countdown);
          prefs.setString('event_id', eventId);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            int siteClass = data['site_class'];

            double pga = pgaZhao2006(mW, rRup, h,
                siteClass: siteClass, mechanism: mechanism);

            if (pga >= 2.9 && countdown > 0) {
              // print(
              // 'Nilai pga: $pga dan countdown: $countdown melebihi nilai batas yang di set. Pengguna akan di notifikasi');

              // Log the event_id before navigating
              // print('evi Navigating to Guncangan with event_id: $eventId');

              // Open Guncangan page when notification is clicked
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => Guncangan(
                    initialCountdown: countdown,
                    eventId: eventId,
                  ),
                ),
              );

              // Create payload for navigation
              final Map<String, dynamic> warningPayload = {
                'type': 'warning',
                'countdown': countdown,
                'eventId': eventId,
              };

              // Show initial notification
              String initialNotificationTitle = "Awas Guncangan";
              String initialNotificationBody =
                  "Bersiap akan guncangan gempa bumi.";

              const AndroidNotificationDetails androidPlatformChannelSpecifics =
                  AndroidNotificationDetails(
                'peringatan_dini_channel',
                'Peringatan Dini',
                channelDescription:
                    'Notifikasi untuk peringatan dini gempa bumi',
                playSound: true,
                sound: RawResourceAndroidNotificationSound('notif'),
                importance: Importance.max,
                priority: Priority.high,
                fullScreenIntent: true,
                showWhen: true,
              );
              const NotificationDetails platformChannelSpecifics =
                  NotificationDetails(android: androidPlatformChannelSpecifics);

              flutterLocalNotificationsPlugin.show(
                0, // Use the same ID to update the notification
                initialNotificationTitle,
                initialNotificationBody,
                platformChannelSpecifics,
                payload: json.encode(warningPayload),
              );
              sendDebug(
                  eventId, pga, LatLng(position.latitude, position.longitude));
            } else {
              // print(
              //     'Nilai pga: $pga atau $countdown tidak melebihi nilai batas yang di set. Pengguna tidak akan di notifikasi');
            }
          } else {
            // print('Failed to retrieve siteClass: ${response.statusCode}');
            int siteClass = 3;

            double pga = pgaZhao2006(mW, rRup, h,
                siteClass: siteClass, mechanism: mechanism);

            if (pga >= 2.9 && countdown > 0) {
              // print(
              //     'Nilai pga: $pga dan countdown: $countdown melebihi nilai batas yang di set. Pengguna akan di notifikasi');

              // // Log the event_id before navigating
              // print('evi Navigating to Guncangan with event_id: $eventId');

              // Open Guncangan page when notification is clicked
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => Guncangan(
                    initialCountdown: countdown,
                    eventId: eventId,
                  ),
                ),
              );

              // Show initial notification
              String initialNotificationTitle = "Awas Guncangan";
              String initialNotificationBody =
                  "Bersiap akan guncangan gempa bumi.";

              const AndroidNotificationDetails androidPlatformChannelSpecifics =
                  AndroidNotificationDetails(
                'peringatan_dini_channel',
                'Peringatan Dini',
                channelDescription:
                    'Notifikasi untuk peringatan dini gempa bumi',
                playSound: true,
                sound: RawResourceAndroidNotificationSound('notif'),
                importance: Importance.max,
                priority: Priority.high,
                fullScreenIntent: true,
                showWhen: true,
              );
              const NotificationDetails platformChannelSpecifics =
                  NotificationDetails(android: androidPlatformChannelSpecifics);

              flutterLocalNotificationsPlugin.show(
                0, // Use the same ID to update the notification
                initialNotificationTitle,
                initialNotificationBody,
                platformChannelSpecifics,
                payload: message.data.toString(),
              );
              sendDebug(
                  eventId, pga, LatLng(position.latitude, position.longitude));
            } else {
              // print(
              //     'Nilai pga: $pga atau $countdown tidak melebihi nilai batas yang di set. Pengguna tidak akan di notifikasi');
            }
          }
        } catch (e) {
          // print('Error getting location: $e');
        }
      }
    } else {
      // Handle default or unknown topic
    }
  }
}

Future<void> handleActiveMessage(RemoteMessage message) async {
  // print('ActiveMessage: ${message.from}');
  final String? from = message.from;
  if (from != null && from.startsWith('/topics/')) {
    final topic = from.replaceFirst('/topics/', '');
    // print('Topic: $topic');

    if (topic == 'event') {
      _handleEventTopic(message);
    } else if (topic == 'info') {
      _handleInfoTopic(message);
    } else if (topic == 'warning') {
      // print('handleActiveMessage: ${message.from}');
      final String? magnitudeStr = message.data['magnitude'];
      final String? lat = message.data['latitude'];
      final String? lon = message.data['longitude'];
      final String? depthStr = message.data['depth'];
      final String? eventId = message.data['event_id'];
      final String? waktu = message.data['s_time'];
      // print('Received message data: ${message.data}');

      if (lat != null &&
          lon != null &&
          depthStr != null &&
          magnitudeStr != null &&
          eventId != null &&
          waktu != null) {
        final double latitude = double.parse(lat);
        final double longitude = double.parse(lon);
        final double depth = double.parse(depthStr);
        final double magnitude = double.parse(magnitudeStr);

        try {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          // print('User position: ${position.latitude}, ${position.longitude}');

          // Retrieve siteClass from the server
          final response = await http.post(
            Uri.parse('http://203.81.248.137:5000/api/vs30'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "latitude": position.latitude,
              "longitude": position.longitude,
            }),
          );

          double distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            latitude,
            longitude,
          );
          double distanceInKm = distanceInMeters / 1000;

          double mW = magnitude;
          double rRup = distanceInKm;
          double h = depth;
          String mechanism = "interface";

          double timeInSeconds = getIasp91STravelTime(h, distanceInKm);

          DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss.SSS");
          DateTime eventTime = dateFormat.parse(waktu);
          DateTime currentTime = DateTime.now();
          Duration difference = eventTime.difference(currentTime);
          int countdown = timeInSeconds.toInt() + difference.inSeconds;

          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('countdown_seconds', countdown);
          prefs.setString('event_id', eventId);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            int siteClass = data['site_class'];

            double pga = pgaZhao2006(mW, rRup, h,
                siteClass: siteClass, mechanism: mechanism);

            if (pga >= 2.9 && countdown > 0) {
              // print(
              //     'Nilai pga: $pga dan countdown: $countdown melebihi nilai batas yang di set. Pengguna akan di notifikasi');
              // print('evi Navigating to Guncangan with event_id: $eventId');
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => Guncangan(
                    initialCountdown: countdown,
                    eventId: eventId,
                  ),
                ),
              );
              sendDebug(
                  eventId, pga, LatLng(position.latitude, position.longitude));
            } else {
              // print(
              //     'Nilai pga: $pga atau $countdown tidak melebihi nilai batas yang di set. Pengguna tidak akan di notifikasi');
            }
          } else {
            // print('Failed to retrieve siteClass: ${response.statusCode}');
            int siteClass = 3; // Default value if the request fails

            double pga = pgaZhao2006(mW, rRup, h,
                siteClass: siteClass, mechanism: mechanism);

            if (pga >= 2.9 && countdown > 0) {
              // print(
              //     'Nilai pga: $pga dan countdown: $countdown melebihi nilai batas yang di set. Pengguna akan di notifikasi');
              // Log the event_id before navigating
              // print('evi Navigating to Guncangan with event_id: $eventId');
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => Guncangan(
                    initialCountdown: countdown,
                    eventId: eventId,
                  ),
                ),
              );
              sendDebug(
                  eventId, pga, LatLng(position.latitude, position.longitude));
            } else {
              // print(
              //     'Nilai pga: $pga atau $countdown tidak melebihi nilai batas yang di set. Pengguna tidak akan di notifikasi');
            }
          }
        } catch (e) {
          // print('Error getting location: $e');
        }
      }
    } else {
      // Handle default or unknown topic
    }
  }
}

class NotifHandler {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> subscribeToTopics(List<String> topics) async {
    for (String topic in topics) {
      await _firebaseMessaging.subscribeToTopic(topic);
      // print('Subscribed to $topic topic');
    }
  }

  Future<void> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      // print("Notification permissions granted");

      // Get the FCM token
      // final FCMToken = await _firebaseMessaging.getToken();
      // print('FCM Token: $FCMToken');

      // Subscribe to multiple topics
      await subscribeToTopics(['event', 'info', 'warning', 'beta', 'coba']);

      // Listen for messages sent to this token
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // print("Received foreground message: ${message.messageId}");
        handleActiveMessage(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // print("Notification clicked: ${response.payload}");
          if (response.payload != null) {
            try {
              final Map<String, dynamic> payload =
                  json.decode(response.payload!);

              // Check if it's a warning notification
              if (payload['type'] == 'warning') {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => Guncangan(
                      initialCountdown: payload['countdown'],
                      eventId: payload['eventId'],
                    ),
                  ),
                );
              } else {
                // Handle regular earthquake event notification
                final gempaEvent = GempaEvent.fromJson(payload);
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => DetailGempa(gempaEvent: gempaEvent),
                  ),
                );
              }
            } catch (e) {
              // print("Error parsing notification payload: $e");
            }
          }
        },
      );
      // print("Local notifications initialized successfully");
    } catch (e) {
      // print("Error initializing notifications: $e");
    }
  }
}
