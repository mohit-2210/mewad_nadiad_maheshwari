import 'package:url_launcher/url_launcher.dart';

Future<void> openMap(String location) async {
  final uri =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$location');
  await launchUrl(uri);
}
