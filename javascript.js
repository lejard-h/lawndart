window.IDBTransaction = window.webkitIDBTransaction;

var dbName = 'TEST';
var storeName = 'TEST';
var VERSION = "1";

var db = null;

function initDb() {
	if (VERSION != db.version) {
		var req = db.setVersion(VERSION);
		req.onsuccess = function(e) {
			db.createObjectStore(storeName);
		};
	}
	saveObject();
}

function saveObject() {
	var id = Date.now();
	var obj = {'x': ['foo', {'bar':2}]};
	var txn = db.transaction(storeName, IDBTransaction.READ_WRITE);
	var req = txn.objectStore(storeName).put(obj, id);
	req.onsuccess = function(e) {
		getObject(id);
	};
}

function getObject(id) {
	var txn = db.transaction(storeName, IDBTransaction.READ_ONLY);
	var req = txn.objectStore(storeName).get(id);
	req.onsuccess = function(e) {
		var obj = e.target.result;
		console.log(obj['x'][1].bar);
	};
}

var req = window.webkitIndexedDB.open(dbName);
req.onsuccess = function(e) {
	db = e.target.result;
	initDb();
};
