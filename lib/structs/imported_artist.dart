class ImportedArtist {
  final String _name;
  final Set<String> _genres;

  ImportedArtist(this._name, this._genres);

  String get name {
    return _name;
  }

  Set<String> get genres {
    return _genres;
  }

}