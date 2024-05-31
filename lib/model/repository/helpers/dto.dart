import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistWithTagsDTO {
  final ArtistDataClass artist;
  final List<TagDataClass> tags;

  ArtistWithTagsDTO({required this.artist, required this.tags});
}

class TagWithDataDTO {
  final TagDataClass tag;
  final TagCategoryDataClass category;
  final int frequency;

  TagWithDataDTO({required this.tag, required this.category, required this.frequency});
}
