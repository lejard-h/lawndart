# Lawndart

A unified, asynchronous, easy-to-use library for offline-enabled
browser-based web apps. Kinda sorta a port of Lawnchair to Dart,
but with Futures and Streams.

Lawndart uses Futures to provide an asynchronous, yet consistent,
interface to local storage, indexed db, and websql. This library is designed
for simple key-value usage, and is not designed for complex transactional
queries. This library prefers simplicity and uniformity over expressiveness.

You can use this library to help deal with the wide array of client-side
storage options. You should be able to write your code against the Lawndart
interface and have it work across browsers that support at least one of the
following: local storage, indexed db, and websql.

# Example
	  
	  var db = new IndexedDbAdapter("simple-run-through", 'test');
	  db.open()
	  .then((_) => db.nuke())
	  .then((_) => db.save("world", "hello"))
	  .then((_) => db.save("is fun", "dart"))
	  .then((_) => db.getByKey("hello"))
	  .then((value) => query('#text').text = value);

See the example/ directory for more sample code.

# API

`Future open()`
Opens the database and makes it available for reading and writing.

`Future nuke()`
Wipes the database clean. All records are deleted.

`Future save(value, key)`
Stores a value accessible by a key.

`Future getByKey(key)`
Retrieves a value, given a key.

`Stream keys()`
Returns all keys.

`Stream all()`
Returns all values.

`Future batch(map)`
Stores all values and their keys.

`Stream getByKeys(keys)`
Returns all values, given keys.

`Future exists(key)`
Returns true if the key exists, or false.

`Future removeByKey(key)`
Removes the value for the key.

`Future removeByKeys(keys)`
Removes all values for the keys.


# Usage

Lawndart does not choose a storage mechanism for you. Instead, you must
make a choice.

Most methods return a Future, like `open` and `save`.
Methods that would return many things, like `all`, return a Stream.

You must call `open()` before you can use the database.
	  
# Supported storage mechanisms

* Indexed DB - Great choice for modern browsers
* WebSQL - Well supported in mobile WebKit browsers, not in Firefox
* Local Storage - Only 5MB, slow, more-or-less universal
* Memory - Good for testing

You can consult [Can I Use?](http://caniuse.com) for a breakdown of browser
support for the various storage technologies.

# Install

Lawndart is a pub package. To install it, and link it into your app,
add lawndart to your pubspec.yaml. For example:

    name: your_cool_app
    dependencies:
      lawndart: any
      
If you use Dart Editor, select your project from the Files view, then go
to Tools, and run Pub Install.

If you use the command line, ensure the Dart SDK is on your path, and
the run: `pub install`

# Support

Lawndart is hosted at https://github.com/sethladd/lawndart

You can file issues at https://github.com/sethladd/lawndart/issues

API docs at https://sethladd.github.com/lawndart/

This library is open source, pull requests welcome!

# Authors

* Seth Ladd (sethladd@gmail.com)

# TODO

* Use streams for getByKeys and all.
* Handle non-String keys and values appropriately.
* Wire into drone.io.

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
