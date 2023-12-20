import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/features/import/lastfm_import/connectors/lastfm_connector.dart' as LastFmConnector;
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/lastfm_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/error_handling/error_stream_handling.dart';
import 'package:moodtag/shared/bloc/helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/shared/exceptions/user_readable/database_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/user_readable_exception.dart';

import 'lastfm_account_management_state.dart';

class LastFmAccountManagementBloc extends Bloc<LastFmEvent, LastFmAccountManagementState> with ErrorStreamHandling {
  late final Repository _repository;
  final CreateEntityBlocHelper createEntityBlocHelper = CreateEntityBlocHelper();
  late final StreamSubscription<LastFmAccount?> _accountStreamSubscription;

  LastFmAccountManagementBloc(this._repository, BuildContext mainContext) : super(LastFmAccountManagementState()) {
    on<LastFmAccountUpdated>(_handleLastFmAccountUpdatedEvent);
    on<AddLastFmAccount>(_handleAddLastFmAccountEvent);
    on<RemoveLastFmAccount>(_handleRemoveLastFmAccountEvent);
    on<UpdateLastFmAccountInfo>(_handleUpdateLastFmAccountInfoEvent);

    _accountStreamSubscription = _repository
        .getLastFmAccount()
        .handleError((error) => add(LastFmAccountUpdated(error: error)))
        .listen((accountName) => add(LastFmAccountUpdated(lastFmAccount: accountName)));

    // TODO Context seems not to be correct for LastFmImportScreen;
    //  some Snackbars are only shown after returning to ArtistsList
    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() {
    _accountStreamSubscription.cancel();
    return super.close();
  }

  void _handleLastFmAccountUpdatedEvent(LastFmAccountUpdated event, Emitter<LastFmAccountManagementState> emit) async {
    if (event.error != null) {
      errorStreamController
          .add(DatabaseError("The Last.fm account name could not be retrieved from the database.", cause: event.error));
      emit(state.copyWith(lastFmAccount: null, accountNameLoadingStatus: LoadingStatus.error, removeAccount: true));
    } else {
      emit(state.copyWith(
          lastFmAccount: event.lastFmAccount,
          accountNameLoadingStatus: LoadingStatus.success,
          removeAccount: event.lastFmAccount == null));
    }
  }

  void _handleAddLastFmAccountEvent(AddLastFmAccount event, Emitter<LastFmAccountManagementState> emit) async {
    final createdAccountUserInfo = await _createOrUpdateLastFmAccount(event.accountName);
    if (createdAccountUserInfo != null) {
      emit(state.copyWith(lastFmAccount: createdAccountUserInfo));
    }
  }

  void _handleRemoveLastFmAccountEvent(RemoveLastFmAccount event, Emitter<LastFmAccountManagementState> emit) async {
    final exception = await createEntityBlocHelper.handleRemoveLastFmAccount(_repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _handleUpdateLastFmAccountInfoEvent(
      UpdateLastFmAccountInfo event, Emitter<LastFmAccountManagementState> emit) async {
    if (state.lastFmAccount == null) {
      errorStreamController
          .add(ExternalServiceQueryException('Update of Last.fm account info failed: No account configured'));
      return;
    }

    final updatedUserInfo = await _createOrUpdateLastFmAccount(state.lastFmAccount!.accountName);
    if (updatedUserInfo != null) {
      emit(state.copyWith(lastFmAccount: updatedUserInfo));
    }
  }

  Future<LastFmAccount?> _createOrUpdateLastFmAccount(String accountName) async {
    try {
      final userInfo = await LastFmConnector.getUserInfo(accountName);
      final exception = await createEntityBlocHelper.handleCreateOrUpdateLastFmAccountEvent(userInfo, _repository);
      if (exception != null) {
        errorStreamController.add(exception);
      } else {
        return userInfo;
      }
    } on UserReadableException catch (e) {
      errorStreamController.add(e);
    } catch (e) {
      errorStreamController
          .add(ExternalServiceQueryException('The request to the Last.fm API failed for an unknown reason.', cause: e));
    }
    return null;
  }
}
