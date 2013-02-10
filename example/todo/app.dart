library app;

import 'models.dart';
import 'package:web_ui/watcher.dart';
import 'package:lawndart/lawndart.dart';
import 'dart:json' as json;
import 'dart:async';

List<TodoItem> todoItems = new List<TodoItem>();

init() {
  Store store;
  var db = new IndexedDb("simple-todo", ['todos']);
  db.open()
    .then((_) {
      store = db.store('todos');
      return store.open();
    })
    .then((_) {
      var stop = watch(() => todoItems, (e) {
        store.save(json.stringify(todoItems), "todos");
      });
    });
}