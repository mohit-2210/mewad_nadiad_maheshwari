import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.05),
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
                'Privacy Policy - Mewad Maheshwari Nadiad Samaj',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '''Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect the personal information of members using the Mewad Maheshwari Nadiad Samaj mobile application.''',
                style: theme.textTheme.bodyMedium,
              ),
              _buildSectionTitle('1. Information We Collect', theme),
              _buildBody(
                '''We collect personal information that helps identify and connect community members, including:
- Full Name  
- Birth Date  
- Address  
- Phone Number  
- Occupation  
- Profile Photo  
- Other voluntary details related to community involvement.''',
                theme,
              ),
              _buildSectionTitle('2. How We Use Your Information', theme),
              _buildBody(
                '''The collected data is used solely for:
- Displaying member profiles to other verified members  
- Facilitating community activities and communication  
- Managing event participation and Samaj directories  
- Enhancing app functionality and member engagement.''',
                theme,
              ),
              _buildSectionTitle('3. Data Sharing and Disclosure', theme),
              _buildBody(
                '''We do not sell, trade, or rent personal data to outsiders.  
Information may be shared only with:
- Authorized Samaj administrators  
- Verified community members for internal use  
- Government authorities if required by law.''',
                theme,
              ),
              _buildSectionTitle('4. Data Security', theme),
              _buildBody(
                '''We use secure servers and encryption techniques to protect your personal information. However, no online system can be completely secure, and we cannot guarantee absolute protection.''',
                theme,
              ),
              _buildSectionTitle('5. Data Retention', theme),
              _buildBody(
                '''Your information will be retained as long as your account remains active or as required to maintain Samaj records. You can request deletion of your data at any time through official communication.''',
                theme,
              ),
              _buildSectionTitle('6. Your Rights', theme),
              _buildBody(
                '''You have the right to:
- Access and review your personal information  
- Request corrections or updates  
- Ask for deletion of your account and related data.''',
                theme,
              ),
              _buildSectionTitle('7. Children’s Privacy', theme),
              _buildBody(
                '''This app is intended for adult members of the community. Users under 18 should use the app under parental guidance.''',
                theme,
              ),
              _buildSectionTitle('8. Updates to this Policy', theme),
              _buildBody(
                '''We may update this Privacy Policy periodically. Members will be notified in-app when major updates occur.''',
                theme,
              ),
              _buildSectionTitle('9. Contact Us', theme),
              _buildBody(
                '''For privacy-related questions, corrections, or data removal requests, please contact the Mewad Maheshwari Nadiad Samaj committee.''',
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
