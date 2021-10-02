import 'package:flutter/material.dart';

import 'models/artist.dart';
import 'models/tag.dart';

typedef NavigationItemChanged = void Function(BuildContext context, NavigationItem item);
typedef ArtistChanged = void Function(BuildContext context, Artist artist);
typedef TagChanged = void Function(BuildContext context, Tag artist);

enum NavigationItem {
  artists, tags
}