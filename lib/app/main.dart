/*
 * Copyright 2021 Stefan Schätz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:moodtag/app/logging/log_emoji_transformer.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/app_bar/app_bar_bloc.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_auth_bloc.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/logging/mt_bloc_observer.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MoodtagApp());
}

class MoodtagApp extends StatefulWidget {
  static const appTitle = 'Moodtag';

  MoodtagApp({Key? key}) : super(key: key) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print(
          '${record.level.name}: ${record.time.hour}:${record.time.minute}:${record.time.second}: ${insertEmojisIntoLogStatement(record.message)}');
    });
    Bloc.observer = MtBlocObserver();
  }

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MoodtagApp> {
  static const mainColor = Color.fromRGBO(230, 50, 50, 1);
  final baseTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: mainColor, brightness: Brightness.light));

  final _routeObserver = RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
        create: (context) => Repository(),
        child: Provider<RouteObserver>(
            create: (context) => _routeObserver,
            child: MultiBlocProvider(
                providers: [
                  BlocProvider<AppBarBloc>(create: (context) => AppBarBloc(context)),
                  BlocProvider<SpotifyAuthBloc>(create: (context) => SpotifyAuthBloc(context)),
                ],
                child: MaterialApp(
                  title: MoodtagApp.appTitle,
                  theme: baseTheme.copyWith(
                      colorScheme: baseTheme.colorScheme
                          .copyWith(tertiary: Color.fromRGBO(255, 200, 200, 1), onTertiary: Colors.black),
                      chipTheme: ChipThemeData(backgroundColor: baseTheme.colorScheme.primaryContainer),
                      appBarTheme: const AppBarTheme(
                        color: mainColor,
                        iconTheme: IconThemeData(color: Colors.white),
                      ),
                      tabBarTheme: TabBarTheme(
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                      // Adjust ElevatedButton text size for the ArtistsList filter modal
                      elevatedButtonTheme: ElevatedButtonThemeData(
                          style: ButtonStyle(
                              textStyle: MaterialStateProperty.resolveWith((states) => TextStyle(fontSize: 18))))),
                  initialRoute: Routes.initialRoute,
                  routes: Routes.instance().getRoutes(),
                  navigatorObservers: [_routeObserver],
                ))));
  }
}
