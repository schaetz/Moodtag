import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/app_bar/app_bar_state.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';
import 'package:moodtag/shared/bloc/extensions/error_handling/error_stream_handling.dart';

class AppBarBloc extends Bloc<LibraryEvent, AppBarState> with ErrorStreamHandling {
  AppBarBloc(BuildContext mainContext) : super(AppBarState()) {}

  @override
  Future<void> close() async {
    super.close();
    closeErrorStreamController();
  }
}
