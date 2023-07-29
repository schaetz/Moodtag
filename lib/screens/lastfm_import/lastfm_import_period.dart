enum LastFmImportPeriod { overall, seven_day, one_month, three_month, six_month, twelve_month }

String getLastFmImportPeriodString(LastFmImportPeriod period) {
  switch (period) {
    case LastFmImportPeriod.overall:
      return 'overall';
    case LastFmImportPeriod.seven_day:
      return '7day';
    case LastFmImportPeriod.one_month:
      return '1month';
    case LastFmImportPeriod.three_month:
      return '3month';
    case LastFmImportPeriod.six_month:
      return '6month';
    case LastFmImportPeriod.twelve_month:
      return '12month';
  }
}
