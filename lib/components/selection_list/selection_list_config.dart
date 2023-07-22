import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

class SelectionListConfig<E extends NamedEntity> extends Equatable {
  final UniqueNamedEntitySet<E> namedEntitySet;
  final PreferredSizeWidget appBar;
  final String mainButtonLabel;
  final Function(BuildContext, List<E>, List<bool>, int) onMainButtonPressed;

  const SelectionListConfig(
      {required this.namedEntitySet,
      required this.appBar,
      required this.mainButtonLabel,
      required this.onMainButtonPressed});

  @override
  List<Object?> get props => [namedEntitySet, appBar, mainButtonLabel, onMainButtonPressed];

  SelectionListConfig<E> copyWith(
      {UniqueNamedEntitySet<E>? namedEntitySet,
      PreferredSizeWidget? appBar,
      String? mainButtonLabel,
      Function(BuildContext, List<E>, List<bool>, int)? onMainButtonPressed}) {
    return SelectionListConfig<E>(
        namedEntitySet: namedEntitySet ?? this.namedEntitySet,
        appBar: appBar ?? this.appBar,
        mainButtonLabel: mainButtonLabel ?? this.mainButtonLabel,
        onMainButtonPressed: onMainButtonPressed ?? this.onMainButtonPressed);
  }
}
