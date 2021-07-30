import 'package:flutter/material.dart';
import 'package:moodtag/main.dart';

class MtBottomNavBar extends BottomNavigationBar {

  MtBottomNavBar(NavigationItem activePage, Function handleBottomNavBarTapped) : super(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.library_music),
        label: 'Artists',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.label),
        label: 'Tags',
      ),
    ],
    currentIndex: activePage.index,
    onTap: (int newIndex) {
      print(newIndex);
      if (newIndex == 1) {
        handleBottomNavBarTapped(NavigationItem.tags);
      } else {
        handleBottomNavBarTapped(NavigationItem.artists);
      }
    },
  );

}