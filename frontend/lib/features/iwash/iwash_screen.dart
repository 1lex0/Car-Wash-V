import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/iwash_live_model.dart';
import '../../widgets/error_view.dart';
import 'theme/iwash_palette.dart';
import 'widgets/iwash_map.dart';

class IWashScreen extends StatefulWidget {
  final int washId;

  const IWashScreen({super.key, required this.washId});

  @override
  State<IWashScreen> createState() => _IWashScreenState();
}

class _IWashScreenState extends State<IWashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
  }

  void _reload() => context.read<IWashLiveModel>().load(widget.washId);

  bool _isDayTime() {
    final hour = DateTime.now().hour;

    return hour >= 6 && hour < 18;
  }

  @override
  Widget build(BuildContext context) {
    final palette = _isDayTime()
        ? const IWashPalette.day()
        : const IWashPalette.night();

    final live = context.watch<IWashLiveModel>();
    final liveState = live.state;

    final Widget map;
    if (live.isLoading || (liveState == null && live.error == null)) {
      map = Center(
        child: CircularProgressIndicator(color: palette.primaryText),
      );
    } else if (live.error != null) {
      map = ColoredBox(
        color: const Color(0xFFECE8DF),
        child: ErrorView(message: live.error!, onRetry: _reload),
      );
    } else {
      map = IWashMap(palette: palette, state: liveState!);
    }

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 18, 10),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I-Wash',
                          style: TextStyle(
                            color: palette.primaryText,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Chișinău',
                          style: TextStyle(
                            color: palette.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xFF41D99A),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: palette.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: live.isLoading ? null : _reload,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: palette.primaryText,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: map,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
