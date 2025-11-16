import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/app/services/launchEmail.dart';
import 'package:mmsn/app/services/openPlayOrAppStore.dart';
import 'package:mmsn/pages/auth/services/auth_service.dart';
import 'package:mmsn/components/DeleteAccountButton.dart';
import 'package:mmsn/components/logoutButton.dart';
import 'package:mmsn/pages/auth/login_screen.dart';
import 'package:mmsn/pages/auth/changePassword.dart';
import 'package:mmsn/pages/setting/contactUs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Gap.s10H(),

          // 🔹 NOTIFICATIONS
          _buildSectionHeader('Notifications', theme),
          SwitchListTile(
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
              // Save preference in SharedPreferences or Firestore
            },
            title: const Text('Event & Update Alerts'),
            secondary: Icon(Icons.notifications_active_outlined,
                color: theme.colorScheme.primary),
          ),
          const Divider(),

          // 🔹 SUPPORT / FEEDBACK
          _buildSectionHeader('Support & Feedback', theme),
          _buildListTile(
            context,
            icon: Icons.email_outlined,
            title: 'Contact Us',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactUsScreen()),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.star_border,
            title: 'Rate the App',
            onTap: openStore,
          ),
          _buildListTile(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Report an Issue',
            onTap: () => launchEmail('nadiadmaheshwarisamaj@gmail.com'),
          ),

          const Divider(),
          // 🔹 ACCOUNT SETTINGS
          _buildSectionHeader('Account Settings', theme),
          _buildListTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          logoutButton(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            onTap: _logout,
            delay: 50,
          ),
          deleteAccountButton(
            context: context,
            delay: 800,
            onConfirm: () {
              // 🔥 Handle delete account logic here
              // e.g., call API -> authRepository.deleteAccount()
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your account has been deleted')),
              );
            },
          ),

          Gap.s30H(),
          Center(
            child: Text(
              '© 2025 Mewad Maheshwari Nadiad Samaj',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          Gap.s20H(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  } 

Future<void> _logout() async {
  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    await AuthApiService.instance.logout();
    if (mounted) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
        backgroundColor: Colors.green,
      ),
    );

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    if (mounted) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Logout failed: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}
