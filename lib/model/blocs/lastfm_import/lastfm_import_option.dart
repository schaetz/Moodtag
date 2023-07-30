enum LastFmImportOption {
  allTimeTopArtists('All-time top artists'),
  lastMonthTopArtists('Last month\'s top artists'),
  topTags('Top tags by all users'),
  userTags('My own tags');

  final String caption;
  const LastFmImportOption(this.caption);
}
