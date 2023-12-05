import 'package:flutter/material.dart';

class SearchBarContainer<T> extends StatefulWidget {
  final GlobalKey listViewKey;
  final String searchBarHintText;
  final Widget contentWidget;
  final bool searchBarVisible;
  final Function(String) onSearchBarTextChanged;
  final Function() onSearchBarClosed;

  const SearchBarContainer(
      {super.key,
      required this.listViewKey,
      this.searchBarHintText = 'Search',
      required this.contentWidget,
      required this.searchBarVisible,
      required this.onSearchBarTextChanged,
      required this.onSearchBarClosed});

  @override
  State<StatefulWidget> createState() => _SearchBarContainerState();
}

class _SearchBarContainerState extends State<SearchBarContainer> {
  final searchBarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.searchBarVisible
          ? Container(
              padding: EdgeInsets.fromLTRB(2, 8, 2, 2),
              child: TextField(
                  controller: searchBarController,
                  onChanged: (searchItem) => widget.onSearchBarTextChanged(searchItem),
                  autofocus: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: widget.searchBarHintText,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.tertiary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            widget.onSearchBarClosed();
                          }))))
          : Container(),
      Expanded(child: widget.contentWidget)
    ]);
  }
}
