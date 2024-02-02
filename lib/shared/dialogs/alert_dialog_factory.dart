import 'package:flutter/material.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'configurations/single_select_entity_dialog_config.dart';
import 'configurations/single_text_input_dialog_config.dart';
import 'core/alert_dialog_config.dart';
import 'core/alert_dialog_wrapper.dart';
import 'core/dialog_action.dart';

class AlertDialogFactory {
  final Repository _repository;

  const AlertDialogFactory(this._repository);

  Future<BooleanDialogWrapper> getDeleteTagDialog(BuildContext context, {required Tag tag}) async {
    final artistsWithTag = await _repository.getArtistsDataHavingTag(tag).first;
    return getConfirmationDialog(context,
        title: 'Are you sure that you want to delete the tag "${tag.name}"?',
        subtitle: artistsWithTag.isEmpty
            ? 'It is not assigned to any artists.'
            : 'It is assigned to ${artistsWithTag.length} artist(s).',
        onTerminate: null);
  }

  BooleanDialogWrapper getConfirmationDialog(BuildContext context,
      {String? title, String? subtitle, Function(bool?)? onTerminate}) {
    return BooleanDialogWrapper(
        context,
        AlertDialogConfig<bool>(
            title: title, subtitle: subtitle, actions: _getYesNoOptions(), onTerminate: onTerminate));
  }

  /// S: Type of the suggested entities
  SingleTextInputDialogWrapper getSingleTextInputDialog<S extends NamedEntity>(BuildContext context,
      {bool multiline = false,
      String? title,
      String? subtitle,
      Function(String?)? onTerminate,
      int? maxLines,
      Set<S>? suggestedEntities}) {
    final textInputDialogConfig = multiline
        ? SingleTextInputDialogConfig.multiline(
            title: title,
            subtitle: subtitle,
            actions: _getTextInputConfirmationActions(SingleTextInputDialogConfig.singleTextInputId),
            onTerminate: onTerminate,
            maxLines: maxLines,
            suggestedEntities: suggestedEntities)
        : SingleTextInputDialogConfig.singleLine(
            title: title,
            subtitle: subtitle,
            actions: _getTextInputConfirmationActions(SingleTextInputDialogConfig.singleTextInputId),
            onTerminate: onTerminate,
            suggestedEntities: suggestedEntities);
    return SingleTextInputDialogWrapper(context, textInputDialogConfig);
  }

  /// E: Type of the selectable entities
  SingleSelectEntityDialogWrapper<E> getSelectEntityDialog<E extends NamedEntity>(
    BuildContext context, {
    String? title,
    String? subtitle,
    Function(E?)? onTerminate,
    // SelectEntityDialog-specific parameters
    required List<E> entities,
    required E initialSelection,
    required EntityDialogSelectionStyle selectionStyle,
    required Icon Function(E)? iconSelector,
  }) {
    return SingleSelectEntityDialogWrapper<E>(
        context,
        SingleSelectEntityDialogConfig<E>(
            title: title,
            subtitle: subtitle,
            actions: _getSelectEntityConfirmationActions<E>(SingleSelectEntityDialogConfig.singleSelectionInputId),
            onTerminate: onTerminate,
            availableEntities: entities,
            initialSelection: initialSelection,
            selectionStyle: selectionStyle,
            iconSelector: iconSelector));
  }

  List<DialogAction<bool>> _getYesNoOptions() {
    return [
      DialogAction.getSimpleTextDialogAction<bool>('Yes', getDialogResult: (context, formState) => true),
      DialogAction.getSimpleTextDialogAction<bool>('No', getDialogResult: (context, formState) => false),
    ];
  }

  static List<DialogAction<String>> _getTextInputConfirmationActions(String mainInputId) => [
        DialogAction.getSimpleTextDialogAction<String>('Discard', getDialogResult: (context, formState) => null),
        DialogAction.getSimpleTextDialogAction<String>('Confirm',
            getDialogResult: (context, formState) => formState?.get<String>(mainInputId) ?? null,
            validate: (context, formState) => formState?.get<String>(mainInputId)?.isNotEmpty == true)
      ];

  static List<DialogAction<E>> _getSelectEntityConfirmationActions<E extends NamedEntity>(String mainInputId) => [
        DialogAction.getSimpleTextDialogAction<E>('Discard', getDialogResult: (context, formState) => null),
        DialogAction.getSimpleTextDialogAction<E>('Confirm',
            getDialogResult: (context, formState) => formState?.get<E>(mainInputId) ?? null,
            validate: (context, formState) => formState?.get<E>(mainInputId) != null)
      ];
}

typedef BooleanDialogWrapper = AlertDialogWrapper<bool, AlertDialogConfig<bool>>;
typedef SingleTextInputDialogWrapper = AlertDialogWrapper<String?, AlertDialogConfig<String?>>;
typedef SingleSelectEntityDialogWrapper<E extends NamedEntity>
    = AlertDialogWrapper<E, SingleSelectEntityDialogConfig<E>>;
