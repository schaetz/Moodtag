import 'package:flutter/material.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class LoadedDataDisplayWrapper<T> extends StatelessWidget {
  static const errorLabelStyle = TextStyle(fontSize: 18.0, color: Colors.black);
  static const emptyDataLabelStyle = TextStyle(fontSize: 18.0);

  final LoadedData<T> loadedData;
  final Widget Function(T) buildOnSuccess;
  final bool showPlaceholders;
  final String captionForError;
  final String captionForEmptyData;
  final LoadedData? additionalCheckData;

  const LoadedDataDisplayWrapper(
      {super.key,
      required this.loadedData,
      required this.buildOnSuccess,
      this.showPlaceholders = true,
      this.captionForError = 'Could not obtain data',
      this.captionForEmptyData = 'No data available',
      this.additionalCheckData});

  @override
  Widget build(BuildContext context) {
    final loadingStatus = _getLoadingStatus();
    return showPlaceholders ? _buildWithPlaceholders(loadingStatus) : _buildWithoutPlaceholders(loadingStatus);
  }

  Widget _buildWithoutPlaceholders(LoadingStatus loadingStatus) {
    if (!loadingStatus.isSuccess || _isDataEmpty()) {
      return Container();
    }
    return buildOnSuccess(loadedData.data!);
  }

  Widget _buildWithPlaceholders(LoadingStatus loadingStatus) {
    if (loadingStatus.isInitialOrLoading) {
      return Align(alignment: Alignment.center, child: CircularProgressIndicator());
    } else if (loadingStatus.isError) {
      return Align(
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(Icons.error),
                style: errorLabelStyle,
              ),
              TextSpan(text: " Error: " + captionForError, style: errorLabelStyle),
            ],
          ),
        ),
      );
    } else if (_isDataEmpty()) {
      return Align(
        alignment: Alignment.center,
        child: Text(captionForEmptyData, style: emptyDataLabelStyle),
      );
    }

    return buildOnSuccess(loadedData.data!);
  }

  LoadingStatus _getLoadingStatus() => additionalCheckData != null
      ? loadedData.loadingStatus.merge(additionalCheckData!.loadingStatus)
      : loadedData.loadingStatus;

  bool _isDataEmpty() => loadedData.data == null || _isDataAnEmptyList(loadedData.data);

  bool _isDataAnEmptyList(dynamic data) => (data is List && data.isEmpty);
}
