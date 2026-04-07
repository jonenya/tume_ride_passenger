import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tume_ride_passenger/providers/auth_provider.dart';
import 'package:tume_ride_passenger/providers/theme_provider.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _darkMode = false;
  String _selectedLanguage = 'en';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _darkMode = themeProvider.isDarkMode;
      _selectedLanguage = authProvider.user?.language ?? 'en';
    });
  }

  Future<void> _updateLanguage(String language) async {
    setState(() => _isLoading = true);

    final api = ApiService();
    final response = await api.post(ApiConstants.profile, data: {
      'action': ApiConstants.updateLanguage,
      'language': language,
    });

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(language: language);
        authProvider.updateUser(updatedUser);
      }
      showSnackBar(context, message: 'Language updated');
    } else {
      showSnackBar(
        context,
        message: response['message'] ?? 'Failed to update language',
        isError: true,
      );
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          _SettingsSwitch(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark theme',
            value: _darkMode,
            onChanged: _toggleDarkMode,
          ),
          const SizedBox(height: 8),
          _SettingsDropdown(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Choose your preferred language',
            value: _selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'sw', child: Text('Kiswahili')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLanguage = value);
                _updateLanguage(value);
              }
            },
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          _SettingsSwitch(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive ride updates and offers',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
              // TODO: Update notification settings
            },
          ),
          _SettingsSwitch(
            icon: Icons.email,
            title: 'Email Notifications',
            subtitle: 'Receive receipts and promotions',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          _SettingsSwitch(
            icon: Icons.sms,
            title: 'SMS Notifications',
            subtitle: 'Receive OTP and ride alerts',
            value: _smsNotifications,
            onChanged: (value) {
              setState(() => _smsNotifications = value);
            },
          ),

          const SizedBox(height: 24),

          // Privacy Section
          _SectionHeader(title: 'Privacy & Security'),
          _SettingsItem(
            icon: Icons.lock,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Show privacy policy
            },
          ),
          _SettingsItem(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              // TODO: Show terms
            },
          ),
          _SettingsItem(
            icon: Icons.data_usage,
            title: 'Data Usage',
            onTap: () {
              // TODO: Show data usage
            },
          ),

          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: 'About'),
          _SettingsItem(
            icon: Icons.info,
            title: 'App Version',
            trailing: '1.0.0',
            onTap: null,
          ),
          _SettingsItem(
            icon: Icons.star,
            title: 'Rate Us',
            onTap: () {
              // TODO: Open Play Store
            },
          ),
          _SettingsItem(
            icon: Icons.share,
            title: 'Share App',
            onTap: () {
              // TODO: Share app
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _SettingsDropdown({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title),
      trailing: trailing != null
          ? Text(
        trailing!,
        style: TextStyle(color: AppColors.textSecondary),
      )
          : const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: onTap,
    );
  }
}
