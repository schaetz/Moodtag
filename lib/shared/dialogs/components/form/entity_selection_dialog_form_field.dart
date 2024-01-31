import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'dialog_form_field.dart';

class EntitySelectionDialogFormField<E extends NamedEntity> extends DialogFormField<E> {
  final List<E> entities;

  const EntitySelectionDialogFormField(super.identifier, {required super.initialValue, required this.entities});
}
