import 'package:flutter/material.dart';

class CarWashCard extends StatelessWidget {
  final String name;
  final String location;
  final String logoPath;
  final VoidCallback? onTap;

  const CarWashCard({
    super.key,
    required this.name,
    required this.location,
    required this.logoPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  logoPath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 19,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF777777),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Color(0xFF7A7A7A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}