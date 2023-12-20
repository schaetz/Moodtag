import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/components/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';
import 'package:moodtag/shared/models/structs/unique_named_entity_set.dart';

class SelectionListConfig<E extends NamedEntity> extends Equatable {
  final UniqueNamedEntitySet<E> namedEntitySet;
  final PreferredSizeWidget appBar;
  final ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory;
  final String mainButtonLabel;
  final Function(BuildContext, List<E>, Map<E, bool>, int) onMainButtonPressed;
  final bool Function(E)? doDisableEntity;

  const SelectionListConfig(
      {required this.namedEntitySet,
      required this.appBar,
      required this.scaffoldBodyWrapperFactory,
      required this.mainButtonLabel,
      required this.onMainButtonPressed,
      required this.doDisableEntity});

  @override
  List<Object?> get props => [namedEntitySet, appBar, mainButtonLabel, onMainButtonPressed, doDisableEntity];

  SelectionListConfig<E> copyWith(
      {UniqueNamedEntitySet<E>? namedEntitySet,
      PreferredSizeWidget? appBar,
      ScaffoldBodyWrapperFactory? scaffoldBodyWrapperFactory,
      String? mainButtonLabel,
      Function(BuildContext, List<E>, Map<E, bool>, int)? onMainButtonPressed,
      bool Function(E)? doDisableEntity}) {
    return SelectionListConfig<E>(
        namedEntitySet: namedEntitySet ?? this.namedEntitySet,
        appBar: appBar ?? this.appBar,
        scaffoldBodyWrapperFactory: scaffoldBodyWrapperFactory ?? this.scaffoldBodyWrapperFactory,
        mainButtonLabel: mainButtonLabel ?? this.mainButtonLabel,
        onMainButtonPressed: onMainButtonPressed ?? this.onMainButtonPressed,
        doDisableEntity: doDisableEntity ?? this.doDisableEntity);
  }
}
