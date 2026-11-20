import 'package:flutter/material.dart';

import '../profile_palette.dart';

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool showArrow;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.showArrow = true,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = ProfilePalette.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 17,
          vertical: trailing == null ? 16 : 6,
        ),
        child: Row(
          children: [
            Icon(icon, size: 21, color: palette.text),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (value != null) ...[
              Flexible(
                child: Text(
                  value!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.subtext, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (trailing != null)
              trailing!
            else if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: palette.subtext,
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Divider(
        height: 1,
        thickness: 1,
        color: ProfilePalette.of(context).divider,
      ),
    );
  }
}
