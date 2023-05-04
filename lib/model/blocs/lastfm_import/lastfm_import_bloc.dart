import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/database_error.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_state.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/lastfm_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/utils/user_properties_index.dart';

class LastFmImportBloc extends Bloc<LibraryEvent, LastFmImportState> with ErrorStreamHandling {
  final Repository _repository;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  late final StreamSubscription<String?> _accountNameStreamSubscription;

  LastFmImportBloc(this._repository, BuildContext mainContext) : super(LastFmImportState()) {
    on<LastFmAccountUpdated>(_mapLastFmAccountUpdatedEventToState);
    on<AddLastFmAccount>(_mapAddLastFmAccountEventToState);
    on<RemoveLastFmAccount>(_mapRemoveLastFmAccountEventToState);

    _accountNameStreamSubscription = _repository
        .getUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME)
        .handleError((error) => add(LastFmAccountUpdated(error: error)))
        .listen((accountName) => add(LastFmAccountUpdated(accountName: accountName)));

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() {
    _accountNameStreamSubscription.cancel();
    return super.close();
  }

  void _mapLastFmAccountUpdatedEventToState(LastFmAccountUpdated event, Emitter<LastFmImportState> emit) async {
    if (event.error != null) {
      errorStreamController.add(DatabaseError("The Last.fm account name could not be retrieved from the database."));
      emit(state.copyWith(accountName: null, accountNameLoadingStatus: LoadingStatus.error));
    } else {
      emit(state.copyWith(
          updateAccountName: true, accountName: event.accountName, accountNameLoadingStatus: LoadingStatus.success));
    }
  }

  void _mapAddLastFmAccountEventToState(AddLastFmAccount event, Emitter<LastFmImportState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateOrUpdateUserPropertyEvent(
        UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME, event.accountName, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _mapRemoveLastFmAccountEventToState(RemoveLastFmAccount event, Emitter<LastFmImportState> emit) async {
    final exception = await _createEntityBlocHelper.handleRemoveUserPropertyEvent(
        UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }
}
