import 'package:flutter/material.dart';

class CarWashLogo extends StatelessWidget {
  final String? asset;
  final double iconSize;

  const CarWashLogo({super.key, required this.asset, this.iconSize = 48});

  @override
  Widget build(BuildContext context) {
    final asset = this.asset;
    if (asset == null) {
      return Icon(
        Icons.local_car_wash_rounded,
        size: iconSize,
        color: const Color(0xFF4E7469),
      );
    }
    return Image.asset(asset, fit: BoxFit.contain);
  }
}
