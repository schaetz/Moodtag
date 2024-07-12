import 'package:flutter/material.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/shared/widgets/data_display/display_wrapper/conditional_display_wrapper.dart';

import 'conditional_wrapper_return_type.dart';

class LoadedDataDisplayWrapper<T> extends ConditionalDisplayWrapper<LoadedDataWrapperReturnType, List<T?>> {
  static const errorLabelStyle = TextStyle(fontSize: 18.0, color: Colors.black);
  static const emptyDataLabelStyle = TextStyle(fontSize: 18.0);

  final List<LoadedData<T>> loadedDataList;
  final String captionForEmptyData;

  LoadedDataDisplayWrapper(
      {super.key,
      required this.loadedDataList,
      required super.buildOnSuccess,
      super.captionForError = 'Could not obtain data',
      this.captionForEmptyData = 'No data available'})
      : super(conditions: _createConditionsFromLoadedDataList(loadedDataList));

  static List<LoadedDataWrapperReturnTypeFunction> _createConditionsFromLoadedDataList(
      List<LoadedData> loadedDataList) {
    return loadedDataList.map((loadedData) {
      return () => _getConditionResultFromLoadingStatus(loadedData);
    }).toList();
  }

  static LoadedDataWrapperReturnType _getConditionResultFromLoadingStatus(LoadedData loadedData) {
    switch (loadedData.loadingStatus) {
      case LoadingStatus.initial:
      case LoadingStatus.loading:
        return LoadedDataWrapperReturnType.Loading;
      case LoadingStatus.error:
        return LoadedDataWrapperReturnType.Error;
      case LoadingStatus.success:
        if (_isDataEmpty(loadedData)) {
          return LoadedDataWrapperReturnType.Empty;
        }
        return LoadedDataWrapperReturnType.HasData;
    }
  }

  static bool _isDataEmpty(LoadedData loadedData) => loadedData.data == null || _isDataAnEmptyList(loadedData.data);

  static bool _isDataAnEmptyList(dynamic data) => (data is List && data.isEmpty);

  @override
  Widget buildWidgetBasedOnConditions() {
    if (hasErrorCondition()) {
      return buildErrorPlaceholder();
    } else if (hasUnfulfilledCondition()) {
      return buildConditionUnfulfilledPlaceholder();
    } else if (isMainDataEmpty()) {
      return _buildEmptyDataPlaceholder();
    }
    return buildOnSuccess(_getLoadedDataSuccessDataList());
  }

  List<T?> _getLoadedDataSuccessDataList() {
    return loadedDataList.map((loadedData) => loadedData.data).toList();
  }

  @override
  bool hasUnfulfilledCondition() =>
      !conditions.any((conditionFunc) => conditionFunc() == LoadedDataWrapperReturnType.Loading);

  @override
  bool hasErrorCondition() => conditions.any((conditionFunc) => conditionFunc() == LoadedDataWrapperReturnType.Error);

  bool isMainDataEmpty() => conditions.first() == LoadedDataWrapperReturnType.Empty;

  Widget _buildEmptyDataPlaceholder() {
    return Align(
      alignment: Alignment.center,
      child: Text(captionForEmptyData, style: emptyDataLabelStyle),
    );
  }
}
