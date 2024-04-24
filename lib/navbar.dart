import 'package:flutter/material.dart';
import 'package:stickershub/screens/collection_page.dart';
import 'package:stickershub/screens/home_page.dart';
import 'package:stickershub/screens/profile_page.dart';
import 'package:stickershub/screens/clicky_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 100),
        curve: Curves.bounceInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: const <Widget>[
          ClickyPage(),
          CollectionPage(),
          ProfilePage(),
        ],
      ),

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(                                           
          topLeft: Radius.circular(30.0),                                            
          topRight: Radius.circular(30.0),                                           
        ), 
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.touch_app),
              label: 'Clicker',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book),
              label: 'Collection',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            // Add more items as needed
          ],
        ),
      ),
    );
  }
}
