library app;

import 'models.dart';
import 'package:web_ui/web_ui.dart';
import 'package:lawndart/lawndart.dart';
import 'dart:json' as json;
import 'dart:async';
import 'package:web_ui/observe/observable.dart' as __observe;

final List<TodoItem> todoItems = toObservable(new List<TodoItem>());

final __changes = new __observe.Observable();

bool __$initialized = false;
bool get initialized {
  if (__observe.observeReads) {
    __observe.notifyRead(__changes, __observe.ChangeRecord.FIELD, 'initialized');
  }
  return __$initialized;
}
set initialized(bool value) {
  if (__observe.hasObservers(__changes)) {
    __observe.notifyChange(__changes, __observe.ChangeRecord.FIELD, 'initialized',
        __$initialized, value);
  }
  __$initialized = value;
}

Store db = new IndexedDbStore("simple-todo", 'todos');

init() {
  db.open()
    .then((_) => db.getByKey("todos"))
    .then((todosString) {
      if (todosString != null) {
        var list = (json.parse(todosString) as List).map((t) => new TodoItem.fromMap(t));
        todoItems.addAll(list);
      }
      
      initialized = true;
      
      var stop = watch(() => todoItems, (e) {
        storeAllTodos();
      });
    });
}

storeAllTodos() {
  db.save(json.stringify(todoItems), "todos");
}
//@ sourceMappingURL=app.dart.map