import 'package:flutter/material.dart';

import '../models/car_wash.dart';

class CarWashCard extends StatelessWidget {
  final CarWash wash;
  final VoidCallback? onTap;

  const CarWashCard({super.key, required this.wash, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F4EE),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Image.asset(wash.logoAsset, fit: BoxFit.contain)),

              const SizedBox(height: 14),

              Text(
                wash.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3A33),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${wash.area}, ${wash.city}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6F7D78)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
