import 'package:mmsn/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> initializeApp() async {
  sharedPrefs = await SharedPreferences.getInstance();
}
