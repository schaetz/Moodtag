String insertEmojisIntoLogStatement(String logStatement) {
  String result = logStatement;
  result = result.replaceAllMapped(RegExp(r'\b(\w+Bloc)\b'), (match) => _replaceBlocName(match.group(1)));
  result = result.replaceAllMapped(RegExp(r'\[dataType: ([a-zA-Z<>]+); ([^\]]+)\]'),
      (match) => '🚰 [dataType: ${_replaceDataType(match.group(1))}; ${_replaceFilterString(match.group(2))}]');
  result =
      result.replaceAllMapped(RegExp(r'\s%(\w+)'), (match) => match.group(1) != null ? ' 🎈' + match.group(1)! : ' 🎈');
  return result;
}

String _replaceBlocName(String? blocNameString) {
  if (blocNameString == null) {
    return '';
  }
  switch (blocNameString) {
    case 'ArtistsListBloc':
      return '🟦 $blocNameString';
    case 'ArtistDetailsBloc':
      return '🟪 $blocNameString';
    case 'TagsListBloc':
      return '🟨 $blocNameString';
    case 'TagDetailsBloc':
      return '🟧 $blocNameString';
    default:
      return '⬜ $blocNameString';
  }
}

String _replaceDataType(String? dataTypeString) {
  if (dataTypeString == null) {
    return '';
  }
  switch (dataTypeString) {
    case 'ArtistData':
      return '🎸$dataTypeString';
    case 'List<ArtistData>':
      return '📋List<🎸ArtistData>';
    case 'TagData':
      return '🏷️$dataTypeString';
    case 'List<TagData>':
      return '📋List<🏷️TagData>';
    default:
      return dataTypeString;
  }
}

String _replaceFilterString(String? filterString) {
  if (filterString == null) {
    return '';
  } else if (filterString == 'ALL') {
    return '💯$filterString';
  }

  String result = filterString;
  result = result.replaceAllMapped(RegExp(r'\bsearchId: (\d+)'), (match) => '#️⃣searchId: ${match.group(1)}');
  result = result.replaceAllMapped(RegExp(r'\bsearchItem: ("\w*")'), (match) => '🔎searchItem: ${match.group(1)}');
  return result;
}
