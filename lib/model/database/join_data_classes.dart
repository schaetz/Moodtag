import 'package:moodtag/model/database/moodtag_db.dart';

class TagWithArtistFreq {
  TagWithArtistFreq(this.tag, this.freq);

  final Tag tag;
  final int? freq;
}
