import 'package:flutter/material.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/shared/widgets/data_display/display_wrapper/conditional_display_wrapper.dart';

import 'conditional_wrapper_return_type.dart';

/// An implementation of ConditionalDisplayWrapper that consumes a list of LoadedData objects
/// and builds a placeholder or a Widget from a given build function based on the loading status
/// of these objects.
///
/// T is the type of the result data from all of the LoadedData objects.
/// M is the type of the result data of the main LoadedData object. Hence M must be a subclass of T.
class MultiLoadedDataDisplayWrapper<T, M extends T> extends ConditionalDisplayWrapper<LoadedDataWrapperReturnType, T> {
  static const errorLabelStyle = TextStyle(fontSize: 18.0, color: Colors.black);
  static const emptyDataLabelStyle = TextStyle(fontSize: 18.0);

  final List<LoadedData<T>> loadedDataList;

  final String captionForEmptyData;
  final bool noPlaceholders;

  /// Single loadedData object, its result data is accessible in buildOnSuccess()
  MultiLoadedDataDisplayWrapper({
    super.key,
    required LoadedData<T> loadedData,
    required Widget Function(M) buildOnSuccess,
    super.captionForError = 'Could not obtain data',
    this.captionForEmptyData = 'No data available',
    this.noPlaceholders = false,
  })  : loadedDataList = [loadedData],
        super(
            conditions: [_createSingleConditionFromSingleLoadedData(loadedData)],
            buildOnSuccess: (loadedDataList) => buildOnSuccess(loadedDataList.first as M));

  /// Multiple loadedData objects, the result data of the first one is accessible in buildOnSuccess(),
  /// whereas the others are just checked for having LoadingStatus.SUCCESS
  MultiLoadedDataDisplayWrapper.additionalChecks({
    super.key,
    required this.loadedDataList,
    required Widget Function(M) buildOnSuccess,
    super.captionForError = 'Could not obtain data',
    this.captionForEmptyData = 'No data available',
    this.noPlaceholders = false,
  }) : super(
            conditions: _createConditionsFromLoadedDataList(loadedDataList),
            buildOnSuccess: (loadedDataList) => buildOnSuccess(loadedDataList.first as M));

  /// Multiple loadedData objects, the result data of all of them is accessible in buildOnSuccess(),
  /// all need to have LoadingStatus.SUCCESS
  MultiLoadedDataDisplayWrapper.multiResult({
    super.key,
    required this.loadedDataList,
    required super.buildOnSuccess,
    super.captionForError = 'Could not obtain data',
    this.captionForEmptyData = 'No data available',
    this.noPlaceholders = false,
  }) : super(conditions: _createConditionsFromLoadedDataList(loadedDataList));

  static List<LoadedDataWrapperReturnTypeFunction> _createConditionsFromLoadedDataList(
      List<LoadedData> loadedDataList) {
    return loadedDataList.map((loadedData) => _createSingleConditionFromSingleLoadedData(loadedData)).toList();
  }

  static LoadedDataWrapperReturnTypeFunction _createSingleConditionFromSingleLoadedData(LoadedData loadedData) {
    return () => _getConditionResultFromLoadingStatus(loadedData);
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
      return noPlaceholders ? _buildEmptyWidget() : buildErrorPlaceholder();
    } else if (hasUnfulfilledCondition()) {
      return noPlaceholders ? _buildEmptyWidget() : buildConditionUnfulfilledPlaceholder();
    } else if (isMainDataEmpty()) {
      return noPlaceholders ? _buildEmptyWidget() : _buildEmptyDataPlaceholder();
    }
    return buildOnSuccess(_getLoadedDataSuccessDataList());
  }

  Widget _buildEmptyWidget() {
    return Container();
  }

  List<T> _getLoadedDataSuccessDataList() {
    return loadedDataList.map((loadedData) => loadedData.data!).toList();
  }

  @override
  bool hasUnfulfilledCondition() =>
      conditions.any((conditionFunc) => conditionFunc() == LoadedDataWrapperReturnType.Loading);

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

typedef LoadedDataDisplayWrapper<T> = MultiLoadedDataDisplayWrapper<T, T>;
