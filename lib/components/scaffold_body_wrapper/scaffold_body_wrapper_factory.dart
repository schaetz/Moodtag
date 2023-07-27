import 'package:flutter/widgets.dart';
import 'package:moodtag/components/scaffold_body_wrapper/scaffold_body_wrapper.dart';

abstract class ScaffoldBodyWrapperFactory<T extends ScaffoldBodyWrapper> {
  T create({required Widget bodyWidget});
}
