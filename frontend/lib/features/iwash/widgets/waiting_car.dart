import 'package:flutter/material.dart';

import '../theme/iwash_palette.dart';
import 'mini_car.dart';

class WaitingCar extends StatelessWidget {
  final double left;
  final double top;
  final double angle;
  final Color color;
  final IWashPalette palette;

  const WaitingCar({
    super.key,
    required this.left,
    required this.top,
    required this.angle,
    required this.color,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: MiniCar(
          color: color,
          scale: 0.82,
          palette: palette,
        ),
      ),
    );
  }
}