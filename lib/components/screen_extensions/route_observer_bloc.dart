import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/abstract_bloc_state.dart';
import 'package:moodtag/model/events/library_events.dart';

/// Mixin for a Bloc that handles the ActiveScreenChanged event
/// for a RouteObserverScreen
mixin RouteObserverBloc<S extends AbstractBlocState> on Bloc<LibraryEvent, S> {}
