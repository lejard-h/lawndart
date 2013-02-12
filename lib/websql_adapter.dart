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
  
  String dbName;
  String storeName;
  int estimatedSize;
  Database _db;
  
  WebSqlAdapter(this.dbName, this.storeName, {this.estimatedSize: 5 * 1024 * 1024});
  
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
        isReady = true;
        completer.complete(true);
      });
    }, (error) => completer.completeError(error));
  }
  
  // TODO
  Future<Collection<K>> keys() {
    throw new UnimplementedError();
  }
  
  Future _save(V obj, K key) {
    String value = JSON.stringify(obj);
    var completer = new Completer<K>();

    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';
    
    _db.transaction((txn) {
      txn.executeSql(upsertSql, [key, value], (txn, resultSet) {
        completer.complete(key);
      });
    }, (error) => completer.completeError(error));
    
    return completer.future;
  }
  
  Future<V> _getByKey(K key) {
    var completer = new Completer<V>();
    
    var sql = 'SELECT value FROM $storeName WHERE id = ?';

    _db.readTransaction((txn) {
      txn.executeSql(sql, [key], (txn, resultSet) {
        var row = resultSet.first;
        if (row == null) {
          completer.complete(null);
        } else {
          completer.complete(JSON.parse(row['value']));
        }
      });
    }, (error) => completer.completeError(error));
    
    return completer.future;
  }
  
  Future<bool> _removeByKey(K key) {
    var completer = new Completer<bool>();
    
    var sql = 'DELETE FROM $storeName WHERE id = ?';

    _db.transaction((txn) {
      txn.executeSql(sql, [key], (txn, resultSet) {
        if (resultSet.rowsAffected < 0) {
          completer.complete(false);
        } else {
          completer.complete(true);
        }
      });
    }, (error) => completer.completeError(error));
    
    return completer.future;
  }
  
  Future<bool> _nuke() {
    Completer<bool> completer = new Completer<bool>();
    
//    var sql = 'TRUNCATE TABLE $storeName';
    var sql = 'DELETE FROM $storeName';
    _db.transaction((txn) {
      txn.executeSql(sql, [], 
          (txn, resultSet) => completer.complete(true), 
          _onError);
    });
    return completer.future;
  }
  
  Future _all() {  
    var sql = 'SELECT id,value FROM $storeName';

    Completer<Collection<V>> completer = new Completer<Collection<V>>();
    var values = [];    
    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        for (var each in resultSet.rows) {
          values.add(each['value']);
        }
        completer.complete(values);
      }, _onError);
    });
    
    return completer.future;
  }
  
  Future _batch(Map<K, V> objs) {
    var completer = new Completer();

    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';
    
    _db.transaction((txn) {
      for (var key in objs.keys) {
        V obj = objs[key];
        var value = JSON.stringify(obj);
        txn.executeSql(upsertSql, [key, value]);
      }
    },
    (error) => completer.completeError(error),
    () { // on success
      completer.complete(true);
    });
    
    return completer.future;
  }

  Future<Iterable<V>> _getByKeys(Iterable<K> _keys) {
    var sql = 'SELECT value FROM $storeName WHERE id = ?';

    var completer = new Completer<Iterable<V>>();
    var values = <V>[];
    
    _db.transaction((txn) {
      _keys.forEach((key) {
        txn.executeSql(sql, [key], (txn, resultSet) {
          values.add(resultSet.rows.item(0).value);
        });
      });
    },
    (error) => completer.completeError(error),
    () => completer.complete(values));
    
    return completer.future;
  }

  Future<bool> _removeByKeys(Iterable<K> _keys) {
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
  
  bool _onError(SqlTransaction transaction, SqlError error){
    print('Database error: ${error.code} ${error.message}');
    return true;
  }
  /*

  Future<bool> exists(K key);
  Future<Collection<K>> keys()
  
  */
}