import 'package:lawndart/lawndart.dart';
import 'dart:html';

main() {
  window.indexedDB.deleteDatabase('temptestdb').then((_) {
    var store = new Store('temptestdb', 'store1');
    store.open().then((_) {
        var store2 = new Store('temptestdb', 'store2');
        return store2.open();
      })
      .then((_) {
        query('#text').text = 'all done';
      });
  });
}