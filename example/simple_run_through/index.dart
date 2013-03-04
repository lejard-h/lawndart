library index;

import 'package:lawndart/lawndart.dart';
import 'dart:html';
import 'dart:web_sql';
import 'dart:indexed_db';

runThrough(Store store, String id) {
  store.open()
  .then((_) => store.nuke())
  .then((_) => store.save(id, "hello"))
  .then((_) => store.save("is fun", "dart"))
  .then((_) => store.getByKey("hello"))
  .then((value) => query('#$id').text = "$value works!");
}

main() {
  if (SqlDatabase.supported) {
    runThrough(new WebSqlAdapter('test', 'test'), 'websql');
  } else {
    query('#websql').text = 'WebSQL is not supported in your browser';
  }
  
  if (IdbFactory.supported) {
    runThrough(new IndexedDbAdapter('test', 'test'), 'indexeddb');
  } else {
    query('#indexeddb').text = 'IndexedDB is not supported in your browser';
  }
}