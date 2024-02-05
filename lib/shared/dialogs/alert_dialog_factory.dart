import 'package:flutter/material.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/dialogs/configurations/result_types/delete_with_replacement_result.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'configurations/delete_with_replacement_config.dart';
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

  Future<DeleteWithReplacementDialogWrapper<TagCategoryData>> getDeleteTagCategoryDialog(BuildContext context,
      {required TagCategory category}) async {
    final tagsWithCategory = await _repository.getTagsWithCategory(category).first;
    final remainingTagCategories = await _repository.getTagCategories().first
      ..removeWhere((tagCategoryData) => tagCategoryData.tagCategory == category);
    final replacementActive = tagsWithCategory.length > 0;
    return getDeleteWithReplacementDialog<TagCategoryData>(context,
        title: 'Are you sure that you want to delete the tag category "${category.name}"?',
        subtitle: tagsWithCategory.isEmpty
            ? 'It is not assigned to any tags.'
            : 'It is assigned to ${tagsWithCategory.length} tag(s). Please select the category to assign to these tags instead.',
        entities: replacementActive ? remainingTagCategories : [],
        initialSelection: remainingTagCategories.first,
        selectionStyle: EntityDialogSelectionStyle.ONE_TAP,
        iconSelector: (categoryData) => Icon(Icons.circle, color: Color(categoryData.tagCategory.color)),
        replacementActive: replacementActive);
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
            actions: selectionStyle == EntityDialogSelectionStyle.ONE_TAP
                ? []
                : _getSelectEntityConfirmationActions<E>(SingleSelectEntityDialogConfig.singleSelectionInputId),
            onTerminate: onTerminate,
            availableEntities: entities,
            initialSelection: initialSelection,
            selectionStyle: selectionStyle,
            iconSelector: iconSelector));
  }

  /// E: Type of the entity to be deleted and replaced
  DeleteWithReplacementDialogWrapper<E> getDeleteWithReplacementDialog<E extends NamedEntity>(
    BuildContext context, {
    String? title,
    String? subtitle,
    Function(DeleteWithReplacementResult<E>?)? onTerminate,
    // SelectEntityDialog-specific parameters
    required List<E> entities,
    required E? initialSelection,
    required EntityDialogSelectionStyle selectionStyle,
    Icon Function(E)? iconSelector,
    // DeleteWithReplacementDialog-specific parameters
    required bool replacementActive,
  }) {
    return DeleteWithReplacementDialogWrapper<E>(
        context,
        DeleteWithReplacementConfig<E>(
            title: title,
            subtitle: subtitle,
            actions: selectionStyle == EntityDialogSelectionStyle.ONE_TAP && replacementActive
                ? [
                    DialogAction<DeleteWithReplacementResult<E>>('Discard',
                        getDialogResult: (context, formState) => DeleteWithReplacementResult<E>(confirmDeletion: false))
                  ]
                : _getDeleteWithReplacementActions<E>(
                    DeleteWithReplacementConfig.singleSelectionInputId, replacementActive),
            onTerminate: onTerminate,
            availableEntities: entities,
            initialSelection: initialSelection,
            selectionStyle: selectionStyle,
            iconSelector: iconSelector,
            replacementActive: replacementActive));
  }

  List<DialogAction<bool>> _getYesNoOptions() {
    return [
      DialogAction<bool>('Yes', getDialogResult: (context, formState) => true),
      DialogAction<bool>('No', getDialogResult: (context, formState) => false),
    ];
  }

  static List<DialogAction<String>> _getTextInputConfirmationActions(String mainInputId) => [
        DialogAction<String>('Confirm',
            getDialogResult: (context, formState) => formState?.get<String>(mainInputId) ?? null,
            validate: (context, formState) => formState?.get<String>(mainInputId)?.isNotEmpty == true),
        DialogAction<String>('Discard', getDialogResult: (context, formState) => null),
      ];

  static List<DialogAction<E>> _getSelectEntityConfirmationActions<E extends NamedEntity>(String mainInputId) => [
        DialogAction<E>('Confirm',
            getDialogResult: (context, formState) => formState?.get<E>(mainInputId) ?? null,
            validate: (context, formState) => true),
        DialogAction<E>('Discard', getDialogResult: (context, formState) => null),
      ];

  static List<DialogAction<DeleteWithReplacementResult<E>>> _getDeleteWithReplacementActions<E extends NamedEntity>(
          String mainInputId, bool replacementActive) =>
      replacementActive
          ? [
              DialogAction<DeleteWithReplacementResult<E>>('Confirm',
                  getDialogResult: (context, formState) => DeleteWithReplacementResult<E>(
                      confirmDeletion: true, replacement: formState?.get<E>(mainInputId)),
                  validate: (context, formState) => true),
              DialogAction<DeleteWithReplacementResult<E>>('Discard',
                  getDialogResult: (context, formState) => DeleteWithReplacementResult<E>(confirmDeletion: false)),
            ]
          : [
              DialogAction<DeleteWithReplacementResult<E>>('Yes',
                  getDialogResult: (context, formState) => DeleteWithReplacementResult<E>(confirmDeletion: true)),
              DialogAction<DeleteWithReplacementResult<E>>('No',
                  getDialogResult: (context, formState) => DeleteWithReplacementResult<E>(confirmDeletion: false)),
            ];
}

typedef BooleanDialogWrapper = AlertDialogWrapper<bool, AlertDialogConfig<bool>>;
typedef SingleTextInputDialogWrapper = AlertDialogWrapper<String?, AlertDialogConfig<String?>>;
typedef SingleSelectEntityDialogWrapper<E extends NamedEntity>
    = AlertDialogWrapper<E, SingleSelectEntityDialogConfig<E>>;
typedef DeleteWithReplacementDialogWrapper<E extends NamedEntity>
    = AlertDialogWrapper<DeleteWithReplacementResult<E>, DeleteWithReplacementConfig<E>>;
