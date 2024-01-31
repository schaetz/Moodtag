import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/app_settings/app_settings_bloc.dart';
import 'package:moodtag/features/app_settings/lastfm_account_management/lastfm_account_selector.dart';
import 'package:moodtag/features/app_settings/tag_categories/create_tag_category_dialog_form.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_auth_bloc.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/shared/bloc/events/app_settings_events.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';
import 'package:moodtag/shared/bloc/events/spotify_events.dart';
import 'package:moodtag/shared/dialogs/components/alert_dialog_factory.dart';
import 'package:moodtag/shared/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/shared/widgets/data_display/loaded_data_display_wrapper.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_app_bar.dart';

class AppSettingsScreen extends StatelessWidget {
  static const headlineTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 22);
  final String serviceName = 'Last.fm';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppSettingsBloc>();
    final dialogFactory = context.read<AlertDialogFactory>();

    return Scaffold(
        appBar: MtAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<AppSettingsBloc, AppSettingsState>(
              buildWhen: (previous, current) => current.lastFmAccountLoadingStatus == LoadingStatus.success,
              builder: (context, state) {
                return SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Tag categories', style: headlineTextStyle),
                  _buildTagCategoriesSection(context, bloc, state, dialogFactory),
                  _buildDividerWithPadding(),
                  Text('Import', style: headlineTextStyle),
                  _buildImportSection(context, bloc, state, dialogFactory),
                  _buildDividerWithPadding(),
                  Text('Library', style: headlineTextStyle),
                  _buildLibrarySection(context, bloc, dialogFactory),
                ]));
              }),
        ));
  }

  Padding _buildDividerWithPadding() => Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: Divider());

  Widget _buildTagCategoriesSection(
      BuildContext context, AppSettingsBloc bloc, AppSettingsState state, AlertDialogFactory dialogFactory) {
    return Column(children: [
      Card(
          child: LoadedDataDisplayWrapper(
              loadedData: state.allTagCategories,
              buildOnSuccess: (tagCategories) => Column(
                      children: tagCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final categoryData = entry.value;
                    final tagCategory = categoryData.tagCategory;
                    return ListTile(
                      leading: Icon(
                        Icons.circle,
                        color: Color(tagCategory.color),
                      ),
                      title: Text(entry.value.name),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => CreateTagCategoryDialogForm(
                                  isEditForm: true,
                                  initialName: tagCategory.name,
                                  initialColor: Color(tagCategory.color),
                                  onSendInput: (nameInput, colorInput) => bloc
                                      .add(EditTagCategory(tagCategory, newName: nameInput, newColor: colorInput)))),
                        ),
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => dialogFactory
                                .getConfirmationDialog(
                                  context,
                                  title: 'Are you sure that you want to delete the tag category "${tagCategory.name}"?',
                                )
                                .show(onTruthyResult: (_) => bloc.add(DeleteTagCategory(tagCategory))))
                      ]),
                      shape: index < tagCategories.length - 1
                          ? Border(
                              bottom: BorderSide(),
                            )
                          : null,
                    );
                  }).toList()))),
      Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add category'),
              onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => CreateTagCategoryDialogForm(
                        onSendInput: (nameInput, colorInput) =>
                            bloc.add(CreateTagCategory(nameInput, color: colorInput))),
                  )))
    ]);
  }

  Widget _buildImportSection(
      BuildContext context, AppSettingsBloc bloc, AppSettingsState state, AlertDialogFactory dialogFactory) {
    // TODO Why does the FractionallySizedBox not work as expected, but widthFactor=1 leads to the content being
    // centered while decreasing the widthFactor makes it move to the left?
    return FractionallySizedBox(
        widthFactor: 1,
        alignment: FractionalOffset.center,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          LastFmAccountSelector(
              serviceName: serviceName,
              accountName: state.lastFmAccount?.accountName,
              artistCount: state.lastFmAccount?.artistCount,
              playCount: state.lastFmAccount?.playCount,
              lastAccountUpdate: state.lastFmAccount?.lastAccountUpdate,
              lastTopArtistsUpdate: state.lastFmAccount?.lastTopArtistsUpdate,
              onAddAccountClick: () => _openSetLastFmAccountNameDialog(context, bloc, dialogFactory),
              onRemoveAccountClick: () => bloc.add(RemoveLastFmAccount()),
              onUpdateAccountInfoClick: () => bloc.add(UpdateLastFmAccountInfo()),
              onAddAccountError: (e) => _handleAddLastFmAccountError(e, bloc),
              onRemoveAccountError: (e) => _handleRemoveLastFmAccountError(e, bloc),
              onUpdateAccountInfoError: (e) => _handleUpdateLastFmAccountInfoError(e, bloc)),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                  child: Text('Import from Last.fm'),
                  onPressed: bloc.state.hasAccount ? () => _showLastFmImportScreen(context) : null)),
          Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                  child: Text('Import from Spotify'), onPressed: () => _showSpotifyImportScreen(context)))
        ]));
  }

  Widget _buildLibrarySection(BuildContext context, AppSettingsBloc bloc, AlertDialogFactory dialogFactory) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: [
          Center(
              child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: ElevatedButton(
                      child: Text('Reset library'),
                      onPressed: () => _showResetLibraryDialog(context, bloc, dialogFactory))))
        ]));
  }

  void _showLastFmImportScreen(BuildContext context) => Navigator.of(context).pushNamed(Routes.lastFmImport);

  void _openSetLastFmAccountNameDialog(
      BuildContext context, AppSettingsBloc bloc, AlertDialogFactory dialogFactory) async {
    dialogFactory
        .getSingleTextInputDialog(context, title: 'Enter your Last.fm account name:', multiline: false)
        .show(onTruthyResult: (newAccountName) => bloc.add(AddLastFmAccount(newAccountName!)));
  }

  void _handleAddLastFmAccountError(Exception e, AppSettingsBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to set the ${serviceName} account.", cause: e));
  }

  void _handleRemoveLastFmAccountError(Exception e, AppSettingsBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to remove the ${serviceName} account.", cause: e));
  }

  void _handleUpdateLastFmAccountInfoError(Exception e, AppSettingsBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to update the ${serviceName} account info.", cause: e));
  }

  void _showSpotifyImportScreen(BuildContext context) {
    if (context.read<SpotifyAuthBloc>().state.spotifyAuthCode == null) {
      Function redirectAfterAuth = () {
        Navigator.pop(context);
        Navigator.pushNamed(context, Routes.spotifyImport);
      };
      context.read<SpotifyAuthBloc>().add(RequestUserAuthorization(redirectAfterAuth: redirectAfterAuth));
      Navigator.of(context).pushNamed(Routes.spotifyAuth);
    } else {
      Navigator.of(context).pushNamed(Routes.spotifyImport);
    }
  }

  void _showResetLibraryDialog(BuildContext context, AppSettingsBloc bloc, AlertDialogFactory dialogFactory) {
    dialogFactory
        .getConfirmationDialog(context,
            title: 'Are you sure that you want to reset the library?',
            subtitle: 'This will delete all artists and tags.')
        .show(onTruthyResult: (_) => bloc.add(ResetLibrary()));
  }
}
