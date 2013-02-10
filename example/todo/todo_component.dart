import 'package:web_ui/web_ui.dart';
import 'models.dart';
import 'app.dart' as app;
import 'package:meta/meta.dart';

class TodoItemComponent extends WebComponent {
  TodoItem todo;
  WatcherDisposer stopWatcher;
  
  toggle() => todo.toggle();
  
  bool get isChecked => todo.complete;
  
  @override
  void inserted() {
    // just experimenting, the call to save is probably
    // better placed inside of toggle()
    stopWatcher = watch(() => todo.hashCode, (_) => app.storeAllTodos());
  }
  
  @override
  void removed() {
    stopWatcher();
  }
  
  String get completeClass => todo.complete ? 'completed' : '';
}