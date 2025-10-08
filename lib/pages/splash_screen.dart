import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:mmsn/main.dart';
import 'package:mmsn/auth_service.dart';
import 'package:mmsn/pages/main_screen.dart';
import 'package:mmsn/pages/login_screen.dart';
import 'package:mmsn/pages/intro_screen.dart';

@NowaGenerated()
class SplashScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

@NowaGenerated()
class _SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      sharedPrefs.getBool('test');
    } catch (e) {}
    setState(() {
      _isVisible = true;
    });
    await AuthService.instance.loadCurrentUser();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      if (AuthService.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        bool hasSeenIntro = false;
        try {
          hasSeenIntro = sharedPrefs.getBool('hasSeenIntro') ?? false;
        } catch (e) {
          hasSeenIntro = false;
        }
        if (hasSeenIntro) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const IntroScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _isVisible ? 1 : 0.8,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _isVisible ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 800),
              child: AnimatedScale(
                scale: _isVisible ? 1 : 0.9,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                child: FlexSizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 40,
                  child: const Text(
                    'Family Directory',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 1200),
              child: Text(
                'Connect with your community',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: const Duration(milliseconds: 1500),
              child: AnimatedScale(
                scale: _isVisible ? 1 : 0.8,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
