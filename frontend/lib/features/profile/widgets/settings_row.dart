import 'package:flutter/material.dart';

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool showArrow;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.showArrow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 21, color: const Color(0xFF1F3A33)),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1F3A33),
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
                  style: const TextStyle(
                    color: Color(0xFF6F7D78),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF6F7D78),
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
    return const Padding(
      padding: EdgeInsets.only(left: 50),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE0DCD4)),
    );
  }
}
