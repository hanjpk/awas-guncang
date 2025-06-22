import 'package:flutter/material.dart';
import 'package:earthquake_notification_filtering/models/gempa_event.dart';
import 'package:earthquake_notification_filtering/controller/gempa_api.dart';

class GempaProvider with ChangeNotifier {
  List<GempaEvent> _gempaEvents = [];

  List<GempaEvent> get gempaEvents => _gempaEvents;

  Future<void> fetchGempaData() async {
    List<GempaEvent> newEvents = await fetchGempa();
    if (_gempaEvents != newEvents) {
      _gempaEvents = newEvents;
      notifyListeners();
    }
  }
}
