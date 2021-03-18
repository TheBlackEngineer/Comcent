import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class PreHome extends StatefulWidget {
  @override
  _PreHomeState createState() => _PreHomeState();
}

class _PreHomeState extends State<PreHome> {
  int _currentIndex = 0;
  final List<Widget> tabs = [
    Home(),
    Clubs(),
    SearchScreen(),
    Notifications(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: FlashyTabBar(
        animationDuration: Duration(milliseconds: 200),
        selectedIndex: _currentIndex,
        onItemSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: [
          FlashyTabBarItem(
              icon: Icon(AntDesign.home),
              title: Text('Community'),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey),
          FlashyTabBarItem(
              icon: Icon(MaterialCommunityIcons.cards_club),
              title: Text('Clubs'),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey),
          FlashyTabBarItem(
              icon: Icon(Icons.search),
              title: Text('Search'),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey),
          FlashyTabBarItem(
              icon: Icon(Feather.bell),
              title: Text('Notifications'),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey),
        ],
      ),
    );
  }
}
