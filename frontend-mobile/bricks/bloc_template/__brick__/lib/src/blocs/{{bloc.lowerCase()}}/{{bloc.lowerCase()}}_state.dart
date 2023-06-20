
part of '{{bloc.lowerCase()}}_bloc.dart';

abstract class {{bloc.pascalCase()}}State extends ScreenState {}
{{#states}}
class {{bloc.pascalCase()}}{{name.pascalCase()}} extends {{bloc.pascalCase()}}State {
 {{bloc.pascalCase()}}{{name.pascalCase()}}({{#variables}}this.{{name}}{{/variables}});
{{#variables}}final {{{type}}} {{name}};{{/variables}}
}
{{/states}}
