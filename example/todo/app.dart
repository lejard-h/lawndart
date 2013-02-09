library app;

import 'models.dart';
import 'package:web_ui/watcher.dart';
import 'package:lawndart/lawndart.dart';

List<TodoItem> todoItems = new List<TodoItem>();

init() {
  var stop = watch(() => todoItems, (e) {
    // store
  });
}