import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

import 'selection_list_row_builder.dart';

class SelectionListConfig<E extends NamedEntity> extends Equatable {
  final UniqueNamedEntitySet<E> namedEntitySet;
  final PreferredSizeWidget appBar;
  final SelectionListRowBuilder<E>? rowBuilder; // Properties: entity, isBoxSelected, onListTileChanged
  final String mainButtonLabel;
  final Function(BuildContext, List<E>, List<bool>, int) onMainButtonPressed;

  const SelectionListConfig(
      {required this.namedEntitySet,
      required this.appBar,
      this.rowBuilder,
      required this.mainButtonLabel,
      required this.onMainButtonPressed});

  @override
  List<Object?> get props => [namedEntitySet, appBar, rowBuilder, mainButtonLabel, onMainButtonPressed];

  SelectionListConfig<E> copyWith(
      {UniqueNamedEntitySet<E>? namedEntitySet,
      PreferredSizeWidget? appBar,
      SelectionListRowBuilder<E> rowBuilder, // rowBuilder can be null, so it always has to be passed
      String? mainButtonLabel,
      Function(BuildContext, List<E>, List<bool>, int)? onMainButtonPressed}) {
    return SelectionListConfig<E>(
        namedEntitySet: namedEntitySet ?? this.namedEntitySet,
        appBar: appBar ?? this.appBar,
        rowBuilder: rowBuilder,
        mainButtonLabel: mainButtonLabel ?? this.mainButtonLabel,
        onMainButtonPressed: onMainButtonPressed ?? this.onMainButtonPressed);
  }
}
