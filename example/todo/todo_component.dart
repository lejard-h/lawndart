import 'package:web_ui/web_ui.dart';
import 'models.dart';
import 'app.dart' as app;
import 'package:meta/meta.dart';

class TodoItemComponent extends WebComponent {
  TodoItem todo;
  WatcherDisposer stopWatcher;
  
  toggle() {
    todo.toggle();
    app.storeAllTodos();
  }
  
  bool get isChecked => todo.complete;
  
  String get completeClass => todo.complete ? 'completed' : '';
}