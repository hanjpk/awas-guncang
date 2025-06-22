import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:earthquake_notification_filtering/views/components/blowing_circle.dart';

class Tentang extends StatefulWidget {
  const Tentang({super.key});

  @override
  State<Tentang> createState() => _TentangState();
}

class _TentangState extends State<Tentang> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Center(
                child: BlowingCircle(color: Colors.red, size: Size(50, 50))),
            const SizedBox(height: 70),
            const Text(
              'Awas Guncang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Versi $appVersion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Aplikasi ini membantu Anda untuk memfilter dan mengelola notifikasi gempa bumi berdasarkan kriteria yang Anda tentukan. Dengan aplikasi ini, Anda dapat:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.warning_rounded),
                    title: Text('Menerima peringatan dini gempa bumi'),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications_active),
                    title: Text('Menerima notifikasi gempa bumi'),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Mengatur preferensi notifikasi'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Dikembangkan dengan ❤️ untuk Indonesia.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _launchUrl('https://awas-guncang.hanifk.com'),
                  icon: const Icon(Icons.code),
                  label: const Text('Kunjungi Situs'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Debug Info'),
                        content: FutureBuilder<String>(
                          future: Future.wait([
                            FirebaseMessaging.instance.getToken(),
                            DeviceInfoPlugin()
                                .androidInfo
                                .then((info) => info.id)
                          ]).then((results) => '${results[0]}&${results[1]}'),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SelectableText(
                                snapshot.data!,
                                style: const TextStyle(fontFamily: 'monospace'),
                              );
                            }
                            return const CircularProgressIndicator();
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.bug_report_outlined),
                  label: const Text('Debug Info'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
