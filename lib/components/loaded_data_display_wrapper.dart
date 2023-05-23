import 'package:flutter/material.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class LoadedDataDisplayWrapper<T> extends StatelessWidget {
  static const errorLabelStyle = TextStyle(fontSize: 18.0, color: Colors.black);
  static const emptyDataLabelStyle = TextStyle(fontSize: 18.0);

  final LoadedData<T> loadedData;
  final Widget Function(T) buildOnSuccess;
  final String captionForError;
  final String captionForEmptyData;

  const LoadedDataDisplayWrapper(
      {super.key,
      required this.loadedData,
      required this.buildOnSuccess,
      this.captionForError = 'Could not obtain data',
      this.captionForEmptyData = 'No data available'});

  @override
  Widget build(BuildContext context) {
    final loadingStatus = loadedData.loadingStatus;
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
    } else if (loadedData.data == null || (loadedData.data is List && (loadedData.data as List).isEmpty)) {
      return Align(
        alignment: Alignment.center,
        child: Text(captionForEmptyData, style: emptyDataLabelStyle),
      );
    }

    return buildOnSuccess(loadedData.data!);
  }
}
