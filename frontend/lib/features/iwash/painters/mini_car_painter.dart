import 'package:flutter/material.dart';

class MiniCarPainter extends CustomPainter {
  final Color bodyColor;
  final Color darkColor;

  MiniCarPainter({
    required this.bodyColor,
    required this.darkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    final dark = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;

    final carBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        4,
        7,
        size.width - 8,
        16,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(carBody, body);

    final roof = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        15,
        3,
        size.width - 30,
        24,
      ),
      const Radius.circular(5),
    );

    canvas.drawRRect(roof, body);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.35,
        6,
        size.width * 0.30,
        18,
      ),
      dark,
    );

    canvas.drawCircle(
      Offset(11, size.height - 4),
      4,
      dark,
    );

    canvas.drawCircle(
      Offset(size.width - 11, size.height - 4),
      4,
      dark,
    );
  }

  @override
  bool shouldRepaint(covariant MiniCarPainter oldDelegate) {
    return oldDelegate.bodyColor != bodyColor ||
        oldDelegate.darkColor != darkColor;
  }
}