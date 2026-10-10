import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFECE8DF);
    const darkGreen = Color(0xFF1F3A33);
    const lightCard = Color(0xFFF7F4EE);
    const secondary = Color(0xFF6F7D78);

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
                    'Profile',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: darkGreen,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: Color(0xFF4E7469),
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(width: 15),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alex',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'My account',
                              style: TextStyle(
                                color: Color(0xFF9DAAA5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  const _SectionTitle('My vehicle'),

                  const SizedBox(height: 10),

                  const _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicle',
                        value: 'Toyota Corolla',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const _SectionTitle('Account & privacy'),

                  const SizedBox(height: 10),

                  const _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email',
                        value: 'a***@mail.com',
                      ),
                      _SettingsDivider(),
                      _SettingsRow(
                        icon: Icons.lock_outline_rounded,
                        title: 'Password',
                      ),
                      _SettingsDivider(),
                      _SettingsRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const _SectionTitle('Appearance'),

                  const SizedBox(height: 10),

                  const _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.light_mode_outlined,
                        title: 'Theme',
                        value: 'Light',
                      ),
                      _SettingsDivider(),
                      _SettingsRow(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        value: 'English',
                      ),
                      _SettingsDivider(),
                      _SettingsRow(
                        icon: Icons.text_fields_rounded,
                        title: 'Display scale',
                        value: 'Default',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const _SectionTitle('Preferences'),

                  const SizedBox(height: 10),

                  const _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                      ),
                      _SettingsDivider(),
                      _SettingsRow(
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const _SectionTitle('About'),

                  const SizedBox(height: 10),

                  const _SettingsCard(
                    children: [
                      _SettingsRow(
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
                      onPressed: () {},
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1F3A33),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool showArrow;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: showArrow ? () {} : null,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: const Color(0xFF1F3A33),
            ),

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

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 50),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFE0DCD4),
      ),
    );
  }
}