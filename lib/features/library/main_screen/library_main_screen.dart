import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/library/main_screen/artists_list/artists_list_bloc.dart';
import 'package:moodtag/features/library/main_screen/tags_list/tags_list_bloc.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/dialogs/alert_dialog_factory.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_main_scaffold.dart';

import 'artists_list/artists_list_screen.dart';
import 'artists_list/artists_list_screen_bottom_app_bar.dart';
import 'tags_list/tags_list_screen.dart';
import 'tags_list/tags_list_screen_bottom_app_bar.dart';

class LibraryMainScreen extends StatefulWidget {
  final bool startOnArtistsList = true;

  LibraryMainScreen();
  LibraryMainScreen.artistsList({startOnArtistsList = true});
  LibraryMainScreen.tagsList({startOnArtistsList = false});

  @override
  State<StatefulWidget> createState() => _LibraryMainScreenState(startOnArtistsList);
}

/// [AnimationController]s can be created with `vsync: this` because of [TickerProviderStateMixin].
/// See https://api.flutter.dev/flutter/material/TabBar-class.html
class _LibraryMainScreenState extends State<LibraryMainScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late final TabController _tabController;
  bool isArtistsListScreenSelected;

  AlertDialogFactory? _dialogFactory;

  _LibraryMainScreenState(this.isArtistsListScreenSelected);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          isArtistsListScreenSelected = _tabController.index == 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    this._dialogFactory = context.read<AlertDialogFactory>();

    return MtMainScaffold(
        scaffoldKey: _scaffoldKey,
        tabController: _tabController,
        pageWidget: TabBarView(
          controller: _tabController,
          children: [
            ArtistsListScreen(_scaffoldKey, parentTabController: _tabController, parentTabViewIndex: 0),
            TagsListScreen()
          ],
        ),
        bottomNavigationBar:
            isArtistsListScreenSelected ? ArtistsListScreenBottomAppBar() : TagsListScreenBottomAppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => handleAddButtonPressed(context),
          child: isArtistsListScreenSelected ? const Icon(Icons.library_add) : const Icon(Icons.new_label),
        ));
  }

  void handleAddButtonPressed(BuildContext context) {
    if (isArtistsListScreenSelected) {
      final artistsListBloc = context.read<ArtistsListBloc>();
      _dialogFactory
          ?.getSingleTextInputDialog(context,
              title: 'Create new artist(s)',
              subtitle: 'Separate multiple artists by line breaks',
              multiline: true,
              maxLines: 10)
          .show(onTruthyResult: (input) => artistsListBloc.add(CreateArtists(input!)));
    } else {
      final tagsListBloc = context.read<TagsListBloc>();
      _dialogFactory
          ?.getSingleTextInputDialog(context,
              title: 'Create new tag(s)',
              subtitle: 'Separate multiple tags by line breaks',
              multiline: true,
              maxLines: 10)
          .show(onTruthyResult: (input) => tagsListBloc.add(CreateTags(input!)));
    }
  }
}
