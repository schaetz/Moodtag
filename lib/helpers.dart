import 'models/artist.dart';
import 'models/tag.dart';

String dropThe(String artistName) {
  if (artistName.toLowerCase().startsWith("the ")) {
    return artistName.substring(4);
  }
  return artistName;
}

extension ArtistList on List<Artist> {

  void sortArtistNames() => this.sort((a,b) => dropThe(a.name.toLowerCase())
      .compareTo(dropThe(b.name.toLowerCase())));

}

extension TagList on List<Tag> {
  
  void sortTags() => this.sort((a,b) => a.name.toLowerCase()
      .compareTo(b.name.toLowerCase()));
  
}

List<String> processMultilineInput(String input) {
  List<String> elementsWithDuplicates = input.split("\n");
  elementsWithDuplicates = elementsWithDuplicates
      .map((element) => element.trim()).toList();
  elementsWithDuplicates.retainWhere((element) => element.isNotEmpty);
  Set<String> uniqueElements = elementsWithDuplicates.toSet();
  return uniqueElements.toList();
}

List<T> createListWithSingleElementOrEmpty<T>(T elementOrNull) {
  return elementOrNull != null ? [elementOrNull] : [];
}