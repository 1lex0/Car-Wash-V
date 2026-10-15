import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_car_washes.dart';

class CarWashDetailScreen extends StatelessWidget {
  final int id;

  const CarWashDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final matches = mockCarWashes.where((wash) => wash.id == id);

    if (matches.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFECE8DF),
        appBar: AppBar(title: const Text('Car wash')),
        body: const Center(child: Text('Car wash not found')),
      );
    }

    final wash = matches.first;

    return Scaffold(
      backgroundColor: const Color(0xFFECE8DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECE8DF),
        elevation: 0,
        title: Text(
          wash.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F3A33),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 210,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EE),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Image.asset(wash.logoAsset, fit: BoxFit.contain),
            ),
            const SizedBox(height: 28),
            Text(
              wash.name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F3A33),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${wash.area}, ${wash.city}',
              style: const TextStyle(fontSize: 17, color: Color(0xFF6F7D78)),
            ),
            const Spacer(),

            if (wash.id == 3)
              FilledButton.icon(
                onPressed: () {
                  context.push('/search/${wash.id}/map');
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open live map'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFF1F3A33),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
