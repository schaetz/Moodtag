import 'package:flutter/material.dart';

// Source: https://stackoverflow.com/a/54582062/4602192
class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar({required this.color, required this.tabBar});

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: Material(type: MaterialType.transparency, child: tabBar),
      );
}
