// Needed to pass the onBackButtonPressed function from the SpotifyImportFlow to the AppBar in the nested widget tree
class AppBarContextData {
  final Function? onBackButtonPressed;

  const AppBarContextData({this.onBackButtonPressed});
}
