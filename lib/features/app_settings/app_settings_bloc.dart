import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/features/import/lastfm_import/connectors/lastfm_connector.dart' as LastFmConnector;
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config_factory.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/app_settings_events.dart';
import 'package:moodtag/shared/bloc/events/data_loading_events.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';
import 'package:moodtag/shared/bloc/extensions/error_handling/error_stream_handling.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscriber_state_mixin.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscription_sub_state.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/shared/bloc/helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/shared/exceptions/user_readable/database_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/user_readable_exception.dart';

part 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<LibraryEvent, AppSettingsState> with LibraryUserBlocMixin, ErrorStreamHandling {
  late final Repository _repository;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();
  late final StreamSubscription<LastFmAccount?> _accountStreamSubscription;

  AppSettingsBloc(this._repository, BuildContext mainContext) : super(AppSettingsState()) {
    useLibrary(_repository);
    add(RequestOrUpdateSubscription.withConfig(SubscriptionConfigFactory.getAllTagCategoriesListConfig()));

    on<CreateTagCategory>(_handleCreateTagCategoryEvent);
    on<EditTagCategory>(_handleEditTagCategoryEvent);
    on<DeleteTagCategory>(_handleDeleteTagCategoryEvent);
    on<LastFmAccountUpdated>(_handleLastFmAccountUpdatedEvent);
    on<AddLastFmAccount>(_handleAddLastFmAccountEvent);
    on<RemoveLastFmAccount>(_handleRemoveLastFmAccountEvent);
    on<UpdateLastFmAccountInfo>(_handleUpdateLastFmAccountInfoEvent);
    on<ResetLibrary>(_handleResetLibraryEvent);

    _accountStreamSubscription = _repository
        .getLastFmAccount()
        .handleError((error) => add(LastFmAccountUpdated(error: error)))
        .listen((accountName) => add(LastFmAccountUpdated(lastFmAccount: accountName)));

    // TODO Context seems not to be correct for this screen;
    // some Snackbars are only shown after returning to ArtistsList
    // (legacy from LastFmAccountManagementScreen, could be resolved by now)
    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    super.close();
    _accountStreamSubscription.cancel();
    closeErrorStreamController();
  }

  void _handleCreateTagCategoryEvent(CreateTagCategory event, Emitter<AppSettingsState> emit) async {
    final createTagCategoryResponse = await _repository.createTagCategory(event.name, color: event.color.value);
    if (createTagCategoryResponse.didFail()) {
      errorStreamController.add(createTagCategoryResponse.getUserFeedbackException());
    }
  }

  void _handleEditTagCategoryEvent(EditTagCategory event, Emitter<AppSettingsState> emit) async {
    final editTagCategoryResponse =
        await _repository.editTagCategory(event.tagCategory, name: event.newName, color: event.newColor.value);
    if (editTagCategoryResponse.didFail()) {
      errorStreamController.add(editTagCategoryResponse.getUserFeedbackException());
    }
  }

  void _handleDeleteTagCategoryEvent(DeleteTagCategory event, Emitter<AppSettingsState> emit) async {
    try {
      final deleteTagCategoryResponse =
          await _repository.removeTagCategory(event.deletedCategory, event.insertedCategory);
      if (deleteTagCategoryResponse.didFail()) {
        errorStreamController.add(deleteTagCategoryResponse.getUserFeedbackException());
      }
    } catch (exception) {
      log.warning(exception);
      if (exception is UserReadableException) {
        errorStreamController.add(exception);
      }
    }
  }

  void _handleLastFmAccountUpdatedEvent(LastFmAccountUpdated event, Emitter<AppSettingsState> emit) async {
    if (event.error != null) {
      errorStreamController
          .add(DatabaseError("The Last.fm account name could not be retrieved from the database.", cause: event.error));
      emit(state.copyWith(lastFmAccount: null, lastFmAccountLoadingStatus: LoadingStatus.error, removeAccount: true));
    } else {
      emit(state.copyWith(
          lastFmAccount: event.lastFmAccount,
          lastFmAccountLoadingStatus: LoadingStatus.success,
          removeAccount: event.lastFmAccount == null));
    }
  }

  void _handleAddLastFmAccountEvent(AddLastFmAccount event, Emitter<AppSettingsState> emit) async {
    final createdAccountUserInfo = await _createOrUpdateLastFmAccount(event.accountName);
    if (createdAccountUserInfo != null) {
      emit(state.copyWith(lastFmAccount: createdAccountUserInfo));
    }
  }

  void _handleRemoveLastFmAccountEvent(RemoveLastFmAccount event, Emitter<AppSettingsState> emit) async {
    final exception = await _createEntityBlocHelper.handleRemoveLastFmAccount(_repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _handleUpdateLastFmAccountInfoEvent(UpdateLastFmAccountInfo event, Emitter<AppSettingsState> emit) async {
    if (state.lastFmAccount == null) {
      errorStreamController
          .add(ExternalServiceQueryException('Update of Last.fm account info failed: No account configured'));
      return;
    }

    final updatedUserInfo = await _createOrUpdateLastFmAccount(state.lastFmAccount!.name);
    if (updatedUserInfo != null) {
      emit(state.copyWith(lastFmAccount: updatedUserInfo));
    }
  }

  Future<LastFmAccount?> _createOrUpdateLastFmAccount(String accountName) async {
    try {
      final userInfo = await LastFmConnector.getUserInfo(accountName);
      final exception = await _createEntityBlocHelper.handleCreateOrUpdateLastFmAccountEvent(userInfo, _repository);
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

  void _handleResetLibraryEvent(ResetLibrary event, Emitter<AppSettingsState> emit) async {
    await _repository.resetLibrary();
    emit(state);
  }
}
