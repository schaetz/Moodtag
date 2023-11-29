import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_state.dart';
import 'package:moodtag/model/events/artist_events.dart';

class ArtistsListScreenBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistsListBloc>();
    return BlocBuilder<ArtistsListBloc, ArtistsListState>(
        builder: (context, state) => BottomAppBar(
              child: Row(
                children: <Widget>[
                  IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.search),
                    onPressed: () {},
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
