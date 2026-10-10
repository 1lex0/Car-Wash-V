import 'package:flutter/material.dart';

import 'models/wash_live_state.dart';
import 'theme/iwash_palette.dart';
import 'widgets/iwash_map.dart';

class IWashScreen extends StatelessWidget {
  final WashLiveState state;

  const IWashScreen({
    super.key,
    required this.state,
  });

  bool _isDayTime() {
    final hour = DateTime.now().hour;

    return hour >= 6 && hour < 18;
  }

  @override
  Widget build(BuildContext context) {
    final palette = _isDayTime()
        ? const IWashPalette.day()
        : const IWashPalette.night();

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                8,
                18,
                10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: palette.primaryText,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I-Wash',
                          style: TextStyle(
                            color:
                                palette.primaryText,
                            fontSize: 27,
                            fontWeight:
                                FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Chișinău',
                          style: TextStyle(
                            color:
                                palette.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 4,
                          backgroundColor:
                              Color(0xFF41D99A),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color:
                                palette.primaryText,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  4,
                  10,
                  10,
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(30),
                  child: IWashMap(
                    palette: palette,
                    state: state,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}