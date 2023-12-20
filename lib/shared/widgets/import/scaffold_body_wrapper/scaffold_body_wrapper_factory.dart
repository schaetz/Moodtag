import 'package:flutter/widgets.dart';
import 'package:moodtag/shared/widgets/import/scaffold_body_wrapper/scaffold_body_wrapper.dart';

abstract class ScaffoldBodyWrapperFactory<T extends ScaffoldBodyWrapper> {
  T create({required Widget bodyWidget});
}
