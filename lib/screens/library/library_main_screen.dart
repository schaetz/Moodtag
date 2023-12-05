import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_main_scaffold.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/tags_list/tags_list_bloc.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/screens/library/artists_list_screen.dart';
import 'package:moodtag/screens/library/artists_list_screen_bottom_app_bar.dart';
import 'package:moodtag/screens/library/tags_list_screen.dart';
import 'package:moodtag/screens/library/tags_list_screen_bottom_app_bar.dart';

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
    return MtMainScaffold(
        scaffoldKey: _scaffoldKey,
        tabController: _tabController..addListener(() {}),
        pageWidget: TabBarView(
          controller: _tabController,
          children: [
            ArtistsListScreen(_scaffoldKey, parentTabController: _tabController, parentTabViewIndex: 0),
            TagsListScreen(_scaffoldKey)
          ],
        ),
        bottomNavigationBar:
            isArtistsListScreenSelected ? ArtistsListScreenBottomAppBar() : TagsListScreenBottomAppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => handleAddButtonPressed(context),
          child: const Icon(Icons.add),
        ));
  }

  void handleAddButtonPressed(BuildContext context) {
    if (isArtistsListScreenSelected) {
      final artistsListBloc = context.read<ArtistsListBloc>();
      AddEntityDialog.openAddArtistDialog(context, onSendInput: (input) => artistsListBloc.add(CreateArtists(input)));
    } else {
      final tagsListBloc = context.read<TagsListBloc>();
      AddEntityDialog.openAddTagDialog(context, onSendInput: (input) => tagsListBloc.add(CreateTags(input)));
    }
  }
}
