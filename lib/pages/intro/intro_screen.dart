import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmsn/app/globals/AppImages.dart';
import 'package:mmsn/pages/auth/cubit/auth_cubit.dart';
import 'package:mmsn/pages/auth/cubit/auth_state.dart';
import 'package:mmsn/pages/auth/login_screen.dart';
import 'package:mmsn/pages/home/main_screen.dart';
import 'package:mmsn/pages/intro/people_intro_page.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // List of advertisement images (2 per page)
  final List<String> _adImages = [
    'assets/Ads/SomaniGold.webp',
    'assets/Ads/devraj_industries.webp',
  ];

  // ---- PAGES LIST ----
  List<Widget> get _pages {
    final people = AppImages.peopleList;
    final isLoggedIn = context.read<AuthCubit>().state is AuthSuccess;

    // Chunk people into pages of 12 (4 x 3 grid)
    const int pageSize = 12;
    final List<Widget> pages = [];
    for (int i = 0; i < people.length; i += pageSize) {
      final end = (i + pageSize > people.length) ? people.length : i + pageSize;
      pages.add(PeopleIntroPage(people: people.sublist(i, end)));
    }

    // Add image slides after people pages (only if not logged in)
    if (!isLoggedIn) {
      pages.add(_buildTwoImageSlide());
    }
    
    return pages;
  }

  // ---- BUILD TWO IMAGES SLIDE ----
  Widget _buildTwoImageSlide() {
    return Column(
      children: [
        // Top Image - Takes 50% of screen height
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: Image.asset(
              _adImages[0],
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Bottom Image - Takes 50% of screen height
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: Image.asset(
              _adImages[1],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

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
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthSuccess) {
      // User already logged in → Go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // Not logged in → Go to Login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // ---- MAIN UI ----
  @override
  Widget build(BuildContext context) {
    final pages = _pages;

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
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