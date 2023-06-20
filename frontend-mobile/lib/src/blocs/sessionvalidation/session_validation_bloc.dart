import '../common/base_bloc.dart';
import '../common/screen_state.dart';
import '../../data/repository/sessionvalidation/sessionvalidation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';

part 'session_validation_event.dart';
part 'session_validation_state.dart';

class SessionValidationBloc
    extends BaseBloc<SessionValidationEvent, SessionValidationState> {
  SessionValidationBloc() : super(SessionValidationInitState());

  @override
  Future<void> eventHandlerMethod(
    SessionValidationEvent event,
    Emitter<SessionValidationState> emit,
  ) async {
    if (event is ValidateSessionEvent) {
      final BaseModel validationResponse = await SessionValidationRepository
          .instance
          .validateSession(BaseRequest());

      if (validationResponse.isSuccess()) {
        emit(SessionValidState());
      } else {
        emit(SessionInValidState());
      }
    }
  }

  @override
  SessionValidationState getErrorState() {
    return SessionInValidState();
  }
}
