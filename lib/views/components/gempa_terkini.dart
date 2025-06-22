import 'dart:async';

import 'package:earthquake_notification_filtering/controller/color_helper.dart';
import 'package:earthquake_notification_filtering/models/gempa_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:earthquake_notification_filtering/controller/gempa_provider.dart';

class GempaTerkini extends StatefulWidget {
  final Function(GempaEvent) onShowDetails;
  final ScrollController scrollController;

  const GempaTerkini({
    required this.onShowDetails,
    required this.scrollController,
    super.key,
  });

  @override
  _GempaTerkiniState createState() => _GempaTerkiniState();
}

class _GempaTerkiniState extends State<GempaTerkini> {
  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    final gempaProvider = Provider.of<GempaProvider>(context, listen: false);
    gempaProvider.fetchGempaData(); // Initial fetch
    Timer.periodic(const Duration(minutes: 1), (timer) {
      gempaProvider.fetchGempaData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GempaProvider>(
      builder: (context, gempaProvider, child) {
        if (gempaProvider.gempaEvents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final gempa = gempaProvider.gempaEvents;
        return Transform.translate(
          offset: const Offset(0, 0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20), // Adjust margin
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(15), // Clip with rounded corners
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: widget.scrollController,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 20),
                        physics: const ClampingScrollPhysics(),
                        itemCount: gempa.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              widget.onShowDetails(gempa[index]);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFEAEAEA),
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 5),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: getColorBasedOnvalue(
                                                  double.parse(
                                                      gempa[index].mag)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: getColorBasedOnvalue(
                                                          double.parse(
                                                              gempa[index].mag))
                                                      .withOpacity(0.5),
                                                  blurRadius: 0,
                                                  spreadRadius: 10,
                                                  offset: const Offset(0, 0),
                                                ),
                                                BoxShadow(
                                                  color: getColorBasedOnvalue(
                                                          double.parse(
                                                              gempa[index].mag))
                                                      .withOpacity(0.3),
                                                  blurRadius: 0,
                                                  spreadRadius: 6,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                gempa[index].mag,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                gempa[index].area,
                                                style: TextStyle(
                                                  color: Colors.grey.shade900,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                // 'Kedalaman ${gempa[index].dalam} KM',
                                                gempa[index].waktu,
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Text(
                                  //   gempa[index].waktu,
                                  //   style: TextStyle(
                                  //     color: Colors.grey.shade800,
                                  //     fontSize: 12,
                                  //     fontWeight: FontWeight.w700,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
