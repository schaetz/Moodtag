import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/events/library_events.dart';

/// Mixin to make a screen (i.e. the state of a StatefulWidget) observe the router
/// and fire ActiveScreenChanged events on changes
mixin RouteObserverScreen<W extends StatefulWidget, B extends Bloc> on State<W> implements RouteAware {
  late final RouteObserver _routeObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = context.read<RouteObserver>();
    _routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    final bloc = context.read<B>();
    bloc.add(ActiveScreenChanged(true));
  }

  @override
  void didPopNext() {
    final bloc = context.read<B>();
    bloc.add(ActiveScreenChanged(true));
  }

  @override
  void didPop() {
    final bloc = context.read<B>();
    bloc.add(ActiveScreenChanged(false));
  }

  @override
  void didPushNext() {
    final bloc = context.read<B>();
    bloc.add(ActiveScreenChanged(false));
  }
}
