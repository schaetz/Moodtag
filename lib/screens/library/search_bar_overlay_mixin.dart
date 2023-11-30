import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

mixin SearchBarOverlayMixin {
  String searchBarHintText = 'Search';

  final searchBarController = TextEditingController();
  bool searchBarOverlayVisible = false;
  OverlayEntry? _searchBarOverlay;

  void showSearchBarOverlay(BuildContext context) {
    searchBarOverlayVisible = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _searchBarOverlay = OverlayEntry(builder: (context) {
        return Positioned(
          right: MediaQuery.of(context).size.width * 0.1,
          bottom: MediaQuery.of(context).size.height * 0.14,
          child: Material(
              color: Colors.transparent,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
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
                              onPressed: () => onSearchBarClearPressed()))))),
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

  void onSearchBarClearPressed() {
    searchBarController.text = '';
  }
}
