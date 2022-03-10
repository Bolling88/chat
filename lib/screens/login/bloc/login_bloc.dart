import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/log.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginBloc() : super(LoginBaseState()) {
    add(LoginInitialEvent());
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    try {
      if (event is LoginInitialEvent) {

      }else{
        Log.e('LoginBloc: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield LoginErrorState();
      Log.e('LoginBloc: $error', stackTrace: stacktrace);
    }
  }
}
