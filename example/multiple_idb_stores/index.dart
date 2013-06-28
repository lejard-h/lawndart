import 'package:lawndart/lawndart.dart';
import 'dart:indexed_db';
import 'dart:html';
import 'dart:async';

main() {
  Store store;
  
  window.indexedDB.deleteDatabase('temptestdb').then((_) {
    store = new Store('temptestdb', 'store1');
    store.open()
      .then((_) {
        print('opened 1');
        var store2 = new Store('temptestdb', 'store2');
        return store2.open();
      })
      .then((_) {
        print('opened 2');
        return store.all().toList();
      })
      .then((_) {
        print('all done');
        query('#text').text = 'all done';
      });
  });
  
  
//  window.indexedDB.deleteDatabase('justtesting')
//  .then((_) {
//    print('opening');
//    return window.indexedDB.open('justtesting');
//  })
//  .then((Database db) {
//    if (!db.objectStoreNames.contains('store1')) {
//      db.close();
//      return window.indexedDB.open('justtesting', version: db.version+1,
//          onUpgradeNeeded: (e) {
//            print('upgrading to v1');
//            Database d = e.target.result as Database;
//            d.createObjectStore('store1');
//          },
//          onBlocked: (e) => print('blocked on 1'));
//    } else {
//      return db;
//    }
//  })
//  .then((Database db) {
//    //db.close();
//    return window.indexedDB.open('justtesting');
//  })
//  .then((Database db) {
//    if (!db.objectStoreNames.contains('store2')) {
//      db.close();
//      return window.indexedDB.open('justtesting', version: db.version+1,
//          onUpgradeNeeded: (e) {
//            print('upgrading to v2');
//            Database d = e.target.result as Database;
//            d.createObjectStore('store2');
//          },
//          onBlocked: (e) => print('blocked on 2'));
//    } else {
//      return db;
//    }
//  })
//  .then((db) {
//    print('fetching data');
//    Transaction txn = db.transaction('store1', 'readonly');
//    ObjectStore store = txn.objectStore('store1');
//    store.getObject('1').then(print);
//    return txn.completed;
//  })
//  .then((_) {
//    print('all done');
//  })
//  .catchError(print);
}