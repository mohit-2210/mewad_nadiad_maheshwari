import 'package:flutter/material.dart';
import 'package:mmsn/app/services/launchCall.dart';
import 'package:mmsn/app/services/launchEmail.dart';
import 'package:mmsn/app/services/launchMap.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '''For any queries, feedback, or community-related assistance, please reach out to us using the details below.''',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('+91 98765 43210'),
              onTap: () => launchPhone('+919876543210'),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('nadiadmaheshwarisamaj'),
              onTap: () => launchEmail('nadiadmaheshwarisamaj@gmail.com'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Mahesh Vatika, Nadiad, Gujarat, India'),
              onTap: () => openMap('Mahesh Vatika, Nadiad, Gujarat, India'),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'We value your feedback 🙏',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
