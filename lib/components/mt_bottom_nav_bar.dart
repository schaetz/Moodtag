import 'package:flutter/material.dart';
import 'package:moodtag/navigation/navigation_item.dart';

class MtBottomNavBar extends BottomNavigationBar {
  MtBottomNavBar(BuildContext context, NavigationItem activePage)
      : super(
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
            // if (newIndex == 0 && activePage != NavigationItem.artists) {
            //   Navigator.of(context).pushNamedAndRemoveUntil(Routes.artistsList, (route) => false);
            // } else if (newIndex == 1 && activePage != NavigationItem.tags) {
            //   Navigator.of(context).pushNamedAndRemoveUntil(Routes.tagsList, (route) => false);
            // }
          },
        );
}
