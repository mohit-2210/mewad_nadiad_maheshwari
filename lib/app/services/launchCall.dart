import 'package:url_launcher/url_launcher.dart';

Future<void> launchPhone(String number) async {
  final Uri uri = Uri(scheme: 'tel', path: number);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $number';
  }
}
