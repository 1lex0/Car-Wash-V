import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'logout_dialog.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showLogoutDialog(context);

    if (!confirmed) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFECE8DF);
    const darkGreen = Color(0xFF1F3A33);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const ProfileHeader(),

                  const SizedBox(height: 26),

                  const SectionTitle('My vehicle'),

                  const SizedBox(height: 10),

                  const SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicle',
                        value: 'Toyota Corolla',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle('Account & privacy'),

                  const SizedBox(height: 10),

                  const SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email',
                        value: 'a***@mail.com',
                      ),
                      SettingsDivider(),
                      SettingsRow(
                        icon: Icons.lock_outline_rounded,
                        title: 'Password',
                      ),
                      SettingsDivider(),
                      SettingsRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle('Appearance'),

                  const SizedBox(height: 10),

                  const SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.light_mode_outlined,
                        title: 'Theme',
                        value: 'Light',
                      ),
                      SettingsDivider(),
                      SettingsRow(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        value: 'English',
                      ),
                      SettingsDivider(),
                      SettingsRow(
                        icon: Icons.text_fields_rounded,
                        title: 'Display scale',
                        value: 'Default',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle('Preferences'),

                  const SizedBox(height: 10),

                  const SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                      ),
                      SettingsDivider(),
                      SettingsRow(
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle('About'),

                  const SizedBox(height: 10),

                  const SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        value: '1.0',
                        showArrow: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _logout(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
