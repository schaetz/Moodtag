import 'package:flutter/material.dart';
import 'package:moodtag/components/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';

abstract class AbstractImportConfirmationScreen extends StatelessWidget {
  // TODO Use common property with list screens?
  static const headlineStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  final GlobalKey scaffoldKey = GlobalKey();

  final ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory;

  AbstractImportConfirmationScreen({super.key, required this.scaffoldBodyWrapperFactory});

  Widget getImportedEntitiesOverviewList(Map<String, int> entityFrequencies) {
    return Column(children: [
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
            child: Text('Confirm import:', style: headlineStyle),
          )),
      Expanded(
          child: ListView.separated(
              separatorBuilder: (context, _) => Divider(),
              padding: EdgeInsets.all(16.0),
              itemCount: entityFrequencies.length,
              itemBuilder: (context, i) => ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entityFrequencies.keys.elementAt(i),
                            style: listEntryStyle,
                          ),
                        ),
                        Text(
                          entityFrequencies.values.elementAt(i).toString(),
                          style: listEntryStyle,
                        ),
                      ],
                    ),
                  )))
    ]);
  }
}
