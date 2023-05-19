import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistData {
  ArtistData(this.artist, this.tags);

  final Artist artist;
  final Set<Tag> tags;
}

class ArtistWithTagFlag {
  ArtistWithTagFlag(this.artist, this.tagId, this.hasTag);

  final Artist artist;
  final int tagId;
  final bool hasTag;
}

class TagData {
  TagData(this.tag, this.freq);

  final Tag tag;
  final int? freq;
}
