import 'dart:async';

import 'package:earthquake_notification_filtering/views/pages/pengaturan/demo_guncangan.dart';
import 'package:earthquake_notification_filtering/views/pages/pengaturan/laporan.dart';
import 'package:earthquake_notification_filtering/views/pages/pengaturan/tentang.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:earthquake_notification_filtering/views/pages/pengaturan/notifications.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  // const _AnimatedSurveyMenuItem(
                  //   icon: Icons.assignment_outlined, // A suitable icon for survey
                  //   title: "Isi Survei Pengguna",
                  //   url: 'https://s.id/awaskuis',
                  // ),
                  _buildSettingTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi Gempa Bumi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSetting(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    context,
                    icon: Icons.close_rounded,
                    title: 'Putar Demo Peringatan Dini',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text(
                                'Pastikan Anda tidak di tempat umum atau kecilkan volume ponsel Anda.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DemoGuncangan(),
                                    ),
                                  );
                                },
                                child: const Text('Ya'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Privasi',
                    onTap: () async {
                      const url = 'https://awas-guncang.hanifk.com/privasi';
                      if (!await launchUrl(Uri.parse(url))) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Tidak dapat membuka halaman')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                    onTap: () async {
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
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'Tentang',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Tentang(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    context,
                    icon: Icons.report_problem_outlined,
                    title: 'Laporkan Masalah',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LaporkanMasalah(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              strokeAlign: BorderSide.strokeAlignCenter,
              color: Color(0xFFEAEAEA),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSurveyMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String url;

  const _AnimatedSurveyMenuItem({
    required this.icon,
    required this.title,
    required this.url,
  });

  @override
  State<_AnimatedSurveyMenuItem> createState() => _AnimatedSurveyMenuItemState();
}

class _AnimatedSurveyMenuItemState extends State<_AnimatedSurveyMenuItem> {
  Timer? _timer;
  bool _isGlowing = false; // To control the animation state

  @override
  void initState() {
    super.initState();
    // Start the glowing animation
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { // Adjusted timing for a more subtle glow
      if (mounted) {
        setState(() {
          _isGlowing = !_isGlowing;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(widget.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Optional: Add error handling like a SnackBar if the URL can't be launched
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Could not launch ${widget.url}')),
      // );
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500), // Animation duration for glow
        curve: Curves.easeInOut, // Smooth animation curve
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: _isGlowing ? 1.0 : 1.0, // Thicker border when glowing
              strokeAlign: BorderSide.strokeAlignCenter,
              color: _isGlowing ? Colors.redAccent  : const Color(0xFFEAEAEA), // Blue glow color, then back to grey
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: [
            if (_isGlowing)
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.4), // Matching glow shadow
                blurRadius: 10.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 0), // Centered shadow
              ),
            BoxShadow( // Default shadow for all states
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 24, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 20, color: Colors.grey), // Indicating external link
          ],
        ),
      ),
    );
  }
}
