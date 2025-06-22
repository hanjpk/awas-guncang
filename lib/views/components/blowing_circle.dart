// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';

class _BlowingCircleCustomPaint extends CustomPainter {
  _BlowingCircleCustomPaint(
      {required this.iconColor,
      required this.iconSize,
      required this.animationValue});

  final Color iconColor;

  final Size iconSize;

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final double halfWidth = iconSize.width / 2;
    const Offset center = Offset.zero;
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..color = iconColor;
    canvas.drawCircle(center, halfWidth, paint);
    canvas.drawCircle(center, halfWidth + halfWidth * 2 * animationValue,
        paint..color = iconColor.withOpacity(1 - animationValue));
  }

  @override
  bool shouldRepaint(_BlowingCircleCustomPaint oldDelegate) => true;
}

/// Renders the blowing  circle sample
class BlowingCircle extends StatefulWidget {
  /// Creates the blowing  circle sample
  const BlowingCircle({
    super.key,
    required this.color,
    required this.size,
  });

  /// Color value
  final Color color;
  final Size size;

  @override
  _BlowingCircleState createState() => _BlowingCircleState();
}

class _BlowingCircleState extends State<BlowingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<dynamic> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 5000,
      ),
    );

    _animation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    )..addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BlowingCircleCustomPaint(
          iconColor: widget.color,
          iconSize: widget.size,
          animationValue: _animation.value),
    );
  }
}
