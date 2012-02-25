#library('lawndart');

#import('dart:dom', prefix:'dom');
#import('dart:html');
#import('dart:json');

#source('memory-adapter.dart');
#source('local-storage-adapter.dart');
#source('indexeddb-adapter.dart');

_uuid() {
  return "RANDOM STRING";
}

_results(obj) => new Future.immediate(obj);

interface Store<K, V> {
  Future<Collection<K>> keys();
  Future<K> save(V obj, [K key]);
  Future<Collection<K>> batch(List<V> objs, [List<K> _keys]);
  Future<V> getByKey(K key);
  Future<Collection<V>> getByKeys(Collection<K> _keys);
  Future<bool> exists(K key);
  Future<Collection<V>> all();
  Future<bool> removeByKey(K key);
  // TODO: what are the semantics of bool here?
  Future<bool> removeByKeys(Collection<K> _keys);
  Future<bool> nuke();
}

interface Adapter<K, V> extends Store<K, V> {
  String get adapter();
  bool get valid();
}
