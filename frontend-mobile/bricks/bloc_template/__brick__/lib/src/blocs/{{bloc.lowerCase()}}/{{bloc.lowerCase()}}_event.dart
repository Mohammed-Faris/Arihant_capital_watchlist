part of '{{bloc.lowerCase()}}_bloc.dart';

abstract class {{bloc.pascalCase()}}Event {}
{{#events}}
class {{name.pascalCase()}}{{bloc.pascalCase()}}Event extends {{bloc.pascalCase()}}Event {
 {{name.pascalCase()}}{{bloc.pascalCase()}}Event({{#variables}}this.{{name}}{{/variables}});
  {{#variables}}final {{{type}}} {{name}};{{/variables}}
}
{{/events}}

