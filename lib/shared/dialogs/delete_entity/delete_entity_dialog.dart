import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog_config.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog_mixin.dart';
import 'package:moodtag/shared/dialogs/dialog_config.dart';

import '../abstract_dialog.dart';

typedef R = bool;

/**
 *  Dialog to confirm the deletion of an entity
 *
 *  R: Result type = bool
 *  E: Type of the entity
 */
class DeleteEntityDialog<E> extends AbstractDialog<R, DeleteEntityDialogConfig<R, E>>
    with DeleteEntityDialogMixin<E, R> {
  static DeleteEntityDialog construct<E>(BuildContext context,
      {String? title,
      required OptionObjectToHandler<R> options,
      Function(R?)? onTerminate,
      // Dialog-specific properties
      required E? entityToDelete,
      required Function() deleteHandler}) {
    return DeleteEntityDialog<E>(
        context,
        DeleteEntityDialogConfig<R, E>(
            title: title,
            options: options,
            onTerminate: onTerminate,
            // Dialog-specific properties
            entityToDelete: entityToDelete,
            deleteHandler: deleteHandler));
  }

  DeleteEntityDialog(super.context, super.config);

  DeleteEntityDialog.withFuture(
      BuildContext context, Future<DeleteEntityDialogConfig<R, E>> Function(BuildContext) getRequiredData)
      : super.withFuture(context, getRequiredData: getRequiredData);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return SimpleDialog(
      title: FutureBuilder<String>(
          future: determineDialogTextForDeleteEntity(context),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
              (snapshot.hasData && snapshot.data != null) ? Text(snapshot.data!) : Text('')),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: () => deleteEntity(context),
                  child: const Text('Yes'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: () => closeDialog(context, result: false),
                  child: const Text('No'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
