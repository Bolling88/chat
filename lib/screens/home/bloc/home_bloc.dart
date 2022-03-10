import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/log.dart';
import 'Home_event.dart';
import 'Home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  HomeBloc() : super(HomeBaseState()) {
    add(HomeInitialEvent());
  }

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    try {
      if (event is HomeInitialEvent) {

      }else{
        Log.e('HomeBloc: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield HomeErrorState();
      Log.e('HomeBloc: $error', stackTrace: stacktrace);
    }
  }
}
