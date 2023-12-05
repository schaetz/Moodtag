import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

mixin SearchBarOverlayMixin {
  String searchBarHintText = 'Search';

  final searchBarController = TextEditingController();
  bool searchBarOverlayVisible = false;
  OverlayEntry? _searchBarOverlay;

  void showSearchBarOverlay(BuildContext context, double width, Offset position) {
    searchBarOverlayVisible = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _searchBarOverlay = OverlayEntry(builder: (context) {
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
              color: Colors.transparent,
              child: SizedBox(
                  width: width,
                  child: TextField(
                      controller: searchBarController..text = '',
                      onChanged: (searchItem) => onSearchBarTextChanged(searchItem),
                      autofocus: true,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: searchBarHintText,
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.85),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
                          suffixIcon: IconButton(
                              icon: Icon(Icons.cancel, color: Colors.grey),
                              onPressed: () => onSearchBarClosePressed()))))),
        );
      });
      Overlay.of(context).insert(_searchBarOverlay!);
    });
  }

  void hideSearchBarOverlay() {
    searchBarOverlayVisible = false;
    _searchBarOverlay?.remove();
  }

  void onSearchBarTextChanged(String searchItem);

  void onSearchBarClosePressed() {
    hideSearchBarOverlay();
  }
}
