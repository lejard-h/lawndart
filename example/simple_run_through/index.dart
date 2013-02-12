library index;

import 'package:lawndart/lawndart.dart';
import 'dart:html';

main() {
  Store store;
  
  var db = new IndexedDb("simple-run-through", ['test']);
  db.open()
  .then((_) {
    store = db.store('test');
    return store.open();
  })
  .then((_) => store.nuke())
  .then((_) => store.save("world", "hello"))
  .then((_) => store.save("is fun", "dart"))
  .then((_) => store.getByKey("hello"))
  .then((value) => query('#text').text = value);
}