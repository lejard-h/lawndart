library index;

import 'package:lawndart/lawndart.dart';
import 'dart:html';

runThrough(Store store, String id) {
  store.open()
  .then((_) => store.nuke())
  .then((_) => store.save(id, "hello"))
  .then((_) => store.save("is fun", "dart"))
  .then((_) => store.getByKey("hello"))
  .then((value) => query('#$id').text = value);
}

main() {
  runThrough(new WebSqlAdapter('test', 'test'), 'websql');
  runThrough(new IndexedDbAdapter('test', 'test'), 'indexeddb');
}