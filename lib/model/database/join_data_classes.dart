import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistData {
  ArtistData(this.artist, this.tags);

  final Artist artist;
  final Set<Tag> tags;

  bool hasTag(Tag tag) => tags.contains(tag);
}

typedef ArtistsList = List<ArtistData>;

class TagData {
  TagData(this.tag, this.freq);

  final Tag tag;
  final int? freq;
}

typedef TagsList = List<TagData>;
