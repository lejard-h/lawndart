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

class WebSqlAdapter<K, V> implements Store<K, V> {
  
  static final String VERSION = "1";
  
  String dbName;
  String storeName;
  int estimatedSize;
  Database _db;
  bool isReady = false;
  
  WebSqlAdapter([Map options]) {
    this.dbName = options['dbName'];
    this.storeName = options['storeName'];
    if (options.containsKey('estimatedSize')) {
      this.estimatedSize = options['estimatedSize'];
    } else {
      this.estimatedSize = 5 * 1024 * 1024;
    }
  }

  _throwNotReady() {
    throw "Database not opened or ready";
  }
  
  Future<bool> open() {
    Completer completer = new Completer();
    _db = window.openDatabase(dbName, VERSION, dbName, estimatedSize);
    _initDb(completer);
    return completer.future;
  }
  
  void _initDb(Completer completer) {
    var sql = 'CREATE TABLE IF NOT EXISTS $storeName (id NVARCHAR(32) UNIQUE PRIMARY KEY, value TEXT)';

    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        isReady = true;
        completer.complete(true);
      });
    }, (error) => completer.completeException(error));
  }
  
  /*
  Future<Collection<K>> keys();
  */
  
  Future<K> save(V obj, [K key]) {
    bool keyProvided() => key != null;

    if (!isReady) _throwNotReady();

    String value = JSON.stringify(obj);

    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';
    var noKeySql = 'INSERT INTO $storeName (value) VALUES (?)';
    var sql = keyProvided() ? upsertSql : noKeySql;
    
    Completer<K> completer = new Completer<K>();
    
    _db.transaction((txn) {
      if (keyProvided()) {
        txn.executeSql(sql, [key, value], (txn, resultSet) {
          completer.complete(key);
        });
      } else {
        txn.executeSql(sql, [value], (txn, resultSet) {
          completer.complete(resultSet.insertId);
        });
      }

    }, (error) => completer.completeException(error));

    
    return completer.future;
  }
  
  Future<V> getByKey(K key) {
    if (!isReady) _throwNotReady();
    
    Completer<V> completer = new Completer<V>();
    
    var sql = 'SELECT value FROM $storeName WHERE id = ?';

    _db.readTransaction((txn) {
      txn.executeSql(sql, [key], (txn, resultSet) {
        completer.complete(JSON.parse(resultSet.rows.item(0).value));
      });
    }, (error) => completer.completeException(error));
    
    return completer.future;
  }
  
  Future<bool> removeByKey(K key) {
    if (!isReady) _throwNotReady();
    
    Completer<bool> completer = new Completer<bool>();
    
    var sql = 'DELETE FROM $storeName WHERE id = ?';

    _db.transaction((txn) {
      txn.executeSql(sql, [key], (txn, resultSet) {
        if (resultSet.rowsAffected < 0) {
          completer.complete(false);
        } else {
          completer.complete(true);
        }
      });
    }, (error) => completer.completeException(error));
    
    return completer.future;
  }
  
  Future<bool> nuke() {
    if (!isReady) _throwNotReady();
    
    Completer<bool> completer = new Completer<bool>();
    
    var sql = 'TRUNCATE TABLE $storeName';

    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        completer.complete(true);
      });
    }, (error) => completer.completeException(error));
    
    return completer.future;
  }
  
  Future all() {
    if (!isReady) _throwNotReady();
    
    var sql = 'SELECT * FROM $storeName';

    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = <V>[];
    
    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        for (var each in resultSet.rows) {
          values.add(each);
        }
        completer.complete(values);
      });
    }, (error) => completer.completeException(error));
    
    return completer.future;
  }
  
  Future<Collection<K>> batch(List<V> objs, [List<K> keys]) {
    if (!isReady) _throwNotReady();
    if (keys != null && objs.length != keys.length) {
      throw "length of _keys must match length of objs";
    }
    
    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var newKeys = <K>[];

    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';
    var noKeySql = 'INSERT INTO $storeName (value) VALUES (?)';
    
    _db.transaction((txn) {
      for (int i = 0; i < objs.length; i++) {
        V obj = objs[i];
        var value = JSON.stringify(obj);
        K key = keys[i];
        
        if (key == null) {
          txn.executeSql(noKeySql, [value], (txn, resultSet) {
            newKeys.add(resultSet.insertId);
          });
        } else {
          txn.executeSql(upsertSql, [key, value], (txn, resultSet) {
            newKeys.add(key);
          });
        }
      }
    }, (error) => completer.completeException(error),
       (success) => completer.complete(newKeys));
    
    return completer.future;
  }

  Future<Collection<V>> getByKeys(Collection<K> _keys) {
    if (!isReady) _throwNotReady();

    var sql = 'SELECT value FROM $storeName WHERE id = ?';

    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = <V>[];
    
    _db.transaction((txn) {
      _keys.forEach((key) {
        txn.executeSql(sql, [key], (txn, resultSet) {
          values.add(resultSet.rows.item(0).value);
        });
      });
    }, (error) => completer.completeException(error),
       (success) => completer.complete(values));
    
    return completer.future;
  }

  Future<bool> removeByKeys(Collection<K> _keys) {
    if (!isReady) _throwNotReady();

    var sql = 'DELETE FROM $storeName WHERE id = ?';
    
    Completer<bool> completer = new Completer<bool>();
    
    _db.transaction((txn) {
      _keys.forEach((key) {
        // TODO verify I don't need to do anything in the callback
        txn.executeSql(sql, [key]);
      });
    }, (error) => completer.completeException(error),
       (success) => completer.complete(true));
    
    return completer.future;
  }
  
  /*

  Future<bool> exists(K key);
  Future<Collection<K>> keys()
  
  */
}