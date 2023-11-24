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
import 'package:moodtag/model/blocs/app_bar/app_bar_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_bloc.dart';
import 'package:moodtag/model/blocs/spotify_auth/spotify_auth_bloc.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MoodtagApp());
}

class MoodtagApp extends StatefulWidget {
  static const appTitle = 'Moodtag';

  MoodtagApp({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MoodtagApp> {
  static const mainColor = Color.fromRGBO(230, 50, 50, 1);

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
                  BlocProvider<EntityLoaderBloc>(create: (context) => EntityLoaderBloc(context)),
                  BlocProvider<SpotifyAuthBloc>(create: (context) => SpotifyAuthBloc(context)),
                ],
                child: MaterialApp(
                  title: MoodtagApp.appTitle,
                  theme: ThemeData(
                    brightness: Brightness.light,
                    useMaterial3: true,
                    // textTheme: const TextTheme(
                    //   displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    //   bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
                    // ),
                    appBarTheme: const AppBarTheme(
                      color: mainColor,
                      iconTheme: IconThemeData(color: Colors.white),
                    ),
                    colorScheme: ColorScheme.fromSeed(seedColor: mainColor, brightness: Brightness.light),
                  ),
                  initialRoute: Routes.initialRoute,
                  routes: Routes.instance().getRoutes(),
                  navigatorObservers: [_routeObserver],
                ))));
  }
}
