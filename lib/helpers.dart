import 'models/artist.dart';
import 'models/tag.dart';

String dropThe(String artistName) {
  if (artistName.toLowerCase().startsWith("the ")) {
    return artistName.substring(4);
  }
  return artistName;
}

extension ArtistList on List<Artist> {

  void sortArtistNames() => this.sort((a,b) => dropThe(a.name).compareTo(dropThe(b.name)));

}

extension TagList on List<Tag> {
  
  void sortTags() => this.sort((a,b) => a.name.compareTo(b.name));
  
}