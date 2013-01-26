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
  
  LocalStorageAdapter() {
    storage = window.localStorage;
  }
  
  List<K> get _allKeys => JSON.parse(storage[INDEX_KEY]);

  Future<bool> open() {
    return new Future.immediate(true);
  }
  
  Future<Iterable<K>> keys() {
    return _results(_allKeys);
  }
  
  Future save(V obj, K key) {
    if (key == null) {
      throw new ArgumentError("key must not be null");
    }
    storage[key] = JSON.stringify(obj);
    return _results(true);
  }
  
  Future batch(Map<K, V> objs) {
    for (var key in objs.keys) {
      var obj = objs[key];
      storage[key] = JSON.stringify(obj);
    }
    return _results(true);
  }
  
  Future<V> getByKey(K key) {
    return _results(storage[key]);
  }
  
  Future<Iterable<V>> getByKeys(Iterable<K> _keys) {
    var values = _keys.mappedBy((key) => storage[key]);
    return _results(values);
  }
  
  Future<bool> exists(K key) {
    return _results(storage[key] != null);
  }
  
  Future<Iterable<V>> all() {
    var values = _allKeys.mappedBy((key) => storage[key]);
    return _results(values);
  }
  
  Future<bool> removeByKey(K key) {
    List<K> _keys = _allKeys;
    _keys.removeRange(_keys.indexOf(key), 1);
    storage.remove(key);
    storage[INDEX_KEY] = JSON.stringify(_keys);
    return _results(true);
  }
  
  Future<bool> removeByKeys(Iterable<K> _keys) {
    _keys.forEach((key) => removeByKey(key));
    return _results(true);
  }
  
  Future<bool> nuke() {
    storage.remove(INDEX_KEY);
    storage.clear();
    return _results(true);
  }
}