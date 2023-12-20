import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';

/// Mixin for a Bloc that handles the ActiveScreenChanged event
/// for a RouteObserverScreen
mixin RouteObserverBloc<S extends Equatable> on Bloc<LibraryEvent, S> {}
