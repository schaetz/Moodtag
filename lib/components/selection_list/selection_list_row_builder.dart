import 'package:moodtag/structs/named_entity.dart';

typedef SelectionListRowBuilder<E extends NamedEntity> = Function(E, bool, Function(bool?))?;
