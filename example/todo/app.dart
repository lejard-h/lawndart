library app;

import 'models.dart';
import 'package:web_ui/web_ui.dart';
import 'package:lawndart/lawndart.dart';
import 'dart:json' as json;
import 'dart:async';

final List<TodoItem> todoItems = toObservable(new List<TodoItem>());

@observable
bool initialized = false;

getDb() {
  if (IndexedDbStore.supported) {
    return new IndexedDbStore("simple-todo", 'todos');
  } else if (WebSqlStore.supported) {
    return new WebSqlStore('simple-todo', 'todos');
  } else {
    return new LocalStorageStore();
  }
}

Store db = getDb();

init() {
  db.open()
    .then((_) => db.getByKey("todos"))
    .then((todosString) {
      if (todosString != null) {
        var list = (json.parse(todosString) as List).map((t) => new TodoItem.fromMap(t));
        todoItems.addAll(list);
      }
      
      initialized = true;
    });
}

storeAllTodos() {
  db.save(json.stringify(todoItems), "todos");
}