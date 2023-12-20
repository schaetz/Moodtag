import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/library/main_screen/tags_list/tags_list_bloc.dart';
import 'package:moodtag/features/library/main_screen/tags_list/tags_list_state.dart';
import 'package:moodtag/model/events/library_events.dart';

class TagsListScreenBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TagsListBloc>();
    return BlocBuilder<TagsListBloc, TagsListState>(
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
                ],
              ),
            ));
  }
}
