import 'package:flutter/material.dart';
import 'package:mmsn/app/helpers/gap.dart';
import 'dart:async';
import 'package:mmsn/models/family.dart';
import 'package:mmsn/pages/family/family_directory_screen.dart';
import 'package:mmsn/data_service.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/pages/auth/data/auth_service.dart';
import 'package:mmsn/components/family_card.dart';
import 'package:mmsn/pages/family/family_details_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key, this.onDrawerToggle});

  final VoidCallback? onDrawerToggle;

  @override
  State<HomeTabScreen> createState() {
    return _HomeTabScreenState();
  }
}

class _HomeTabScreenState extends State<HomeTabScreen> with TickerProviderStateMixin {
  final PageController _carouselController = PageController();

  int _currentCarouselIndex = 0;

  Timer? _carouselTimer;

  List<String> _carouselImages = [];

  List<Family> _recentFamilies = [];

  bool _isLoading = true;

  late AnimationController _headerAnimationController;

  late AnimationController _carouselAnimationController;

  late AnimationController _listAnimationController;

  late Animation<double> _headerFadeAnimation;

  late Animation<Offset> _headerSlideAnimation;

  late Animation<double> _carouselScaleAnimation;


  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _carouselTimer?.cancel();
    _headerAnimationController.dispose();
    _carouselAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _carouselAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.easeOutBack,
          ),
        );
    _carouselScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _carouselAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _setupFamilyAnimations(int count) {
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselImages.isNotEmpty && _carouselController.hasClients) {
        final nextIndex = (_currentCarouselIndex + 1) % _carouselImages.length;
        _carouselController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final images = DataService.instance.carouselImages;
      final families = await DataService.instance.getFamilies();
      setState(() {
        _carouselImages = images;
        _recentFamilies = families.take(3).toList();
        _isLoading = false;
      });
      _setupFamilyAnimations(_recentFamilies.length);
      _headerAnimationController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _carouselAnimationController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      _listAnimationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthApiService.instance.currentUser;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingAnimation()
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: SlideTransition(
                          position: _headerSlideAnimation,
                          child: _buildAnimatedHeader(currentUser),
                        ),
                      ),
                      Gap.s24H(),
                      if (_carouselImages.isNotEmpty)
                        ScaleTransition(
                          scale: _carouselScaleAnimation,
                          child: _buildEnhancedCarousel(size),
                        ),
                      Gap.s32H(),
                      _buildAnimatedFamilySection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) => Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Gap.s24H(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: const Text(
                'Loading your community...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(User? currentUser) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: widget.onDrawerToggle,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'home_profile_${currentUser?.id ?? 'unknown'}',
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: currentUser?.profileImage != null
                            ? NetworkImage(currentUser!.profileImage!)
                            : null,
                        child: currentUser?.profileImage == null
                            ? const Icon(Icons.person, size: 35)
                            : null,
                      ),
                    ),
                    // Hamburger menu icon overlay (visual indicator only)
                    if (widget.onDrawerToggle != null)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Gap.s16W(),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    currentUser?.fullName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCarousel(Size size) {
    return Container(
      height: size.height * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _carouselController,
              onPageChanged: (index) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
              itemCount: _carouselImages.length,
              itemBuilder: (context, index) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: Image(
                    image: AssetImage(_carouselImages[index]),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _carouselImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentCarouselIndex == index ? 32 : 8,
                    decoration: BoxDecoration(
                      color: _currentCarouselIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _currentCarouselIndex == index
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
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

  Widget _buildAnimatedFamilySection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Animated "Family Directory" title
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) => Transform.translate(
              offset: Offset(-30 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            ),
            child: Text(
              'Family Directory',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),

          // Animated "View All" button
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
            builder: (context, value, child) => Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            ),
            child: TextButton(
              onPressed: () {
                // Navigate safely to FamilyDirectoryScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FamilyDirectoryScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('View All'),
                  Gap.s4W(),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      Gap.s16H(),

      // Recent families list
      if (_recentFamilies.isEmpty)
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                  Gap.s12H(),
                  const Text('No families found'),
                ],
              ),
            ),
          ),
        )
      else
        Column(
          children: _recentFamilies.asMap().entries.map((entry) {
            final index = entry.key;
            final family = entry.value;

            // Slide animation for each family card
            final slideAnimation = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _listAnimationController,
                curve: Interval(
                  index * 0.2,
                  (index * 0.2) + 0.6,
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: FamilyCard(
                  family: family,
                  heroTagPrefix: 'home_family',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FamilyDetailsScreen(familyId: family.id),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
    ],
  );
}

}
