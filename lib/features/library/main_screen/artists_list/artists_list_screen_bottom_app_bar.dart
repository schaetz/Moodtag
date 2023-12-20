import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_state.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/library_events.dart';

class ArtistsListScreenBottomAppBar extends StatelessWidget {
  final searchBarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistsListBloc>();
    return BlocBuilder<ArtistsListBloc, ArtistsListState>(
        builder: (context, state) => BottomAppBar(
              child: Row(
                children: <Widget>[
                  state.displaySearchBar
                      ? IconButton(
                          tooltip: 'Close search',
                          icon: const Icon(Icons.search_off),
                          onPressed: () => bloc.add(ToggleSearchBar()),
                        )
                      : IconButton(
                          tooltip: 'Search',
                          icon: const Icon(Icons.search),
                          onPressed: () => bloc.add(ToggleSearchBar()),
                        ),
                  IconButton(
                    tooltip: 'Filter',
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => bloc.add(ToggleFilterSelectionModal()),
                  ),
                  IconButton(
                    tooltip: state.displayTagSubtitles ? 'Hide Tags' : 'Show Tags',
                    icon: state.displayTagSubtitles ? const Icon(Icons.label_off) : const Icon(Icons.label),
                    onPressed: () => bloc.add(ToggleTagSubtitles()),
                  ),
                ],
              ),
            ));
  }
}
