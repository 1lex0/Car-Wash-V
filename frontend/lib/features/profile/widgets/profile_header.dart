import 'package:flutter/material.dart';

import '../profile_palette.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback? onTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = ProfilePalette.of(context);
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return Material(
      color: palette.header,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: palette.avatar,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: palette.headerSubtext,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.edit_outlined,
                  color: palette.headerSubtext,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
