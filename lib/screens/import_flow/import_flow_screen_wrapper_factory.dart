import 'package:flutter/src/widgets/framework.dart';
import 'package:moodtag/components/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/screens/import_flow/import_flow_screen_wrapper.dart';

class ImportFlowScreenWrapperFactory extends ScaffoldBodyWrapperFactory<ImportFlowScreenWrapper> {
  final double _importProgress;
  final String captionText;

  ImportFlowScreenWrapperFactory(this._importProgress, this.captionText);

  @override
  ImportFlowScreenWrapper create({required Widget bodyWidget}) {
    return ImportFlowScreenWrapper(bodyWidget: bodyWidget, importProgress: _importProgress, captionText: captionText);
  }
}
