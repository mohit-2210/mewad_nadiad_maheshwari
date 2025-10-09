import 'package:flutter/material.dart';
import 'package:mmsn/pages/home/home_tab_screen.dart';
import 'package:mmsn/pages/announcement/announcements_tab_screen.dart';
import 'package:mmsn/pages/society/society_tab_screen.dart';
import 'package:mmsn/pages/profile/profile_tab_screen.dart';
import 'package:mmsn/pages/navigationbar.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class MainScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

@NowaGenerated()
class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<AnimatedDrawerState> _drawerKey = GlobalKey<AnimatedDrawerState>();

  final List<Widget> _screens = [
    const HomeTabScreen(),
    const AnnouncementsTabScreen(),
    const SocietyTabScreen(),
    const ProfileTabScreen(),
  ];

  void openDrawer() {
    _drawerKey.currentState?.toggleDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDrawer(
      key: _drawerKey,
      showTopMenuButton: false,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens.map((screen) {
          // Pass the openDrawer function to HomeTabScreen
          if (screen is HomeTabScreen) {
            return HomeTabScreen(onDrawerToggle: openDrawer);
          }
          return screen;
        }).toList()),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey[600],
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Announcements',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.apartment),
                label: 'Society',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
