import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/app_bar/app_bar_state.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/error_handling/error_stream_handling.dart';

class AppBarBloc extends Bloc<LibraryEvent, AppBarState> with ErrorStreamHandling {
  late final Repository _repository;

  AppBarBloc(BuildContext mainContext) : super(AppBarState()) {
    this._repository = mainContext.read<Repository>();

    on<ResetLibrary>(_handleResetLibraryEvent);

    setupErrorHandler(mainContext);
  }

  void _handleResetLibraryEvent(ResetLibrary event, Emitter<AppBarState> emit) {
    _repository.deleteAllTags();
    _repository.deleteAllArtists();
    emit(state);
  }
}
