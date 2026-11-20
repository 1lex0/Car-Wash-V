import 'package:flutter/material.dart';

import '../profile_palette.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProfilePalette.of(context).card,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: ProfilePalette.of(context).text,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
