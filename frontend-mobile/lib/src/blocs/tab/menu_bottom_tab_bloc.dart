import '../common/base_bloc.dart';
import '../common/screen_state.dart';
import '../../data/repository/login/login_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/invalid_exception.dart';

part 'menu_bottom_tab_event.dart';
part 'menu_bottom_tab_state.dart';

class MenuBottomTabBloc
    extends BaseBloc<MenuBottomTabEvent, MenuBottomTabState> {
  MenuBottomTabBloc() : super(InitialState());

  UpdateTabState get initialState => UpdateTabState(0);

  static String pushNavigation = '';

  @override
  Future<void> eventHandlerMethod(
    MenuBottomTabEvent event,
    Emitter<MenuBottomTabState> emit,
  ) async {
    if (event is ChangeTabEvent) {
      emit(UpdateTabState(event.tabIndex));
    } else if (event is LogoutEvent) {
      await _handleLogoutEvent(event, emit);
    }
  }

  Future<void> _handleLogoutEvent(
      LogoutEvent event, Emitter<MenuBottomTabState> emit) async {
    try {
      await LoginRepository().sendLogoutRequest(BaseRequest());
      emit(LogoutDoneState(
        event.exittoLogin,
        event.isFromMyaccount,
      ));
    } on InvalidException catch (_) {
      emit(LogoutDoneState(
        event.exittoLogin,
        event.isFromMyaccount,
      ));
    }
  }

  @override
  MenuBottomTabState getErrorState() {
    return LogoutErrorState();
  }
}
