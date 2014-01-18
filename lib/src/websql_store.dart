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

/**
 * Wraps the WebSQL API and exposes it as a [Store].
 * WebSQL is a transactional database.
 */
class WebSqlStore<V> extends Store<V> {

  static final String VERSION = "1";
  static const int INITIAL_SIZE = 4 * 1024 * 1024;

  String dbName;
  String storeName;
  int estimatedSize;
  SqlDatabase _db;

  WebSqlStore(this.dbName, this.storeName, {this.estimatedSize: INITIAL_SIZE}) : super._();

  /// Returns true if WebSQL is supported on this platform.
  static bool get supported => SqlDatabase.supported;

  @override
  Future<bool> open() {
    if (!supported) {
      return new Future.error(
        new UnsupportedError('WebSQL is not supported on this platform'));
    }
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
  Stream<String> _keys() {
    var sql = 'SELECT id FROM $storeName';
    var controller = new StreamController();
    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        for (var i = 0; i < resultSet.rows.length; ++i) {
          var row = resultSet.rows.item(i);
          controller.add(row['id']);
        }
      });
    },
    (error) => controller.addError(error),
    () => controller.close());

    return controller.stream;
  }

  @override
  Future _save(V obj, String key) {
    var completer = new Completer();
    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';

    _db.transaction((txn) {
      txn.executeSql(upsertSql, [key, obj], (txn, resultSet) {
        completer.complete(key);
      });
    }, (error) => completer.completeError(error));

    return completer.future;
  }

  @override
  Future<bool> _exists(String key) {
    return _getByKey(key).then((v) => v != null);
  }

  @override
  Future<V> _getByKey(String key) {
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
  Future _removeByKey(String key) {
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

    var sql = 'DELETE FROM $storeName';
    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) => completer.complete(true));
    }, (error) => completer.completeError(error));
    return completer.future;
  }

  @override
  Stream<V> _all() {
    var sql = 'SELECT id,value FROM $storeName';
    var controller = new StreamController<V>();
    _db.transaction((txn) {
      txn.executeSql(sql, [], (txn, resultSet) {
        for (var i = 0; i < resultSet.rows.length; ++i) {
          var row = resultSet.rows.item(i);
          controller.add(row['value']);
        }
      });
    },
    (error) => controller.addError(error),
    () => controller.close());

    return controller.stream;
  }

  @override
  Future _batch(Map<String, V> objs) {
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
  Stream<V> _getByKeys(Iterable<String> _keys) {
    var sql = 'SELECT value FROM $storeName WHERE id = ?';

    var controller = new StreamController<V>();

    _db.transaction((txn) {
      _keys.forEach((key) {
        txn.executeSql(sql, [key], (txn, resultSet) {
          if (!resultSet.rows.isEmpty) {
            controller.add(resultSet.rows.item(0)['value']);
          }
        });
      });
    },
    (error) => controller.addError(error),
    () => controller.close());

    return controller.stream;
  }

  @override
  Future _removeByKeys(Iterable<String> _keys) {
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
