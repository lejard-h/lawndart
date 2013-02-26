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

class WebSqlAdapter<K, V> extends Store<K, V> {
  
  static final String VERSION = "1";
  static const int INITIAL_SIZE = 5 * 1024 * 1024;
  
  String dbName;
  String storeName;
  int estimatedSize;
  SqlDatabase _db;
  
  WebSqlAdapter(this.dbName, this.storeName, {this.estimatedSize: INITIAL_SIZE});
  
  @override
  Future<bool> open() {
    var completer = new Completer();
    _db = window.openDatabase(dbName, VERSION, dbName, estimatedSize);
    _initDb(completer);
    return completer.future;
  }
  
  void _initDb(Completer completer) {
    var sql = 'CREATE TABLE IF NOT EXISTS $storeName (id NVARCHAR(32) UNIQUE PRIMARY KEY, value TEXT)';

    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        _isOpen = true;
        completer.complete(true);
      });
    }, (error) => completer.completeError(error));
  }
  
  @override
  Future<Iterable<K>> _keys() {
    var sql = 'SELECT id FROM $storeName';
    var completer = new Completer<Iterable<K>>();
    var keys = new Queue<K>();    
    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        for (var i = 0; i < resultSet.rows.length; ++i) {
          var row = resultSet.rows.item(i);
          keys.add(row['id']);
        }
        completer.complete(keys);
      });
    }, (error) => completer.completeError(error));
    
    return completer.future;
  }
  
  @override
  Future _save(V obj, K key) {
    var completer = new Completer();
    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';
    
    _db.transaction((txn) {
      txn.executeSql(upsertSql, [key, obj], (txn, resultSet) {
        completer.complete(true);
      });
    }, (error) => completer.completeError(error));
    
    return completer.future;
  }
  
  @override
  Future<bool> _exists(K key) {
    return _getByKey(key).then((v) => v != null);
  }
  
  @override
  Future<V> _getByKey(K key) {
    var completer = new Completer();
    var sql = 'SELECT value FROM $storeName WHERE id = ?';

    _db.readTransaction((txn) {
      txn.executeSql(sql, [key], (txn, resultSet) {
        if (resultSet.rows.isEmpty) {
          completer.complete(null);
        } else {
          var row = resultSet.rows.item(0);
          completer.complete(row['value']);
        }
      });
    }, (error) => completer.completeError(error));
    
    return completer.future;
  }
  
  @override
  Future _removeByKey(K key) {
    var completer = new Completer();
    var sql = 'DELETE FROM $storeName WHERE id = ?';

    _db.transaction((txn) {
      txn.executeSql(sql, [key], (txn, resultSet) {
        // maybe later, if (resultSet.rowsAffected < 0)
        completer.complete(true);
      });
    }, (error) => completer.completeError(error));
    
    return completer.future;
  }
  
  @override
  Future _nuke() {
    var completer = new Completer();
    
//    var sql = 'TRUNCATE TABLE $storeName';
    var sql = 'DELETE FROM $storeName';
    _db.transaction((txn) {
      txn.executeSql(sql, [],  (txn, resultSet) => completer.complete(true));
    }, (error) => completer.completeError(error));
    return completer.future;
  }
  
  @override
  Future<Iterable<V>> _all() {  
    var sql = 'SELECT id,value FROM $storeName';
    var completer = new Completer<Collection<V>>();
    var values = new Queue<V>();    
    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        for (var i = 0; i < resultSet.rows.length; ++i) {
          var row = resultSet.rows.item(i);
          values.add(row['value']);
        }
        completer.complete(values);
      });
    }, (error) => completer.completeError(error));
    
    return completer.future;
  }
  
  @override
  Future _batch(Map<K, V> objs) {
    var completer = new Completer();
    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';
    
    _db.transaction((txn) {
        for (var key in objs.keys) {
          V obj = objs[key];
          txn.executeSql(upsertSql, [key, obj]);
        }
      },
      (error) => completer.completeError(error),
      () => completer.complete(true)
    );
    
    return completer.future;
  }

  @override
  Future<Iterable<V>> _getByKeys(Iterable<K> _keys) {
    var sql = 'SELECT value FROM $storeName WHERE id = ?';

    var completer = new Completer<Iterable<V>>();
    var values = new Queue<V>();
    
    _db.transaction((txn) {
      _keys.forEach((key) {
        txn.executeSql(sql, [key], (txn, resultSet) {
          if (!resultSet.rows.isEmpty) {
            values.add(resultSet.rows.item(0)['value']);
          }
        });
      });
    },
    (error) => completer.completeError(error),
    () => completer.complete(values));
    
    return completer.future;
  }

  @override
  Future _removeByKeys(Iterable<K> _keys) {
    var sql = 'DELETE FROM $storeName WHERE id = ?'; 
    var completer = new Completer<bool>();
    
    _db.transaction((txn) {
      _keys.forEach((key) {
        // TODO verify I don't need to do anything in the callback
        txn.executeSql(sql, [key]);
      });
    },
    (error) => completer.completeError(error),
    () => completer.complete(true));
    
    return completer.future;
  }

}