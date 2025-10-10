import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => appVersion = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Samaj')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/samaj_logo.png'),
            ),
            const SizedBox(height: 10),
            Text(
              'Mewad Maheshwari Nadiad Samaj',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Connecting Together, Preserving Heritage',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildSection(
              'About the Samaj',
              '''The Mewad Maheshwari Nadiad Samaj is a platform connecting Maheshwari families of Nadiad. Our vision is to preserve our rich traditions while encouraging unity and growth within the community.''',
              theme,
            ),
            _buildSection(
              'Mission & Vision',
              '''We aim to foster collaboration, cultural events, youth engagement, and mutual support through digital transformation.''',
              theme,
            ),
            _buildSection(
              'Developed & Managed By',
              '''Mewad Maheshwari Nadiad Samaj IT Committee\n📍 Nadiad, Gujarat, India\n✉️ mewadmaheshwarinadiad@gmail.com''',
              theme,
            ),
            const SizedBox(height: 20),
            Text(
              'App Version: $appVersion',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
