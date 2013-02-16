import 'package:web_ui/web_ui.dart';
import 'models.dart';
import 'app.dart' as app;

class TodoItemComponent extends WebComponent {
  TodoItem todo;
  
  toggle() {
    todo.toggle();
    app.storeAllTodos();
  }
  
  bool get isChecked => todo.complete;
  
  String get completeClass => todo.complete ? 'completed' : '';
}