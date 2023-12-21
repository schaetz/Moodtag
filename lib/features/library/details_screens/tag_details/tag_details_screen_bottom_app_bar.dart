import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_bloc.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_state.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';

class TagDetailsScreenBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TagDetailsBloc>();
    return BlocBuilder<TagDetailsBloc, TagDetailsState>(
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
                    tooltip: 'Checklist mode',
                    icon: state.checklistMode ? const Icon(Icons.list_alt) : const Icon(Icons.ballot),
                    onPressed: () => bloc.add(ToggleChecklistMode()),
                  ),
                ],
              ),
            ));
  }
}
