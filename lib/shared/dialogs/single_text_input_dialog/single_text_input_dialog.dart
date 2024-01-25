import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/abstract_dialog.dart';
import 'package:moodtag/shared/dialogs/dialog_option.dart';
import 'package:moodtag/shared/dialogs/simple_text_dialog_option.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'single_text_input_dialog_config.dart';

/**
 *  Dialog with a single text input;
 *  used for entity creation
 *
 *  S: Type of the suggested entities
 */
class SingleTextInputDialog<S extends NamedEntity> extends AbstractDialog<String?, SingleTextInputDialogConfig<S>> {
  static SingleTextInputDialog construct<S extends NamedEntity>(BuildContext context,
      {String? title,
      required Function(String?) handleResult,
      Function(String?)? onTerminate,
      // Dialog-specific properties
      List<S>? suggestedEntities = null}) {
    return SingleTextInputDialog<S>(
        context,
        SingleTextInputDialogConfig<S>(
            title: title,
            options: _getDefaultOptions(),
            handleResult: handleResult,
            onTerminate: onTerminate,
            // Dialog-specific properties
            suggestedEntities: suggestedEntities));
  }

  // TODO I18n
  static List<DialogOption<String?>> _getDefaultOptions() => [
        SimpleTextDialogOption<String?>('Discard', (context, formState) => null),
        SimpleTextDialogOption<String?>('Confirm',
            (context, formState) => formState?.get<String>(SingleTextInputDialogConfig.singleTextInputId) ?? null)
      ];

  SingleTextInputDialog(super.context, super.config);

  SingleTextInputDialog.withFuture(
      BuildContext context, Future<SingleTextInputDialogConfig<S>> Function(BuildContext) getRequiredData)
      : super.withFuture(context, getRequiredData: getRequiredData);
}
