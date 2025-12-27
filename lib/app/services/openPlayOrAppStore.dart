import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

Future<void> openStore() async {
  const String androidUrl =
      'https://play.google.com/store/apps/details?id=com.nadiadmaheshwari.app';
  const String iosUrl =
      'https://apps.apple.com/in/app/mewad-maheshwari-samaj-nadiad/id6755380541'; // Replace with actual App Store ID

  final Uri uri = Uri.parse(Platform.isAndroid ? androidUrl : iosUrl);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch the app store link';
  }
}
