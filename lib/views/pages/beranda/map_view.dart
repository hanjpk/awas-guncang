import 'dart:async';
import 'package:flutter/services.dart';
import 'package:earthquake_notification_filtering/views/components/blowing_circle.dart';
import 'package:earthquake_notification_filtering/views/components/gempa_terkini.dart';
import 'package:earthquake_notification_filtering/models/gempa_event.dart';
import 'package:earthquake_notification_filtering/controller/location_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:provider/provider.dart';
import 'package:earthquake_notification_filtering/controller/gempa_provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:earthquake_notification_filtering/controller/geojson_parser.dart';
import 'package:earthquake_notification_filtering/views/detail_gempa.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  Set<Marker> markers = {};
  bool isLocationLayerVisible = true;
  List<latlong.LatLng> faultLines = [];
  GeoJsonParser geoJsonParser = GeoJsonParser();
  LocationController? locationController;
  static bool isPollingStarted = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFaultLines();
    _startPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locationController =
        Provider.of<LocationController>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    locationController?.stopFetchingLocation();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      locationController?.startFetchingLocation();
      setState(() {
        isLocationLayerVisible = true;
      });
    } else if (state == AppLifecycleState.paused) {
      locationController?.stopFetchingLocation();
      setState(() {
        isLocationLayerVisible = false;
      });
    }
  }

  void _startPolling() {
    if (!isPollingStarted) {
      final gempaProvider = Provider.of<GempaProvider>(context, listen: false);
      gempaProvider.fetchGempaData();
      isPollingStarted = true;
      // Timer.periodic(const Duration(seconds: 60), (timer) {
      //   gempaProvider.fetchGempaData();
      // });
    }
  }

  Future<void> _loadFaultLines() async {
    final String response =
        await rootBundle.loadString('assets/json/indo_faults_lines.geojson');
    geoJsonParser.parseGeoJsonAsString(response);
    setState(() {
      markers.addAll(geoJsonParser.markers);
    });
  }

  void _createMarkers(List<GempaEvent> gempa) {
    markers.clear();

    // Create markers for earthquake events
    for (var event in gempa) {
      final lat = double.parse(event.lintang);
      final lng = double.parse(event.bujur);
      Color iconColor;

      // Determine the color based on the magnitude
      double magnitude = double.parse(event.mag);
      if (magnitude < 3) {
        iconColor = const Color.fromARGB(
            255, 227, 227, 92); // Yellow for magnitude below 3
      } else if (magnitude >= 3 && magnitude <= 5) {
        iconColor = const Color.fromARGB(
            255, 243, 165, 76); // Orange for magnitude between 3 and 5
      } else {
        iconColor = const Color.fromARGB(
            255, 227, 101, 92); // Red for magnitude above 5
      }

      markers.add(
        Marker(
          point: latlong.LatLng(lat, lng),
          width: 15,
          height: 15,
          child: BlowingCircle(
            color: iconColor,
            size: const Size(15, 15),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gempaProvider = Provider.of<GempaProvider>(context);
    _createMarkers(gempaProvider.gempaEvents);
    return locationController?.currentPosition == null
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: SlidingUpPanel(
              boxShadow: const [],
              panelBuilder: (ScrollController sc) => _scrollingList(sc),
              color: const Color.fromARGB(255, 250, 255, 253),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              collapsed: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 250, 255, 253),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: const Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.chevron_up),
                    SizedBox(height: 7),
                    Text("Gempa Terkini", style: TextStyle(fontSize: 16)),
                  ],
                )),
              ),
              body: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: latlong.LatLng(
                    locationController!.currentPosition!.latitude,
                    locationController!.currentPosition!.longitude,
                  ),
                  initialZoom: 6,
                  onMapReady: () {},
                ),
                children: [
                  TileLayer(
                    urlTemplate: dotenv.get("ARCGISMAP"),
                  ),
                  MarkerLayer(
                    markers: markers.toList(),
                  ),
                  if (isLocationLayerVisible) CurrentLocationLayer(),
                  PolylineLayer(
                    polylines: geoJsonParser.polylines,
                  ),
                ],
              ),
            ),
          );
  }

  Widget _scrollingList(ScrollController sc) {
    return GempaTerkini(
      onShowDetails: (gempaEvent) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailGempa(gempaEvent: gempaEvent),
          ),
        );
      },
      scrollController: sc,
    );
  }

  // void _centerMapOnLocation(double lat, double lng) {
  //   _mapController.move(latlong.LatLng(lat - 1.7, lng), 8.0);
  // }
}
