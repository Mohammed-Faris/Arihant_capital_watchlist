import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acml/src/blocs/common/base_bloc.dart';
import 'package:acml/src/blocs/common/screen_state.dart';
import 'package:acml/src/models/alerts/alerts_model.dart';

part '{{bloc.lowerCase()}}_event.dart';
part '{{bloc.lowerCase()}}_state.dart';
class {{bloc.pascalCase()}}Bloc extends BaseBloc<{{bloc.pascalCase()}}Event, {{bloc.pascalCase()}}State> {
  {{bloc.pascalCase()}}Bloc() : super({{bloc.pascalCase()}}Initial());

  @override
  Future<void> eventHandlerMethod(
      {{bloc.pascalCase()}}Event event, Emitter<{{bloc.pascalCase()}}State> emit) async {
     switch (event.runtimeType) {
        {{#events}}
        case {{name.pascalCase()}}{{bloc.pascalCase()}}Event:
           on{{name.pascalCase()}}{{bloc.pascalCase()}}Event(event as {{name.pascalCase()}}{{bloc.pascalCase()}}Event,emit);
           break;
        {{/events}}  
         default:
       } 
  }
  {{#events}}
  void on{{name.pascalCase()}}{{bloc.pascalCase()}}Event({{name.pascalCase()}}{{bloc.pascalCase()}}Event event, Emitter<{{bloc.pascalCase()}}State> emit) {
  } 
  {{/events}}  

    @override
  {{bloc.pascalCase()}}State getErrorState() {
    return {{bloc.pascalCase()}}Error();
  }
}
