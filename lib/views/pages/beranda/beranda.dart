import 'package:earthquake_notification_filtering/views/pages/beranda/map_view.dart';
import 'package:earthquake_notification_filtering/views/pages/beranda/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:earthquake_notification_filtering/controller/location_service.dart';
import 'package:provider/provider.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<LocationController>(context, listen: false)
        .fetchLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: const [MapView(), SettingsView()],
        ),
        bottomNavigationBar: Container(
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFFEAEAEA),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.map), label: 'Jelajah'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings), label: 'Pengaturan')
                    ],
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedItemColor: Theme.of(context).primaryColor,
                    unselectedItemColor: Colors.grey,
                    enableFeedback: false,
                    selectedIconTheme: const IconThemeData(size: 28),
                    unselectedIconTheme: const IconThemeData(size: 24),
                  ),
                ))));
  }
}
