import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/auth_api.dart';
import '../../models/profile_model.dart';
import '../../models/settings_model.dart';
import 'edit_dialogs.dart';
import 'logout_dialog.dart';
import 'profile_palette.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<SettingsModel>().theme;
    final brightness = switch (theme) {
      AppThemeChoice.light => Brightness.light,
      AppThemeChoice.dark => Brightness.dark,
      AppThemeChoice.system => MediaQuery.platformBrightnessOf(context),
    };

    return Theme(
      data: ProfilePalette.themeFor(brightness, Theme.of(context)),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  static String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at < 1) return email;
    return '${email[0]}***${email.substring(at)}';
  }

  Future<void> _editName(BuildContext context) async {
    final profile = context.read<ProfileModel>();
    final user = profile.user;
    if (user == null) return;
    final name = await showTextEditDialog(
      context,
      title: 'Your name',
      initialValue: user.name,
      validator: (v) => v.length < 2 ? 'Minimum 2 characters' : null,
    );
    if (name == null || name == user.name || !context.mounted) return;
    final error = await profile.updateName(name);
    if (!context.mounted) return;
    _snack(context, error ?? 'Name updated');
  }

  Future<void> _editEmail(BuildContext context) async {
    final profile = context.read<ProfileModel>();
    final user = profile.user;
    if (user == null) return;
    final email = await showTextEditDialog(
      context,
      title: 'Email',
      initialValue: user.email,
      keyboardType: TextInputType.emailAddress,
      validator: (v) => v.contains('@') ? null : 'Enter a valid email',
    );
    if (email == null || email == user.email || !context.mounted) return;
    final error = await profile.updateEmail(email);
    if (!context.mounted) return;
    _snack(context, error ?? 'Email updated');
  }

  Future<void> _changePassword(BuildContext context) async {
    final profile = context.read<ProfileModel>();
    final result = await showChangePasswordDialog(context);
    if (result == null || !context.mounted) return;
    final error = await profile.changePassword(result.current, result.next);
    if (!context.mounted) return;
    _snack(context, error ?? 'Password changed');
  }

  Future<void> _editVehicle(BuildContext context, {required bool plate}) async {
    final settings = context.read<SettingsModel>();
    final value = await showTextEditDialog(
      context,
      title: plate ? 'License plate' : 'Vehicle',
      initialValue: plate ? settings.vehiclePlate : settings.vehicleModel,
    );
    if (value == null) return;
    plate ? settings.setVehiclePlate(value) : settings.setVehicleModel(value);
  }

  Future<void> _pickTheme(BuildContext context) async {
    final settings = context.read<SettingsModel>();
    final choice = await showChoiceDialog(
      context,
      title: 'Theme',
      current: settings.theme,
      options: const {
        AppThemeChoice.light: 'Light',
        AppThemeChoice.dark: 'Dark',
        AppThemeChoice.system: 'System',
      },
    );
    if (choice != null) settings.setTheme(choice);
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final settings = context.read<SettingsModel>();
    final choice = await showChoiceDialog(
      context,
      title: 'Language',
      current: settings.language,
      options: {for (final l in SettingsModel.languages) l: l},
    );
    if (choice != null) settings.setLanguage(choice);
  }

  Future<void> _pickTextSize(BuildContext context) async {
    final settings = context.read<SettingsModel>();
    final choice = await showChoiceDialog(
      context,
      title: 'Display scale',
      current: settings.textSize,
      options: const {
        TextSizeChoice.small: 'Small',
        TextSizeChoice.normal: 'Default',
        TextSizeChoice.large: 'Large',
      },
    );
    if (choice != null) settings.setTextSize(choice);
  }

  void _openPrivacy(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Consumer<SettingsModel>(
        builder: (context, settings, _) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Hide email in profile'),
                subtitle: const Text('Show only the first letter and domain'),
                value: settings.hideEmail,
                onChanged: settings.setHideEmail,
              ),
              SwitchListTile(
                title: const Text('Share anonymous usage data'),
                subtitle: const Text('Helps to improve the app'),
                value: settings.shareUsage,
                onChanged: settings.setShareUsage,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showLogoutDialog(context);
    if (!confirmed || !context.mounted) return;

    await context.read<AuthApi>().logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final palette = ProfilePalette.of(context);
    final profile = context.watch<ProfileModel>();
    final settings = context.watch<SettingsModel>();
    final user = profile.user;

    final String headerName;
    final String headerSubtitle;
    if (user != null) {
      headerName = user.name;
      headerSubtitle = 'Tap to edit name';
    } else if (profile.isLoading) {
      headerName = 'Loading...';
      headerSubtitle = 'My account';
    } else {
      headerName = 'My account';
      headerSubtitle = profile.error ?? '';
    }

    final emailValue = user == null
        ? '—'
        : settings.hideEmail
        ? _maskEmail(user.email)
        : user.email;

    String themeLabel(AppThemeChoice t) => switch (t) {
      AppThemeChoice.light => 'Light',
      AppThemeChoice.dark => 'Dark',
      AppThemeChoice.system => 'System',
    };
    String sizeLabel(TextSizeChoice s) => switch (s) {
      TextSizeChoice.small => 'Small',
      TextSizeChoice.normal => 'Default',
      TextSizeChoice.large => 'Large',
    };

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: RefreshIndicator(
              onRefresh: () => context.read<ProfileModel>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ProfileHeader(
                    name: headerName,
                    subtitle: headerSubtitle,
                    onTap: user != null
                        ? () => _editName(context)
                        : () => context.read<ProfileModel>().load(),
                  ),

                  const SizedBox(height: 26),

                  const SectionTitle('My vehicle'),
                  const SizedBox(height: 10),
                  SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicle',
                        value: settings.vehicleModel,
                        onTap: () => _editVehicle(context, plate: false),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.pin_outlined,
                        title: 'License plate',
                        value: settings.vehiclePlate,
                        onTap: () => _editVehicle(context, plate: true),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle('Account & privacy'),
                  const SizedBox(height: 10),
                  SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email',
                        value: emailValue,
                        onTap: () => _editEmail(context),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.lock_outline_rounded,
                        title: 'Password',
                        value: '••••••',
                        onTap: () => _changePassword(context),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.shield_outlined,
                        title: 'Privacy',
                        onTap: () => _openPrivacy(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle('Appearance'),
                  const SizedBox(height: 10),
                  SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.light_mode_outlined,
                        title: 'Theme',
                        value: themeLabel(settings.theme),
                        onTap: () => _pickTheme(context),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        value: settings.language,
                        onTap: () => _pickLanguage(context),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.text_fields_rounded,
                        title: 'Display scale',
                        value: sizeLabel(settings.textSize),
                        onTap: () => _pickTextSize(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle('Preferences'),
                  const SizedBox(height: 10),
                  SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        onTap: () =>
                            settings.setNotifications(!settings.notifications),
                        trailing: Switch(
                          value: settings.notifications,
                          onChanged: settings.setNotifications,
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                        onTap: () => settings.setLocation(!settings.location),
                        trailing: Switch(
                          value: settings.location,
                          onChanged: settings.setLocation,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle('About'),
                  const SizedBox(height: 10),
                  SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        value: '1.0',
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: '2D Wash',
                          applicationVersion: '1.0',
                          applicationLegalese:
                              'Car wash catalog with I-Wash live map',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _logout(context),
                      style: TextButton.styleFrom(
                        foregroundColor: palette.text,
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
