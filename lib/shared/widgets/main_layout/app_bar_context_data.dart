// Needed to pass the onBackButtonPressed function from the import flow to the AppBar in the nested widget tree

class AppBarContextData {
  final Function? onBackButtonPressed;

  const AppBarContextData({this.onBackButtonPressed});
}
