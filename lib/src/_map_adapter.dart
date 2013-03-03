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

abstract class _MapAdapter<V> extends Store<V> {
  Map<String, V> storage;

  Future<bool> open() {
    storage = _generateMap();
    _isOpen = true;
    return _results(true);
  }
  
  Map<String, V> _generateMap();
  
  Future<Iterable<String>> _keys() {
    return _results(storage.keys);
  }
  
  Future _save(V obj, String key) {
    storage[key] = obj;
    return _results(true);
  }
  
  Future _batch(Map<String, V> objs) {
    for (var key in objs.keys) {
      storage[key] = objs[key];
    }
    return _results(true);
  }
  
  Future<V> _getByKey(String key) {
    return _results(storage[key]);
  }
  
  Future<Iterable<V>> _getByKeys(Iterable<String> _keys) {
    var values = _keys.map((key) => storage[key]).where((v) => v != null);
    return _results(values);
  }
  
  Future<bool> _exists(String key) {
    return _results(storage.containsKey(key));
  }
  
  Future<Iterable<V>> _all() {
    return _results(storage.values);
  }
  
  Future _removeByKey(String key) {
    storage.remove(key);
    return _results(true);
  }
  
  Future _removeByKeys(Iterable<String> _keys) {
    _keys.forEach((key) => storage.remove(key));
    return _results(true);
  }
  
  Future _nuke() {
    storage.clear();
    return _results(true);
  }
}