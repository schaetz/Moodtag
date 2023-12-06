import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/events/library_events.dart';

mixin SearchableListScreenMixin<B extends Bloc> {
  void onSearchBarTextChanged(String searchItem, B bloc) {
    bloc.add(ChangeSearchItem(searchItem));
  }

  void onSearchBarClosed(B bloc) {
    bloc.add(ToggleSearchBar());
  }
}
