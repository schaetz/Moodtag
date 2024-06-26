import 'package:flutter/material.dart';

class DataList<T> extends StatelessWidget {
  final String? headline;
  final Map<String, T> data;

  // TODO Use common property with list screens?
  static const headlineStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  const DataList({super.key, this.headline, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      headline != null
          ? Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
                child: Text(headline!, style: headlineStyle),
              ))
          : Container(),
      SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
              child: Column(
                  children: ListTile.divideTiles(
                      color: Colors.black,
                      tiles: data.entries.map((entry) => ListTile(
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: listEntryStyle,
                                  ),
                                ),
                                Text(
                                  entry.value.toString(),
                                  style: listEntryStyle,
                                ),
                              ],
                            ),
                          ))).toList())))
    ]);
  }
}
