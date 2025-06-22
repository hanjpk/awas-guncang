import 'package:earthquake_notification_filtering/controller/location_service.dart';
// import 'package:earthquake_notification_filtering/views/components/google_map_widget.dart';
import 'package:earthquake_notification_filtering/archive/map_widget.dart';
// import 'package:earthquake_notification_filtering/views/components/map_widget.dart';
import 'package:earthquake_notification_filtering/views/components/shelter_widget.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    Provider.of<LocationController>(context, listen: false)
        .fetchLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: 330,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF131313), Color(0xFF313131)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 20, left: 20, right: 20, bottom: 2),
                        child: Text('Lokasi',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Text('Kemayoran',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircularPercentIndicator(
                                radius: 60,
                                lineWidth: 8,
                                percent: 0.4,
                                progressColor: Colors.red,
                                backgroundColor: Colors.red.shade200,
                                circularStrokeCap: CircularStrokeCap.round,
                                center: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('15',
                                          style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      Text('until impact',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white))
                                    ],
                                  ),
                                )),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Waktu',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Text('Mag.',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Text('Dep.',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                                Text('Jarak',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ],
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('09:40:51 WIB',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text('2.9',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text('10 Km',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text('40 Km',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              makeMap(),
              makeInfo()
            ],
          ),
        ),
      ),
    );
  }
}
