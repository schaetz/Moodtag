import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog_config.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog_mixin.dart';

import '../abstract_dialog.dart';

class DeleteDialog<E> extends AbstractDialog<bool> with DeleteEntityDialogMixin<E, bool> {
  @override
  DeleteEntityDialogConfig<E> deleteEntityDialogConfig;

  DeleteDialog(BuildContext context,
      {required E? entityToDelete, required Function() deleteHandler, bool resetLibrary = false})
      : this.deleteEntityDialogConfig =
            DeleteEntityDialogConfig(entityToDelete, deleteHandler, resetLibrary: resetLibrary),
        super(context);
  DeleteDialog.withConfig(BuildContext context, this.deleteEntityDialogConfig) : super(context);

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
