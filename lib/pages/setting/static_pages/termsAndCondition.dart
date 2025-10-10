import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mewad Maheshwari Nadiad Samaj - Terms & Conditions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '''Welcome to the Mewad Maheshwari Nadiad Samaj mobile application. By accessing or using this application, you agree to comply with and be bound by the following Terms and Conditions. Please read them carefully before using the app.''',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('1. Purpose of the App', theme),
              _buildBody(
                '''This application is designed exclusively for members of the Maheshwari community residing in Nadiad. It helps connect community members, share information, and promote engagement in social, religious, and cultural activities.''',
                theme,
              ),
              _buildSectionTitle('2. Eligibility', theme),
              _buildBody(
                '''Only verified members of the Maheshwari community in Nadiad district are permitted to use this application. Misrepresentation of identity or submission of false details may result in permanent suspension of access.''',
                theme,
              ),
              _buildSectionTitle('3. Information Accuracy', theme),
              _buildBody(
                '''Users are responsible for ensuring that their personal information (such as name, address, phone number, and occupation) is accurate and up to date. The Samaj administration reserves the right to verify any information provided.''',
                theme,
              ),
              _buildSectionTitle('4. Prohibited Use', theme),
              _buildBody(
                '''You agree not to use this app for any unlawful, harmful, or unauthorized purpose. Any attempt to misuse the app’s data, copy member information, or share private data without consent is strictly prohibited.''',
                theme,
              ),
              _buildSectionTitle('5. Intellectual Property', theme),
              _buildBody(
                '''All content, including logos, text, and media within this application, belongs to Mewad Maheshwari Nadiad Samaj. Reproduction or redistribution without written permission is not allowed.''',
                theme,
              ),
              _buildSectionTitle('6. Limitation of Liability', theme),
              _buildBody(
                '''The Samaj and its developers shall not be held liable for any damages resulting from use or inability to use this application. The app is provided “as is,” without warranties of any kind.''',
                theme,
              ),
              _buildSectionTitle('7. Amendments', theme),
              _buildBody(
                '''We reserve the right to modify or update these Terms and Conditions at any time. Continued use of the app after updates indicates your acceptance of the revised terms.''',
                theme,
              ),
              _buildSectionTitle('8. Contact Information', theme),
              _buildBody(
                '''For any queries or issues related to the app or these Terms, please contact the Mewad Maheshwari Nadiad Samaj office.''',
                theme,
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Last Updated: October 2025',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
    );
  }
}
