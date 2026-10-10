import 'package:flutter/material.dart';

import '../theme/iwash_palette.dart';
import 'mini_car.dart';

class ParkingSpot extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double height;
  final bool occupied;
  final Color carColor;
  final IWashPalette palette;

  const ParkingSpot({
    super.key,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.occupied,
    required this.carColor,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: palette.parkingBackground,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: palette.parkingBorder,
            width: 2,
          ),
        ),
        child: Center(
          child: occupied
              ? MiniCar(
                  color: carColor,
                  scale: 0.55,
                  palette: palette,
                )
              : Text(
                  'P',
                  style: TextStyle(
                    color: palette.secondaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}