import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

class GempaEvent {
  final String eventId;
  final String status;
  final String waktu;
  final String lintang;
  final String bujur;
  final String dalam;
  final String mag;
  final String fokal;
  final String area;

  GempaEvent({
    required this.eventId,
    required this.status,
    required this.waktu,
    required this.lintang,
    required this.bujur,
    required this.dalam,
    required this.mag,
    required this.fokal,
    required this.area,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'status': status,
      'waktu': waktu,
      'lintang': lintang,
      'bujur': bujur,
      'dalam': dalam,
      'mag': mag,
      'fokal': fokal,
      'area': area,
    };
  }

  factory GempaEvent.fromJson(Map<String, dynamic> json) {
    return GempaEvent(
      eventId: json['eventId'] ?? '',
      status: json['status'] ?? '',
      waktu: json['waktu'] ?? '',
      lintang: json['lintang'] ?? '',
      bujur: json['bujur'] ?? '',
      dalam: json['dalam'] ?? '',
      mag: json['mag'] ?? '',
      fokal: json['fokal'] ?? '',
      area: json['area'] ?? '',
    );
  }

  static String _formatTimeInIndonesian(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Hari ini ${DateFormat('HH:mm').format(dateTime)} WIB';
    } else if (date == yesterday) {
      return 'Kemarin ${DateFormat('HH:mm').format(dateTime)} WIB';
    } else {
      final monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${dateTime.day.toString().padLeft(2, '0')} ${monthNames[dateTime.month - 1]} ${dateTime.year} ${DateFormat('HH:mm').format(dateTime)} WIB';
    }
  }

  factory GempaEvent.fromXml(XmlElement xml) {
    DateTime utcTime = DateFormat('yyyy/MM/dd  HH:mm:ss.SSS')
        .parse(xml.findElements('waktu').single.innerText, true);
    DateTime localTime = utcTime.toLocal();
    String formattedTime = _formatTimeInIndonesian(localTime);

    return GempaEvent(
      eventId: xml.findElements('eventid').single.innerText,
      status: xml.findElements('status').single.innerText,
      waktu: formattedTime,
      lintang: xml.findElements('lintang').single.innerText,
      bujur: xml.findElements('bujur').single.innerText,
      dalam: xml.findElements('dalam').single.innerText,
      mag: xml.findElements('mag').single.innerText,
      fokal: xml.findElements('fokal').single.innerText,
      area: xml.findElements('area').single.innerText,
    );
  }
}
