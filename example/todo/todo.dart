// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the COPYING file.

// This is a port of "A Simple ToDo List Using HTML5 IndexedDB" to Dart.
// See: http://www.html5rocks.com/en/tutorials/indexeddb/todo/

import 'dart:html';
import 'package:lawndart/lawndart.dart';
class TodoList {
  static final String _TODOS_DB = "todo";
  static final String _TODOS_STORE = "todos";

  IDBDatabase _db;
  int _version = 5;
  InputElement _input;
  Element _todoItems;
  IndexedDb idb;
  Store store;
  TodoList() {
    _todoItems = query('#todo-items');
    _input = query('#todo');
    query('input#submit').on.click.add((e) => _onAddTodo());
  }

  void open() {
    idb = new IndexedDb(_TODOS_DB, [_TODOS_STORE], 1);
    idb.open().then((_) {
      store = idb.store(_TODOS_STORE);
      _getAllTodoItems();
    });
  }

  void _onError(e) {
    // Get the user's attention for the sake of this tutorial. (Of course we
    // would *never* use window.alert() in real life.)
    window.alert('Oh no! Something went wrong. See the console for details.');
    window.console.log('An error occurred: ${e} ${e.target.error.code}');
  }

  void _onAddTodo() {
    var value = _input.value.trim();
    if (value.length > 0) {
      _addTodo(value);
    }
    _input.value = '';
  }

  void _addTodo(String text) {    
    var timeStamp = new Date.now().millisecondsSinceEpoch.toString(); 
    store.save({'text': text, 'timeStamp': timeStamp}, timeStamp).then((_) {
      _getAllTodoItems();
    });
  }

  void _deleteTodo(String id) {
    store.removeByKey(id).then((_) {
      _getAllTodoItems();
    });
  }

  void _getTodo(String id) {
    store.getByKey(id).then((value) {
      window.alert(value.toString());
    });
  }
  
  void _getAllTodoItems() {
    _todoItems.nodes.clear();    
    store.all().then((all) {
      for (var each in all) {
        _renderTodo(each);
      }
    });
  }

  void _renderTodo(Map todoItem) {
    var textDisplay = new Element.tag('span');
    textDisplay.text = todoItem['text'];

    var deleteControl = new Element.tag('a');
    deleteControl.text = '[Delete]';
    deleteControl.on.click.add((e) => _deleteTodo(todoItem['timeStamp']));
    
    var getTodoControl = new Element.tag('a');
    getTodoControl.text = '[GetItem]';
    getTodoControl.on.click.add((e) => _getTodo(todoItem['timeStamp']));

    var item = new Element.tag('li');
    item.nodes.add(textDisplay);
    item.nodes.add(deleteControl);
    item.nodes.add(getTodoControl);
    _todoItems.nodes.add(item);
  }
}

void main() {
  new TodoList().open();
}
