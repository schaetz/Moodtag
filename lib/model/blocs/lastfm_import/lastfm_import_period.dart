enum LastFmImportPeriod {
  overall('overall', 'overall'),
  twelve_month('12month', '12 months'),
  six_month('6month', '6 months'),
  three_month('3month', '3 months'),
  one_month('1month', '1 month'),
  seven_day('7day', '7 days');

  const LastFmImportPeriod(this.apiStringId, this.humanReadableString);
  final String apiStringId;
  final String humanReadableString;
}
