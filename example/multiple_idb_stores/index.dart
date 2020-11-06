import 'package:lawndart/lawndart.dart';
import 'dart:html';

main() async {
  await window.indexedDB?.deleteDatabase('temptestdb');
  Store store = await Store.open('temptestdb', 'store1');
  print('opened 1');
  await Store.open('temptestdb', 'store2');
  print('opened 2');
  await store.all().toList();
  print('all done');
  querySelector('#text')?.text = 'all done';
}
