import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'models.dart';
import 'app.dart' as app;

class TodoInput extends WebComponent {
  createNewTodo() {
    var newTodo = query('#new-todo') as InputElement;
    app.todoItems.add(new TodoItem(newTodo.value));
    app.storeAllTodos();
    newTodo.value = '';
  }
}
