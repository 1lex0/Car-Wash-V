import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/iwash_palette.dart';
import 'mini_car.dart';

class WashBay extends StatelessWidget {
  final int number;

  final double left;
  final double top;
  final double width;
  final double height;

  final bool occupied;
  final bool vertical;

  final Color? carColor;

  final IWashPalette palette;

  const WashBay({
    super.key,
    required this.number,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.occupied,
    required this.vertical,
    required this.palette,
    this.carColor,
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
          color:
              occupied ? palette.occupiedBay : palette.freeBay,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: occupied
                ? palette.occupiedBorder
                : palette.freeBorder,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 7,
              top: 5,
              child: Text(
                '$number',
                style: TextStyle(
                  color: palette.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Center(
              child: occupied
                  ? Transform.rotate(
                      angle: vertical ? math.pi / 2 : 0,
                      child: MiniCar(
                        color: carColor ??
                            const Color(0xFFD7D3CB),
                        scale: vertical ? 0.70 : 0.82,
                        palette: palette,
                      ),
                    )
                  : Text(
                      'FREE',
                      style: TextStyle(
                        color: palette.freeText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),

            if (vertical)
              Positioned(
                left: 7,
                right: 7,
                bottom: 5,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: occupied
                        ? palette.occupiedAccent
                        : palette.freeAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )
            else
              Positioned(
                top: 8,
                bottom: 8,
                right: 5,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: occupied
                        ? palette.occupiedAccent
                        : palette.freeAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}