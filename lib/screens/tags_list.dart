import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class TagsListScreen extends StatelessWidget {

  final String title;
  final ValueChanged<Tag> onTagTapped;

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  TagsListScreen(
      {this.title, @required this.onTagTapped});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Consumer<Library>(
        builder: (context, library, child) {
          return ListView.separated(
            separatorBuilder: (pro, context) => Divider(color: Colors.black),
            padding: EdgeInsets.all(16.0),
            itemCount: library.tags.length,
            itemBuilder: (context, i) {
              return _buildTagRow(library.tags[i], onTagTapped);
            },
          );
        }
      ),
    );
  }

  Widget _buildTagRow(Tag tag, ValueChanged<Tag> onTapped) {
    return ListTile(
      title: Text(
        tag.name,
        style: listEntryStyle,
      ),
      onTap: () => onTagTapped(tag),
    );
  }

}
