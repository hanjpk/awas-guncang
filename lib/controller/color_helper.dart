import 'package:flutter/material.dart';

Color getColorBasedOnvalue(double value) {
  if (value <= 3.0) {
    return Colors.yellow;
  } else if (value <= 5.0) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
