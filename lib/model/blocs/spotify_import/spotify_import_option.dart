enum SpotifyImportOption {
  topArtists('Top artists'),
  followedArtists('Followed artists'),
  artistGenres('Artist genres');

  final String caption;
  const SpotifyImportOption(this.caption);
}
