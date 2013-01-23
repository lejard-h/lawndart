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

library lawndart;

import 'dart:html';
import 'dart:indexed_db' as idb;
import 'dart:json' as JSON;
import 'dart:async';

part 'indexeddb-adapter.dart';
part 'memory-adapter.dart';
part 'local-storage-adapter.dart';
part 'websql-adapter.dart';

_results(obj) => new Future.immediate(obj);

abstract class Store<K, V> {
  Future open();
  Future<Iterable<K>> keys();
  Future save(V obj, K key);
  Future batch(Map<K, V> objectsByKey);
  Future<V> getByKey(K key);
  Future<Iterable<V>> getByKeys(Iterable<K> _keys);
  Future<bool> exists(K key);
  Future<Iterable<V>> all();
  Future<bool> removeByKey(K key);
  // TODO: what are the semantics of bool here?
  Future<bool> removeByKeys(Iterable<K> _keys);
  Future<bool> nuke();
}
