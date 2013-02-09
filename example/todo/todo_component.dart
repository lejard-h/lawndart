import 'package:web_ui/web_ui.dart';
import 'models.dart';

class TodoItemComponent extends WebComponent {
  TodoItem todo;
  
  toggle() => todo.toggle();
  
  String get completeClass => todo.complete ? 'completed' : '';
}