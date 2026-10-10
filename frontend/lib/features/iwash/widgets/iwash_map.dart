import 'package:flutter/material.dart';

import '../models/waiting_position.dart';
import '../models/wash_live_state.dart';
import '../painters/iwash_ground_painter.dart';
import '../theme/iwash_palette.dart';
import 'parking_spot.dart';
import 'waiting_car.dart';
import 'wash_bay.dart';

class IWashMap extends StatelessWidget {
  final IWashPalette palette;
  final WashLiveState state;

  const IWashMap({
    super.key,
    required this.palette,
    required this.state,
  });

  static const List<WaitingPosition> waitingPositions = [
    WaitingPosition(
      x: 0.45,
      y: 0.34,
      angle: -0.13,
      color: Color(0xFFE98D8D),
    ),
    WaitingPosition(
      x: 0.63,
      y: 0.32,
      angle: 0.20,
      color: Color(0xFFF1B558),
    ),
    WaitingPosition(
      x: 0.78,
      y: 0.35,
      angle: -0.31,
      color: Color(0xFF70AED6),
    ),
    WaitingPosition(
      x: 0.52,
      y: 0.47,
      angle: 0.34,
      color: Color(0xFFD7D3CB),
    ),
    WaitingPosition(
      x: 0.67,
      y: 0.48,
      angle: -0.22,
      color: Color(0xFF89D69F),
    ),
    WaitingPosition(
      x: 0.80,
      y: 0.57,
      angle: 0.13,
      color: Color(0xFFBE91E7),
    ),
    WaitingPosition(
      x: 0.42,
      y: 0.61,
      angle: -0.38,
      color: Color(0xFFE889B7),
    ),
    WaitingPosition(
      x: 0.61,
      y: 0.64,
      angle: 0.15,
      color: Color(0xFFFFCB62),
    ),
    WaitingPosition(
      x: 0.74,
      y: 0.62,
      angle: -0.12,
      color: Color(0xFF79D3AA),
    ),
    WaitingPosition(
      x: 0.54,
      y: 0.56,
      angle: 0.07,
      color: Color(0xFF80B6DF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final waitingCount =
            state.waitingCarsCount.clamp(
          0,
          waitingPositions.length,
        );

        return Container(
          color: palette.mapBackground,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: IWashGroundPainter(
                    palette: palette,
                  ),
                ),
              ),

              // TOP 4 -> 1

              WashBay(
                number: 4,
                left: w * 0.32,
                top: h * 0.10,
                width: w * 0.115,
                height: h * 0.155,
                occupied: state.isBayOccupied(4),
                vertical: true,
                palette: palette,
              ),

              WashBay(
                number: 3,
                left: w * 0.47,
                top: h * 0.10,
                width: w * 0.115,
                height: h * 0.155,
                occupied: state.isBayOccupied(3),
                vertical: true,
                carColor: const Color(0xFFE88B8B),
                palette: palette,
              ),

              WashBay(
                number: 2,
                left: w * 0.62,
                top: h * 0.10,
                width: w * 0.115,
                height: h * 0.155,
                occupied: state.isBayOccupied(2),
                vertical: true,
                carColor: const Color(0xFFE788BC),
                palette: palette,
              ),

              WashBay(
                number: 1,
                left: w * 0.77,
                top: h * 0.10,
                width: w * 0.115,
                height: h * 0.155,
                occupied: state.isBayOccupied(1),
                vertical: true,
                carColor: const Color(0xFF74B6DF),
                palette: palette,
              ),

              // LEFT 5 → 7

              WashBay(
                number: 5,
                left: w * 0.17,
                top: h * 0.29,
                width: w * 0.17,
                height: h * 0.115,
                occupied: state.isBayOccupied(5),
                vertical: false,
                carColor: const Color(0xFFF4BF61),
                palette: palette,
              ),

              WashBay(
                number: 6,
                left: w * 0.17,
                top: h * 0.43,
                width: w * 0.17,
                height: h * 0.115,
                occupied: state.isBayOccupied(6),
                vertical: false,
                carColor: const Color(0xFFF4BF61),
                palette: palette,
              ),

              WashBay(
                number: 7,
                left: w * 0.17,
                top: h * 0.59,
                width: w * 0.17,
                height: h * 0.115,
                occupied: state.isBayOccupied(7),
                vertical: false,
                carColor: const Color(0xFF8BD69F),
                palette: palette,
              ),

              // BOTTOM 8 → 11

              WashBay(
                number: 8,
                left: w * 0.43,
                top: h * 0.76,
                width: w * 0.115,
                height: h * 0.155,
                occupied: state.isBayOccupied(8),
                vertical: true,
                carColor: const Color(0xFF8BD69F),
                palette: palette,
              ),

              WashBay(
                number: 9,
                left: w * 0.56,
                top: h * 0.76,
                width: w * 0.115,
                height: h * 0.155,
                occupied: state.isBayOccupied(9),
                vertical: true,
                carColor: const Color(0xFFBE91E7),
                palette: palette,
              ),

              WashBay(
                number: 10,
                left: w * 0.69,
                top: h * 0.76,
                width: w * 0.115,
                height: h * 0.155,
                occupied: state.isBayOccupied(10),
                vertical: true,
                carColor: const Color(0xFFB68DE2),
                palette: palette,
              ),

              WashBay(
                number: 11,
                left: w * 0.82,
                top: h * 0.76,
                width: w * 0.115,
                height: h * 0.155,
                occupied: state.isBayOccupied(11),
                vertical: true,
                carColor: const Color(0xFFE78D8D),
                palette: palette,
              ),

              // PARKING

              for (int i = 0; i < 8; i++)
                ParkingSpot(
                  left: w * 0.025,
                  top: h * (0.17 + i * 0.083),
                  width: w * 0.105,
                  height: h * 0.055,
                  occupied:
                      state.occupiedParkingSpots.contains(i),
                  carColor: _parkingCarColor(i),
                  palette: palette,
                ),

              // WAITING AREA
              // Сколько пришло из state — столько и рисуем.

              for (int i = 0; i < waitingCount; i++)
                WaitingCar(
                  left:
                      w * waitingPositions[i].x,
                  top:
                      h * waitingPositions[i].y,
                  angle:
                      waitingPositions[i].angle,
                  color:
                      waitingPositions[i].color,
                  palette: palette,
                ),
            ],
          ),
        );
      },
    );
  }

  Color _parkingCarColor(int index) {
    const colors = [
      Color(0xFF74B6DF),
      Color(0xFFF5C25D),
      Color(0xFFE887B8),
      Color(0xFF8CD49F),
      Color(0xFFBE91E7),
      Color(0xFFE98D8D),
      Color(0xFF72ADD3),
      Color(0xFFF4B459),
    ];

    return colors[index % colors.length];
  }
}