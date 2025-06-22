import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:earthquake_notification_filtering/views/pages/beranda/beranda.dart';
import 'package:earthquake_notification_filtering/main.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          titleWidget: const Text(
            "Terdapat perubahan perizinan",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          bodyWidget: const Text(
            "Aplikasi tidak dapat berjalan secara optimal.",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          image: const Icon(
            Icons.warning_amber_rounded,
            size: 100,
            color: Colors.black,
          ),
        ),
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
