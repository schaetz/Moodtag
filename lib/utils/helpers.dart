import 'package:http/http.dart';

String dropThe(String artistName) {
  if (artistName.toLowerCase().startsWith("the ")) {
    return artistName.substring(4);
  }
  return artistName;
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

bool isHttpRequestSuccessful(Response response) {
  return response.statusCode.toString().startsWith('2');
}