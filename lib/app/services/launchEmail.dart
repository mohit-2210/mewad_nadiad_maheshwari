import 'package:url_launcher/url_launcher.dart';

Future<void> launchEmail(String email) async {
  final uri = Uri.parse('mailto:$email?subject=App%20Feedback');
  await launchUrl(uri);
}
