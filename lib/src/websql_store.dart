//Copyright 2012 Google
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
class WebSqlStore extends Store {

  static const String VERSION = "1";
  static const int INITIAL_SIZE = 4 * 1024 * 1024;

  String dbName;
  String storeName;
  int estimatedSize;
  SqlDatabase _db;

  WebSqlStore._(this.dbName, this.storeName, {this.estimatedSize: INITIAL_SIZE}) : super._();

  static Future<WebSqlStore> open(String dbName, String storeName, {int estimatedSize: INITIAL_SIZE}) async {
    var store = new WebSqlStore._(dbName, storeName, estimatedSize: estimatedSize);
    await store._open();
    return store;
  }

  /// Returns true if WebSQL is supported on this platform.
  static bool get supported => SqlDatabase.supported;

  @override
  Future<bool> _open() async {
    if (!supported) {
      throw new UnsupportedError('WebSQL is not supported on this platform');
    }
    _db = window.openDatabase(dbName, VERSION, dbName, estimatedSize);
    await _initDb();
    return true;
  }

  Future _initDb() {
    var sql = 'CREATE TABLE IF NOT EXISTS $storeName (id NVARCHAR(32) UNIQUE PRIMARY KEY, value TEXT)';
    return _runInTxn((txn, completer) {
      txn.executeSql(sql, []);
    });
  }

  @override
  Stream<String> keys() {
    var sql = 'SELECT id FROM $storeName';
    return _runInTxnWithResults((txn, controller) {
      txn.executeSql(sql, [], (txn, resultSet) {
        for (var i = 0; i < resultSet.rows.length; ++i) {
          var row = resultSet.rows.item(i);
          controller.add(row['id']);
        }
      });
    });
  }

  @override
  Future save(String obj, String key) {
    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';
    return _runInTxn((txn, completer) {
      txn.executeSql(upsertSql, [key, obj], (t,rs) {
        completer.complete(key);
      });
    });
  }

  @override
  Future<bool> exists(String key) async {
    var v = await getByKey(key);
    return v != null;
  }

  @override
  Future<String> getByKey(String key) {
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
  Future removeByKey(String key) {
    var sql = 'DELETE FROM $storeName WHERE id = ?';

    return _runInTxn((txn, completer) {
      txn.executeSql(sql, [key]);
    });
  }

  @override
  Future nuke() {
    var sql = 'DELETE FROM $storeName';
    return _runInTxn((txn, completer) {
      txn.executeSql(sql, []);
    });
  }

  @override
  Stream<String> all() {
    var sql = 'SELECT id,value FROM $storeName';

    return _runInTxnWithResults((txn, controller) {
      txn.executeSql(sql, [], (txn, resultSet) {
        for (var i = 0; i < resultSet.rows.length; ++i) {
          var row = resultSet.rows.item(i);
          controller.add(row['value']);
        }
      });
    });
  }

  @override
  Future batch(Map<String, String> objs) {
    var upsertSql = 'INSERT OR REPLACE INTO $storeName (id, value) VALUES (?, ?)';

    return _runInTxn((txn, completer) {
      objs.forEach((key, value) {
        txn.executeSql(upsertSql, [key, value]);
      });
    });
  }

  @override
  Stream<String> getByKeys(Iterable<String> _keys) {
    var sql = 'SELECT value FROM $storeName WHERE id = ?';
    return _runInTxnWithResults((txn, controller) {
      _keys.forEach((key) {
        txn.executeSql(sql, [key], (txn, resultSet) {
          if (resultSet.rows.isNotEmpty) {
            controller.add(resultSet.rows.item(0)['value']);
          }
        });
      });
    });
  }

  @override
  Future removeByKeys(Iterable<String> _keys) {
    var sql = 'DELETE FROM $storeName WHERE id = ?';
    return _runInTxn((txn, completer) {
      _keys.forEach((key) {
        txn.executeSql(sql, [key]);
      });
    });
  }

  Future _runInTxn(callback(SqlTransaction txn, Completer completer)) {
    var completer = new Completer();

    _db.transaction((txn) => callback(txn, completer),
        (error) => completer.completeError(error),
        () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

    return completer.future;
  }

  Stream _runInTxnWithResults(callback(SqlTransaction txn, StreamController controller)) {
    var controller = new StreamController();

    _db.transaction((txn) => callback(txn, controller),
        (error) {
          controller.addError(error);
          controller.close();
        },
        () => controller.close());

    return controller.stream;
  }

}
