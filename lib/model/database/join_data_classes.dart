import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistWithTagFlag {
  ArtistWithTagFlag(this.artist, this.tagId, this.hasTag);

  final Artist artist;
  final int tagId;
  final bool hasTag;
}

class TagWithArtistFreq {
  TagWithArtistFreq(this.tag, this.freq);

  final Tag tag;
  final int? freq;
}
