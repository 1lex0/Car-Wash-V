import 'package:flutter/material.dart';

import '../theme/iwash_palette.dart';

class IWashGroundPainter extends CustomPainter {
  final IWashPalette palette;

  IWashGroundPainter({
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = palette.road
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.026
      ..strokeCap = StrokeCap.round;

    final waitingAreaPaint = Paint()
      ..color = palette.waitingArea
      ..style = PaintingStyle.fill;

    final waitingBorderPaint = Paint()
      ..color = palette.waitingBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final perimeter = Path()
      ..moveTo(
        size.width * 0.10,
        size.height * 0.065,
      )
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.015,
        size.width * 0.94,
        size.height * 0.065,
      )
      ..quadraticBezierTo(
        size.width * 0.98,
        size.height * 0.40,
        size.width * 0.95,
        size.height * 0.73,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.76,
        size.width * 0.41,
        size.height * 0.74,
      );

    canvas.drawPath(
      perimeter,
      road,
    );

    final waitingArea = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        size.width * 0.36,
        size.height * 0.27,
        size.width * 0.91,
        size.height * 0.71,
      ),
      const Radius.circular(5),
    );

    canvas.drawRRect(
      waitingArea,
      waitingAreaPaint,
    );

    canvas.drawRRect(
      waitingArea,
      waitingBorderPaint,
    );

    final entryTop = Path()
      ..moveTo(
        size.width * 0.13,
        size.height * 0.72,
      )
      ..lineTo(
        size.width * 0.31,
        size.height * 0.62,
      );

    final entryBottom = Path()
      ..moveTo(
        size.width * 0.16,
        size.height * 0.81,
      )
      ..lineTo(
        size.width * 0.36,
        size.height * 0.68,
      );

    canvas.drawPath(
      entryTop,
      road,
    );

    canvas.drawPath(
      entryBottom,
      road,
    );
  }

  @override
  bool shouldRepaint(
    covariant IWashGroundPainter oldDelegate,
  ) {
    return oldDelegate.palette != palette;
  }
}