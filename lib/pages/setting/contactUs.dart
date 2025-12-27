import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';
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
            Gap.s10H(),
            Text(
              '''For any queries, feedback, or community-related assistance, please reach out to us using the details below.''',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            Gap.s20H(),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.black,
              ),
              title: const Text('Mohit Soni'),
            ),
            ListTile(
              leading: const Icon(
                Icons.phone,
                color: Colors.green,
              ),
              title: const Text('+91 6353668707'),
              onTap: () => launchPhone('+916353668707'),
            ),
            ListTile(
              leading: const Icon(
                Icons.email,
                color: Colors.red,
              ),
              title: const Text('nadiadmaheshwarisamaj'),
              onTap: () => launchEmail('nadiadmaheshwarisamaj@gmail.com'),
            ),
            ListTile(
              leading: const Icon(
                Icons.location_on,
                color: Colors.blue,
              ),
              title: const Text('Mahesh Vatika, Nadiad, Gujarat, India'),
              onTap: () => openMap('Mahesh Vatika, Nadiad, Gujarat, India'),
            ),
            Gap.s30H(),
            Text(
              'Development Team',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Gap.s10H(),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.black,
              ),
              title: const Text('Rushit Rabadiya'),
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.black,
              ),
              title: const Text('Mahak Shah'),
            ),
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
