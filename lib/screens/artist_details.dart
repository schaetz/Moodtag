import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/main.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class ArtistDetailsPage extends Page {
  final String title;
  final Artist artist;
  final ValueChanged<NavigationItem> onBottomNavBarTapped;
  final ValueChanged<Tag> onTagTapped;

  ArtistDetailsPage({
    this.title,
    @required this.artist,
    @required this.onBottomNavBarTapped,
    @required this.onTagTapped
  }) : super(key: ValueKey(artist));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return ArtistDetailsScreen(
              title: title,
              artist: artist,
              onBottomNavBarTapped: onBottomNavBarTapped,
              onTagTapped: onTagTapped,
          );
        });
  }
}

class ArtistDetailsScreen extends StatelessWidget {
  final String title;
  final Artist artist;
  final ValueChanged<NavigationItem> onBottomNavBarTapped;
  final ValueChanged<Tag> onTagTapped;

  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  ArtistDetailsScreen({
    @required this.title,
    @required this.artist,
    @required this.onBottomNavBarTapped,
    @required this.onTagTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Consumer<Library>(
        builder: (context, library, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(artist.name, style: artistNameStyle),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _buildTagChipsRow(artist.tags),
                )
              ]
            ),
          );
        }
      ),
      bottomNavigationBar: MtBottomNavBar(onBottomNavBarTapped),
    );
  }

  List<Widget> _buildTagChipsRow(List<Tag> tags) {
    return tags.map((tag) =>
      _buildTagChip(tag, (value) { })
    ).toList();
  }

  Widget _buildTagChip(Tag tag, ValueChanged<Tag> onTapped) {
    return GestureDetector(
      onTap: () => onTagTapped(tag),
      child: Chip(
          label: Text(tag.name),
      ),
    );
  }

}
