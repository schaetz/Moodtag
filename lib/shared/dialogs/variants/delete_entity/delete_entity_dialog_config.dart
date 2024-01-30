import 'package:moodtag/shared/dialogs/components/dialog_config.dart';

/**
 *  Configuration for dialogs to confirm the deletion of an entity
 *
 *  R: Result type
 *  E: Type of the entity to delete
 */
class DeleteEntityDialogConfig<R, E> extends DialogConfig<R> {
  E? entityToDelete;

  DeleteEntityDialogConfig(
      {super.title,
      super.subtitle,
      required super.options,
      super.onTerminate,
      // Dialog-specific properties
      this.entityToDelete});
}
