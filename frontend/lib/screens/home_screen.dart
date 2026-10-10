import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HomeScreen({
    super.key,
    required this.onSearchTap,
  });

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 18) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFECE8DF);
    const darkCard = Color(0xFF1F3A33);
    const lightCard = Color(0xFFF7F4EE);
    const darkText = Color(0xFF18372F);
    const secondaryText = Color(0xFF6F7D78);
    const accentGreen = Color(0xFF3B886E);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 95),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                color: secondaryText,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Alex',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 30,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // WEATHER CAPSULE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: lightCard,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 19,
                              color: darkText,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '18°',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Dry until Sunday',
                    style: TextStyle(
                      color: accentGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // THIS IS WHAT FIXES THE VERTICAL BALANCE
                  const Spacer(),

                  // CENTRAL CONTENT
                  Column(
                    children: [
                      // CAR CARD
                      Container(
                        width: double.infinity,
                        height: 188,
                        decoration: BoxDecoration(
                          color: darkCard,
                          borderRadius: BorderRadius.circular(27),
                        ),
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // decorative circles
                            Positioned(
                              right: -55,
                              top: -45,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2F564D),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -20,
                              top: 52,
                              child: Container(
                                width: 165,
                                height: 165,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF274840),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                            const Positioned(
                              left: 18,
                              top: 16,
                              child: Text(
                                'Your car',
                                style: TextStyle(
                                  color: Color(0xFF9DAAA5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            Positioned(
                              right: 14,
                              top: 9,
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color(0xFF9DAAA5),
                                  size: 22,
                                ),
                              ),
                            ),

                            const Positioned(
                              left: 0,
                              right: 0,
                              top: 48,
                              child: Center(
                                child: _CarSilhouette(),
                              ),
                            ),

                            const Positioned(
                              left: 18,
                              bottom: 34,
                              child: Text(
                                'Toyota Corolla',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),

                            const Positioned(
                              left: 18,
                              bottom: 16,
                              child: Text(
                                'A B C  1 2 3',
                                style: TextStyle(
                                  color: Color(0xFFA2AEA9),
                                  fontSize: 13,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // SEARCH CARD
                      Material(
                        color: lightCard,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          onTap: onSearchTap,
                          borderRadius: BorderRadius.circular(22),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: darkText,
                                  size: 28,
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Where do you want to\nwash?',
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 17,
                                      height: 1.12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarSilhouette extends StatelessWidget {
  const _CarSilhouette();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 215,
      height: 95,
      child: CustomPaint(
        painter: _CarPainter(),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF4E7469)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = const Color(0xFF1F3A33)
      ..style = PaintingStyle.fill;

    final tyrePaint = Paint()
      ..color = const Color(0xFF10251F);

    final wheelPaint = Paint()
      ..color = const Color(0xFF8BA59C);

    final body = Path();

    body.moveTo(18, 66);
    body.quadraticBezierTo(22, 52, 44, 46);
    body.lineTo(74, 20);
    body.quadraticBezierTo(82, 12, 94, 12);
    body.lineTo(139, 12);
    body.quadraticBezierTo(150, 13, 158, 22);
    body.lineTo(179, 46);
    body.quadraticBezierTo(202, 50, 208, 66);
    body.lineTo(208, 76);
    body.lineTo(18, 76);
    body.close();

    canvas.drawPath(body, bodyPaint);

    final rearWindow = Path()
      ..moveTo(87, 25)
      ..lineTo(111, 25)
      ..lineTo(116, 45)
      ..lineTo(65, 45)
      ..close();

    final frontWindow = Path()
      ..moveTo(119, 25)
      ..lineTo(141, 25)
      ..lineTo(160, 45)
      ..lineTo(122, 45)
      ..close();

    canvas.drawPath(rearWindow, windowPaint);
    canvas.drawPath(frontWindow, windowPaint);

    const rearWheel = Offset(59, 77);
    const frontWheel = Offset(178, 77);

    canvas.drawCircle(rearWheel, 17, tyrePaint);
    canvas.drawCircle(frontWheel, 17, tyrePaint);

    canvas.drawCircle(rearWheel, 8, wheelPaint);
    canvas.drawCircle(frontWheel, 8, wheelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}