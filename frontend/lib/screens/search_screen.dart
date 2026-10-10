import 'package:flutter/material.dart';

import '../features/iwash/iwash_screen.dart';
import '../features/iwash/repositories/iwash_repository.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFECE8DF);
    const darkGreen = Color(0xFF1F3A33);
    const lightCard = Color(0xFFF7F4EE);
    const secondary = Color(0xFF6F7D78);

    final carWashes = [
      {
        'name': 'Lux Wash',
        'location': 'Centru',
        'logo': 'assets/logos/Lux-wash.png',
      },
      {
        'name': 'E-Wash',
        'location': 'Rîșcani',
        'logo': 'assets/logos/E-wash.png',
      },
      {
        'name': 'I-Wash',
        'location': 'Botanica',
        'logo': 'assets/logos/I-wash.png',
      },
    ];

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find a car wash',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Choose where you want to wash today.',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search car washes',
                      hintStyle: const TextStyle(
                        color: secondary,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: darkGreen,
                      ),
                      filled: true,
                      fillColor: lightCard,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 17,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: darkGreen,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Car washes',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: carWashes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final wash = carWashes[index];

                      return Material(
                        color: darkGreen,
                        borderRadius: BorderRadius.circular(28),
                        child: InkWell(
                         onTap: () {
                          if (wash['name'] == 'I-Wash') {
                            const repository = IWashRepository();

                            final state = repository.getCurrentState();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IWashScreen(
                                  state: state,
                                ),
                              ),
                            );
                          }
                        },
                          borderRadius: BorderRadius.circular(28),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: lightCard,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    padding: const EdgeInsets.all(18),
                                    child: Image.asset(
                                      wash['logo']!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  wash['name']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  '${wash['location']}, Chișinău',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF9DAAA5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}