library index;

import 'package:lawndart/lawndart.dart';
import 'dart:html';
import 'dart:web_sql';
import 'dart:indexed_db';

runThrough(Store store, String id) {
  var elem = querySelector('#$id');
  store.open()
  .then((_) => store.nuke())
  .then((_) => store.save(id, "hello"))
  .then((_) => store.save("is fun", "dart"))
  .then((_) {
    store.all()
      .listen((value) => elem.appendText('$value, '))
      .onDone(() => elem.appendText('all done'));
  })
  .catchError((e) => elem.text = e.toString());
}

main() {
  if (SqlDatabase.supported) {
    runThrough(new WebSqlStore('test', 'test'), 'websql');
  } else {
    querySelector('#websql').text = 'WebSQL is not supported in your browser';
  }
  
  if (IdbFactory.supported) {
    runThrough(new IndexedDbStore('test', 'test'), 'indexeddb');
  } else {
    querySelector('#indexeddb').text = 'IndexedDB is not supported in your browser';
  }
}