// lib/main.dart

import 'dart:io';
import 'dart:convert'; // Import json for decoding payload
import 'package:earthquake_notification_filtering/controller/fcm_handler.dart';
import 'package:earthquake_notification_filtering/controller/gempa_provider.dart';
import 'package:earthquake_notification_filtering/controller/location_service.dart';
import 'package:earthquake_notification_filtering/views/pages/beranda/beranda.dart';
import 'package:earthquake_notification_filtering/views/pages/guncangan.dart';
import 'package:earthquake_notification_filtering/views/pages/permission.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui';
import 'package:earthquake_notification_filtering/views/themes/color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:earthquake_notification_filtering/views/pages/introscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upgrader/upgrader.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:earthquake_notification_filtering/models/gempa_event.dart'; // Import GempaEvent
import 'package:earthquake_notification_filtering/views/detail_gempa.dart'; // Import DetailGempa

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool _isServiceInitialized = false;

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // Get the initial notification response if the app was launched by one
  final NotificationResponse? initialNotificationResponse = await _checkIfFromNotification();

  if (await _checkLocationPermission()) {
    if (!_isServiceInitialized) {
      await initializeService();
      _isServiceInitialized = true;
    }
  }

  await NotifHandler().initNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationController()),
        ChangeNotifierProvider(create: (_) => GempaProvider()),
      ],
      child: MyApp(
          initialNotificationResponse:
              initialNotificationResponse), // Pass the initial notification response
    ),
  );
}

Future<NotificationResponse?> _checkIfFromNotification() async {
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp == true) {
    // print('App launched from notification: true');
    // print('Notification details: ${notificationAppLaunchDetails?.notificationResponse?.payload}');
    return notificationAppLaunchDetails?.notificationResponse;
  }
  // print('App launched from notification: false');
  return null;
}

Future<bool> _checkLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isGranted) {
    return true;
  }
  return false;
}

Future<bool> _checkBatteryOptimization() async {
  var isDisabled =
      await DisableBatteryOptimization.isBatteryOptimizationDisabled;
  return isDisabled ?? false;
}

Future<bool> _checkRequiredPermissions() async {
  var locationStatus = await Permission.locationAlways.status;
  var isBatteryOptimizationDisabled = await _checkBatteryOptimization();

  return locationStatus.isGranted && isBatteryOptimizationDisabled;
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
      initialNotificationTitle: 'Memantau gempa bumi',
      initialNotificationContent: 'Layanan latar belakang Awas Guncang',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

class MyApp extends StatelessWidget {
  final NotificationResponse? initialNotificationResponse;

  const MyApp({super.key, required this.initialNotificationResponse});

  @override
  Widget build(BuildContext context) {
    const appcastURL = 'https://awas-guncang.hanifk.com/api/appcast.xml';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);
    return MaterialApp(
      title: 'EEWS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: MainColorScheme.colorScheme,
        useMaterial3: true,
        textTheme: GoogleFonts.soraTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      navigatorKey: navigatorKey,
      home: UpgradeAlert(
        upgrader: Upgrader(
            appcastConfig: cfg, dialogStyle: UpgradeDialogStyle.cupertino),
        child: FutureBuilder<bool>(
          future: _checkIfSeenIntro(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (initialNotificationResponse != null) {
              // App launched by a notification, handle routing based on payload
              try {
                final Map<String, dynamic> payload =
                    json.decode(initialNotificationResponse!.payload!);
                if (payload['type'] == 'warning') {
                  final countdown = payload['countdown'] ?? 0;
                  final eventId = payload['eventId'];
                  return Guncangan(
                    initialCountdown: countdown,
                    eventId: eventId,
                  );
                } else {
                  // Handle regular earthquake event notification (assuming it's a GempaEvent)
                  final gempaEvent = GempaEvent.fromJson(payload);
                  return DetailGempa(gempaEvent: gempaEvent);
                }
              } catch (e) {
                // print("Error parsing initial notification payload: $e");
                // Fallback to Beranda if payload parsing fails or payload is malformed
                return const Beranda();
              }
            } else if (snapshot.data == true) {
              return FutureBuilder<bool>(
                future: _checkRequiredPermissions(),
                builder: (context, permissionSnapshot) {
                  if (permissionSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (permissionSnapshot.data == true) {
                    return const Beranda();
                  } else {
                    return const PermissionScreen();
                  }
                },
              );
            } else {
              return const IntroScreen();
            }
          },
        ),
      ),
    );
  }

  Future<bool> _checkIfSeenIntro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seen_intro') ?? false;
  }
}