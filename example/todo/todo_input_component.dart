import 'package:web_ui/web_ui.dart';
import 'dart:html';
import 'models.dart';
import 'app.dart';

class TodoInput extends WebComponent {
  createNewTodo() {
    var newTodo = query('#new-todo') as InputElement;
    todoItems.add(new TodoItem(newTodo.value));
    newTodo.value = '';
  }
}
