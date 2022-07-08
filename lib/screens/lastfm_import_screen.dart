import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/components/external_account_selector.dart';
import 'package:moodtag/components/mt_app_bar.dart';

class LastfmImportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LastfmImportScreenState();
}

class _LastfmImportScreenState extends State<LastfmImportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MtAppBar(context),
        body: Center(
          child: Column(
            children: [ExternalAccountSelector(serviceName: "Last.fm")],
          ),
        ));
  }
}
