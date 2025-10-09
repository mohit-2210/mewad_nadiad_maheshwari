import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedDrawer extends StatefulWidget {
  final Widget child;
  final bool showTopMenuButton;
  const AnimatedDrawer({super.key, required this.child, this.showTopMenuButton = true});

  @override
  State<AnimatedDrawer> createState() => AnimatedDrawerState();
}

class AnimatedDrawerState extends State<AnimatedDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Smooth curve
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );
  }

  void toggleDrawer() {
    if (isDrawerOpen) {
      _controller.reverse();
      setState(() => isDrawerOpen = false);
    } else {
      _controller.forward();
      setState(() => isDrawerOpen = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF4F5BD5), // Drawer background color
      body: Stack(
        children: [
          /// Drawer Content
          _buildDrawerContent(),

          /// Main Screen with Transform Animation
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              double slide = 250 * _animation.value;
              double scale = 1 - (_animation.value * 0.15);
              double borderRadius = 40 * _animation.value;
              double tilt = (_animation.value * -0.1);

              return Transform(
                transform: Matrix4.identity()
                  ..translate(slide)
                  ..scale(scale)
                  ..rotateZ(tilt),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    if (isDrawerOpen) toggleDrawer();
                  },
                  child: AbsorbPointer(
                    absorbing: isDrawerOpen,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        boxShadow: [
                          if (isDrawerOpen)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          widget.child,

                          /// Menu Button with Safe Padding (optional)
                          if (widget.showTopMenuButton)
                            Positioned(
                              top: safeTop + 16,
                              left: 20,
                              child: Material(
                                color: Colors.white.withOpacity(0.8),
                                elevation: 3,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: toggleDrawer,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      isDrawerOpen ? Icons.close : Icons.menu,
                                      color: Colors.black87,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Drawer Layout
  Widget _buildDrawerContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 100, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),

          _drawerItem(Icons.policy, "Terms & Conditions", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
            );
          }),

          _drawerItem(Icons.privacy_tip, "Privacy Policy", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            );
          }),

          _drawerItem(Icons.info_outline, "About", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            );
          }),

          _drawerItem(Icons.color_lens, "Theme", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
            );
          }),

          _drawerItem(Icons.language, "Language", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LanguageSettingsScreen()),
            );
          }),

          _drawerItem(Icons.settings, "Settings", onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example placeholder screens (remove later)
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Terms & Conditions")));
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Privacy Policy")));
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("About")));
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Theme")));
}

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Language")));
}

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Settings")));
}
