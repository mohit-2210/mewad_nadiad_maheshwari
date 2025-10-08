import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:mmsn/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

@NowaGenerated()
Future<void> initializeApp() async {
  sharedPrefs = await SharedPreferences.getInstance();
}
