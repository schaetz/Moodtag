import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/abstract_dialog.dart';
import 'package:moodtag/shared/dialogs/components/options/dialog_option.dart';
import 'package:moodtag/shared/dialogs/components/options/simple_text_dialog_option.dart';
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
      String? subtitle,
      Function(String?)? onTerminate,
      // Dialog-specific properties
      List<S>? suggestedEntities = null}) {
    return SingleTextInputDialog<S>(
        context,
        SingleTextInputDialogConfig<S>(
            title: title,
            subtitle: subtitle,
            options: _getDefaultOptions(),
            onTerminate: onTerminate,
            // Dialog-specific properties
            suggestedEntities: suggestedEntities));
  }

  // TODO I18n
  static List<DialogOption<String?>> _getDefaultOptions() => [
        SimpleTextDialogOption<String?>('Discard', (context, formState) => null),
        SimpleTextDialogOption<String?>('Confirm',
            (context, formState) => formState?.get<String>(SingleTextInputDialogConfig.singleTextInputId) ?? null,
            validate: (context, formState) =>
                formState?.get<String>(SingleTextInputDialogConfig.singleTextInputId)?.isNotEmpty == true)
      ];

  SingleTextInputDialog(super.context, super.config);

  SingleTextInputDialog.withFuture(
      BuildContext context, Future<SingleTextInputDialogConfig<S>> Function(BuildContext) getRequiredData)
      : super.withFuture(context, getRequiredData: getRequiredData);
}
