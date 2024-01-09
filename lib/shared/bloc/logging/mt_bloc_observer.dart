import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

class MtBlocObserver extends BlocObserver {
  final log = Logger('BlocObserver');

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log.fine('${bloc.runtimeType} | Received event | %$event');
  }
}
