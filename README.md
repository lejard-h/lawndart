# Lawndart

A unified, asynchronous, easy-to-use library for offline-enabled
browser-based web apps. Kinda sorta a port of Lawnchair to Dart.

[Lawnchair](http://westcoastlogic.com/lawnchair/) is a
"lightweight, adaptive, simple and elegant persistence solution".

Lawndart uses Futures to provide an asynchronous, yet consistent,
interface to local storage, indexed db, and websql.

# Example

	  Store store;
	  
	  var db = new IndexedDb("simple-run-through", ['test']);
	  db.open()
	  .then((_) {
	    store = db.store('test');
	    return store.open();
	  })
	  .then((_) => store.nuke())
	  .then((_) => store.save("world", "hello"))
	  .then((_) => store.save("is fun", "dart"))
	  .then((_) => store.getByKey("hello"))
	  .then((value) => query('#text').text = value);

# License

	Copyright 2013 Seth Ladd
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	    http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.