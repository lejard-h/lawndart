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

part of lawndart;
// TODO: error handling
class LocalStorageAdapter<K extends String, V> implements Store<K, V> {
  static final INDEX_KEY = "__lawndart__keys";
  
  Storage storage;
  
  LocalStorageAdapter([Map options]) {
    storage = window.localStorage;
  }
  
  List<K> get _allKeys() => JSON.parse(storage[INDEX_KEY]);

  Future<bool> open() {
    return new Future.immediate(true);
  }
  
  Future<Collection<K>> keys() {
    return _results(_allKeys);
  }
  
  Future<K> save(V obj, [K key]) {
    key = key == null ? _uuid() : key;
    storage[key] = JSON.stringify(obj);
    return _results(key);
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> keys]) {
    var newKeys = <K>[];
    for (var i = 0; i < objs.length; i++) {
      K key = keys[i];
      key = key == null ? _uuid() : key;
      storage[key] = JSON.stringify(objs[i]);
    }
    return _results(newKeys);
  }
  
  Future<V> getByKey(K key) {
    return _results(storage[key]);
  }
  
  Future<Collection<V>> getByKeys(Collection<K> _keys) {
    var values = _keys.map((key) => storage[key]);
    return _results(values);
  }
  
  Future<bool> exists(K key) {
    return _results(storage[key] != null);
  }
  
  Future<Collection<V>> all() {
    var values = _allKeys.map((key) => storage[key]);
    return _results(values);
  }
  
  Future<bool> removeByKey(K key) {
    List<K> _keys = _allKeys;
    _keys.removeRange(_keys.indexOf(key), 1);
    storage.remove(key);
    storage[INDEX_KEY] = JSON.stringify(_keys);
    return _results(true);
  }
  
  Future<bool> removeByKeys(Collection<K> _keys) {
    _keys.forEach((key) => removeByKey(key));
    return _results(true);
  }
  
  Future<bool> nuke() {
    storage.remove(INDEX_KEY);
    storage.clear();
    return _results(true);
  }
}