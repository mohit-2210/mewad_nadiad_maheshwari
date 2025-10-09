import 'package:shared_preferences/shared_preferences.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mmsn/globals/app_state.dart';
import 'package:mmsn/pages/splash/splash_screen.dart';

@NowaGenerated()
late final SharedPreferences sharedPrefs;

@NowaGenerated()
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  sharedPrefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

@NowaGenerated({'visibleInNowa': false})
class MyApp extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      builder: (context, child) => MaterialApp(
        title: 'Family Directory',
        theme: AppState.of(context).theme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        // Wrap every route's content in a SafeArea (top) to avoid overlap with status bar
        builder: (context, child) {
          return SafeArea(
            top: false,
            bottom: false,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
