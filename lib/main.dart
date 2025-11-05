import 'package:firebase_core/firebase_core.dart';
import 'package:mmsn/app/globals/app_spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mmsn/app/globals/app_state.dart';
import 'package:mmsn/pages/splash/splash_screen.dart';

late final SharedPreferences sharedPrefs;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  sharedPrefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      builder: (context, child) {
        final appState =
            Provider.of<AppState>(context); // <- listen enabled by default
        return MaterialApp(
          title: 'Family Directory',
          theme: appState.theme, // now reactive
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return SafeArea(
              top: false,
              bottom: false,
              child: child ?? AppSpacing.shrink,
            );
          },
        );
      },
    );
  }
}
