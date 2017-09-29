library index;

import 'package:lawndart/lawndart.dart';
import 'dart:html';
import 'dart:web_sql';
import 'dart:indexed_db';

runThrough(Store store, String id) async {
  var elem = querySelector('#$id');

  try {
    await store.nuke();
    await store.save(id, "hello");
    await store.save("is fun", "dart");
    await for (var value in store.all()) {
      elem.appendText('$value, ');
    }
    elem.appendText('all done');
  } catch (e) {
    elem.text = e.toString();
  }
}

main() async {
  if (SqlDatabase.supported) {
    var store = await WebSqlStore.open('test', 'test');
    runThrough(store, 'websql');
  } else {
    querySelector('#websql').text = 'WebSQL is not supported in your browser';
  }

  if (IdbFactory.supported) {
    var store = await IndexedDbStore.open('test', 'test');
    runThrough(store, 'indexeddb');
  } else {
    querySelector('#indexeddb').text =
        'IndexedDB is not supported in your browser';
  }
}
