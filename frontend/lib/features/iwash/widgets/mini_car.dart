import 'package:flutter/material.dart';

import '../painters/mini_car_painter.dart';
import '../theme/iwash_palette.dart';

class MiniCar extends StatelessWidget {
  final Color color;
  final double scale;
  final IWashPalette palette;

  const MiniCar({
    super.key,
    required this.color,
    required this.palette,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 50,
        height: 30,
        child: CustomPaint(
          painter: MiniCarPainter(
            bodyColor: color,
            darkColor: palette.carDark,
          ),
        ),
      ),
    );
  }
}