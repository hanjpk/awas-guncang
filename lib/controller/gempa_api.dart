// import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:earthquake_notification_filtering/models/gempa_event.dart';
import 'package:xml/xml.dart';

Future<List<GempaEvent>> fetchGempa() async {
  try {
    final response =
        await http.get(Uri.parse(dotenv.env['GEMPA_TERKINI_API']!));

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final gempaElements = document.findAllElements('gempa');

      // Debugging: Print the number of gempa elements found
      // print('Number of gempa elements found: ${gempaElements.length}');

      return gempaElements.map((xml) {
        // Debugging: Print each gempa element
        // print(xml.toXmlString());
        return GempaEvent.fromXml(xml);
      }).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  } catch (e) {
    // print('Error: $e');
    return [
      GempaEvent(
        eventId: 'dummy1',
        status: 'automatic',
        waktu: '01/01/2024  10:00:00',
        lintang: '-6.2000',
        bujur: '106.8000',
        dalam: '10 km',
        mag: '5.5',
        fokal: 'normal',
        area: 'Jakarta, Indonesia',
      ),
      GempaEvent(
        eventId: 'dummy2',
        status: 'manual',
        waktu: '02/01/2024  12:00:00',
        lintang: '-7.2000',
        bujur: '107.6000',
        dalam: '15 km',
        mag: '6.0',
        fokal: 'reverse',
        area: 'Bandung, Indonesia',
      ),
    ];
  }
}
