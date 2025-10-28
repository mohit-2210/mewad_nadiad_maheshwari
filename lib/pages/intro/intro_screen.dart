import 'package:flutter/material.dart';
import 'package:mmsn/app/globals/app_spacing.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'package:mmsn/pages/intro/intro_page.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:mmsn/main.dart';
import 'package:mmsn/pages/auth/login_screen.dart';

@NowaGenerated()
class IntroScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() {
    return _IntroScreenState();
  }
}

@NowaGenerated()
class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<IntroPage> _pages = [
    IntroPage(
      image: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=600',
      title: 'Welcome to Family Directory',
      description:
          'Connect with families in your society and stay updated with community announcements.',
    ),
    IntroPage(
      image:
          'https://images.unsplash.com/photo-1582407947304-fd86f028f716?w=600',
      title: 'Browse Family Profiles',
      description:
          'Discover families in your neighborhood and get to know your community members.',
    ),
    IntroPage(
      image:
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600',
      title: 'Stay Connected',
      description:
          'Get important society announcements and updates directly on your phone.',
    ),
    IntroPage(
      image:
          'https://images.unsplash.com/photo-1600047509358-9dc75507daeb?w=600',
      title: 'Get Started',
      description:
          'Join your community today and make meaningful connections with your neighbors.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishIntro();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishIntro() {
    sharedPrefs.setBool('hasSeenIntro', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishIntro,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image(
                            image: NetworkImage(page.image),
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Gap.s40H(),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Gap.s16H(),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    )
                  else
                    AppSpacing.shrink,
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
