import 'package:flutter/material.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/dialogs/configurations/result_types/delete_with_replacement_result.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'configurations/alert_dialog_config.dart';
import 'configurations/delete_with_replacement_config.dart';
import 'configurations/single_select_entity_dialog_config.dart';
import 'configurations/single_text_input_dialog_config.dart';
import 'core/alert_dialog_wrapper.dart';
import 'core/dialog_action.dart';
import 'form/fields/entity_selection/entity_selection_dialog_form_field.dart';

class AlertDialogFactory {
  final Repository _repository;

  const AlertDialogFactory(this._repository);

  Future<BooleanDialogWrapper> getDeleteTagDialog(BuildContext context, {required Tag tag}) async {
    final artistsWithTag = await _repository.getArtistsHavingTag(tag).first;
    return getConfirmationDialog(context,
        title: 'Are you sure that you want to delete the tag "${tag.name}"?',
        subtitle: artistsWithTag.isEmpty
            ? 'It is not assigned to any artists.'
            : 'It is assigned to ${artistsWithTag.length} artist(s).',
        onTerminate: null);
  }

  Future<DeleteWithReplacementDialogWrapper<TagCategory>> getDeleteTagCategoryDialog(BuildContext context,
      {required TagCategory category}) async {
    final tagsWithCategory = await _repository.getTagsWithCategory(category).first;
    final remainingTagCategories = await _repository.getTagCategories().first
      ..removeWhere((tagCategory) => tagCategory == category);
    final replacementActive = tagsWithCategory.length > 0;

    return getDeleteWithReplacementDialog<TagCategory>(context,
        title: 'Are you sure that you want to delete the tag category "${category.name}"?',
        subtitle: tagsWithCategory.isEmpty
            ? 'It is not assigned to any tags.'
            : 'It is assigned to ${tagsWithCategory.length} tag(s). Please select the category to assign to these tags instead.',
        entities: replacementActive ? remainingTagCategories : [],
        initialSelection: remainingTagCategories.first,
        selectionStyle: EntityDialogSelectionStyle.ONE_TAP,
        iconSelector: (tagCategory) => Icon(Icons.circle, color: Color(tagCategory.color)),
        replacementActive: replacementActive);
  }

  BooleanDialogWrapper getConfirmationDialog(BuildContext context,
      {String? title, String? subtitle, Function(bool?)? onTerminate}) {
    final config = AlertDialogConfig<bool>(title, subtitle, const [], _getBooleanYesNoActions(), onTerminate);
    return BooleanDialogWrapper(context, config);
  }

  /// S: Type of the suggested entities
  SingleTextInputDialogWrapper getSingleTextInputDialog<S extends NamedEntity>(BuildContext context,
      {bool multiline = false,
      String? title,
      String? subtitle,
      Function(String?)? onTerminate,
      int? maxLines,
      Set<S>? suggestedEntities}) {
    final textInputDialogConfig = SingleTextInputDialogConfig.create<S>(title, subtitle, onTerminate,
        multiline: multiline, maxLines: maxLines, suggestedEntities: suggestedEntities);
    return SingleTextInputDialogWrapper(context, textInputDialogConfig);
  }

  /// E: Type of the selectable entities
  SingleSelectEntityDialogWrapper<E> getSelectEntityDialog<E extends LibraryEntity>(
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
    final config = SingleSelectEntityDialogConfig.create<E>(
        title, subtitle, onTerminate, entities, initialSelection, selectionStyle, iconSelector);
    return SingleSelectEntityDialogWrapper<E>(context, config);
  }

  /// E: Type of the entity to be deleted and replaced
  DeleteWithReplacementDialogWrapper<E> getDeleteWithReplacementDialog<E extends NamedEntity>(
    BuildContext context, {
    String? title,
    String? subtitle,
    Function(DeleteReplaceResult<E>?)? onTerminate,
    // SelectEntityDialog-specific parameters
    required List<E> entities,
    required E initialSelection,
    required EntityDialogSelectionStyle selectionStyle,
    Icon Function(E)? iconSelector,
    // DeleteWithReplacementDialog-specific parameters
    required bool replacementActive,
  }) {
    final config = DeleteWithReplacementConfig.create<E>(
        title, subtitle, onTerminate, entities, initialSelection, selectionStyle, iconSelector,
        replacementActive: replacementActive);
    return DeleteWithReplacementDialogWrapper<E>(context, config);
  }

  List<DialogAction<bool>> _getBooleanYesNoActions() {
    return [
      DialogAction<bool>('Yes', getDialogResult: (context, formState) => true),
      DialogAction<bool>('No', getDialogResult: (context, formState) => false),
    ];
  }
}

typedef BooleanDialogWrapper = AlertDialogWrapper<bool, AlertDialogConfig<bool>>;
typedef SingleTextInputDialogWrapper = AlertDialogWrapper<String?, AlertDialogConfig<String?>>;
typedef SingleSelectEntityDialogWrapper<E extends NamedEntity>
    = AlertDialogWrapper<E, SingleSelectEntityDialogConfig<E>>;
typedef DeleteWithReplacementDialogWrapper<E extends NamedEntity>
    = AlertDialogWrapper<DeleteReplaceResult<E>, DeleteWithReplacementConfig<E>>;
