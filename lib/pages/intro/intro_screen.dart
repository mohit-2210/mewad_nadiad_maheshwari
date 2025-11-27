import 'package:flutter/material.dart';
import 'package:mmsn/app/globals/AppImages.dart';
import 'package:mmsn/pages/auth/login_screen.dart';
import 'package:mmsn/pages/intro/people_intro_page.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ---- PAGES LIST (built safely inside build using getter) ----
  List<Widget> get _pages => [
        PeopleIntroPage(people: AppImages.peopleList),
        buildIntroSlide(
          image: 'assets/intro/intro1.webp',
          title: 'Welcome to Family Directory',
          description:
              'Connect with families in your society and stay updated with community announcements.',
        ),
        buildIntroSlide(
          image: 'assets/intro/intro2.webp',
          title: 'Browse Family Profiles',
          description:
              'Discover families in your neighborhood and get to know your community members.',
        ),
        buildIntroSlide(
          image: 'assets/intro/intro3.webp',
          title: 'Stay Connected',
          description:
              'Get important society announcements and updates directly on your phone.',
        ),
        buildIntroSlide(
          image: 'assets/intro/intro4.webp',
          title: 'Get Started',
          description:
              'Join your community today and make meaningful connections with your neighbors.',
        ),
      ];

  // ---- Navigation ----
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // ---- SLIDE BUILDER ----
  Widget buildIntroSlide({
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- MAIN UI ----
  @override
  Widget build(BuildContext context) {
    final pages = _pages; // Cached for performance

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PAGE VIEW
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) => pages[index],
              ),
            ),

            // DOT INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
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

            // BUTTONS
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
                    const SizedBox(width: 60),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == pages.length - 1 ? 'Get Started' : 'Next',
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
