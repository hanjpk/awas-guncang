import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';

class LaporkanMasalah extends StatefulWidget {
  const LaporkanMasalah({super.key});

  @override
  State<LaporkanMasalah> createState() => _LaporkanMasalahState();
}

class _LaporkanMasalahState extends State<LaporkanMasalah> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIssueType = 'Bug';
  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'Bug',
    'Feature Request',
    'UI/UX Issue',
    'Performance Issue',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Ensure Firebase is initialized
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }

        // Get app version information
        final packageInfo = await PackageInfo.fromPlatform();
        String deviceId = (await DeviceInfoPlugin().androidInfo).id;

        print('Device ID: $deviceId'); // Debug print

        // Create report data
        final reportData = {
          'deviceId': deviceId,
          'name': _nameController.text,
          'email': _emailController.text,
          'issueType': _selectedIssueType,
          'description': _descriptionController.text,
          'appVersion': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending', // pending, in-progress, resolved
        };

        print('Attempting to store report data...'); // Debug print

        // Store in Firestore
        await FirebaseFirestore.instance
            .collection('alphatest')
            .doc(deviceId)
            .collection('report')
            .add(reportData);

        print('Report data stored successfully'); // Debug print

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan berhasil dikirim!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e, stackTrace) {
        print('Error submitting report: $e'); // Debug print
        print('Stack trace: $stackTrace'); // Debug print

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim laporan: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporkan Masalah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan nama Anda';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan email Anda';
                  }
                  if (!value.contains('@')) {
                    return 'Mohon masukkan email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIssueType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Masalah',
                  border: OutlineInputBorder(),
                ),
                items: _issueTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedIssueType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Masalah',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon jelaskan masalah Anda';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Kirim Laporan',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
