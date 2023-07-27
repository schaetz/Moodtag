import 'package:bloc/bloc.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_state.dart';
import 'package:moodtag/model/events/import_events.dart';

class AbstractImportBloc<S extends AbstractImportState> extends Bloc<ImportEvent, S> {
  AbstractImportBloc(super.initialState);
}
