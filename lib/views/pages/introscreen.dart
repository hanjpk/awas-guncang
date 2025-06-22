import 'package:earthquake_notification_filtering/views/components/blowing_circle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:earthquake_notification_filtering/views/pages/beranda/beranda.dart';
import 'package:earthquake_notification_filtering/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';

Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'name': build.name,
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    'systemFeatures': build.systemFeatures,
    'serialNumber': build.serialNumber,
  };
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          titleWidget: const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 40, right: 16),
            child: Text(
              "Izinkan Akses Lokasi",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const Text(
                  "Perizinan lokasi sangat penting agar aplikasi dapat menghitung jarak antara pengguna dan pusat gempa. Data ini digunakan untuk menentukan apakah notifikasi peringatan dini akan dikeluarkan atau tidak.",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Request location permission
                        var status =
                            await Permission.locationWhenInUse.request();
                        if (status.isGranted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Terima kasih perizinan lokasi sudah sesuai'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perizinan lokasi ditolak'),
                            ),
                          );
                        }
                      },
                      child: const Text("Izinkan"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Action to navigate to more information
                      },
                      child: const Text("Pelajari lebih lanjut"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        PageViewModel(
          titleWidget: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(
                  "Ubah Perizinan Lokasi ke \"Selalu Izinkan\"",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const Text(
                  "Aplikasi perlu berjalan di latar belakang untuk selalu memberikan notifikasi peringatan dini gempa bumi.",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Request location permission
                        var status =
                            await Permission.locationWhenInUse.request();
                        if (status.isGranted) {
                          var alwaysStatus =
                              await Permission.locationAlways.request();
                          if (alwaysStatus.isGranted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Terima kasih perizinan lokasi sudah sesuai'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Perizinan lokasi ditolak'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perizinan lokasi ditolak'),
                            ),
                          );
                        }
                      },
                      child: const Text("Izinkan"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Action to navigate to more information
                      },
                      child: const Text("Pelajari lebih lanjut"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        PageViewModel(
          titleWidget: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(
                  "Nonaktifkan Optimasi Baterai",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const Text(
                  "Aplikasi perlu berjalan di latar belakang tanpa optimasi baterai untuk selalu memberikan notifikasi peringatan dini gempa bumi.",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Show battery optimization settings
                        await DisableBatteryOptimization
                            .showDisableBatteryOptimizationSettings();
                        // Check if battery optimization is disabled after returning
                        var isDisabled = await DisableBatteryOptimization
                            .isBatteryOptimizationDisabled;
                        if (isDisabled == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Optimasi baterai berhasil dinonaktifkan'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Optimasi baterai masih aktif'),
                            ),
                          );
                        }
                      },
                      child: const Text("Nonaktifkan"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Action to navigate to more information
                      },
                      child: const Text("Pelajari lebih lanjut"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        PageViewModel(
          titleWidget: const Text(
            "Awas Guncang",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          bodyWidget: const Column(
            children: [
              Text(
                "Prototipe aplikasi peringatan dini gempa bumi Indonesia",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Dikaji oleh STMKG",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          image: const Center(
              child: BlowingCircle(color: Colors.red, size: Size(50, 50))),
        ),
      ],
      showSkipButton: false,
      showBackButton: true,
      back: const Text("Kembali"),
      next: const Text("Selanjutnya"),
      done: const Text("Mulai"),
      onDone: () async {
        var alwaysStatus = await Permission.locationAlways.request();
        var isBatteryOptimizationDisabled =
            await DisableBatteryOptimization.isBatteryOptimizationDisabled;

        if (alwaysStatus.isGranted && isBatteryOptimizationDisabled == true) {
          await Firebase.initializeApp();
          String deviceId = (await DeviceInfoPlugin().androidInfo).id;
          await FirebaseFirestore.instance
              .collection('alphatest')
              .doc(deviceId)
              .set({
            'device_info':
                _readAndroidBuildData(await DeviceInfoPlugin().androidInfo),
            'registered_at': FieldValue.serverTimestamp(),
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('seen_intro', true);
          await initializeService();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Beranda()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Perizinan lokasi atau optimasi baterai belum diizinkan. Silakan kembali ke tahap sebelumnya.'),
            ),
          );
        }
      },
    );
  }
}
