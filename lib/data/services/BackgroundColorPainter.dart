import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/ChartConfig.dart';

class BackgroundColorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final totalHeight = size.height;
    final maxY = 8.0; // Total range from -4 to 4
    final thresholdY = 2.5;

    // Calculate position from bottom for the threshold (2.5)
    final orangeStartHeight = totalHeight * (1 - ((thresholdY + 4) / maxY));

    final orangePaint =
        Paint()
          ..color = Colors.orange.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final whitePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, orangeStartHeight),
      orangePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        orangeStartHeight,
        size.width,
        totalHeight - orangeStartHeight,
      ),
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
