//Copyright 2012 Seth Ladd
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

#library('lawndart');

#import('dart:html');
#import('dart:json');

#source('memory-adapter.dart');
#source('local-storage-adapter.dart');
#source('indexeddb-adapter.dart');
#source('websql-adapter.dart');

_uuid() {
  throw new NotImplementedException();
}

_results(obj) => new Future.immediate(obj);

interface Store<K, V> {
  Future<bool> open();
  Future<Collection<K>> keys();
  Future<K> save(V obj, [K key]);
  // TODO: no guaranteed ordering of returned keys, so not sure how useful this is
  Future<Collection<K>> batch(List<V> objs, [List<K> keys]);
  Future<V> getByKey(K key);
  Future<Collection<V>> getByKeys(Collection<K> _keys);
  Future<bool> exists(K key);
  Future<Collection<V>> all();
  Future<bool> removeByKey(K key);
  // TODO: what are the semantics of bool here?
  Future<bool> removeByKeys(Collection<K> _keys);
  Future<bool> nuke();
}