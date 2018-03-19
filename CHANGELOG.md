## 0.10.0

* Dart 2 compliance

## 0.9.0

* BREAKING CHANGE: creating and opening a store are the same operation
  open() is a static method on Store
* Using the new async/await/async*/yield features.
* BREAKING CHANGE: No more generics. Stores are simply String => String stores now.

## 0.6.5

* Reduce size of WebSQL down to 4MB, avoids permission check.

## 0.6.2

* Update to SDK version 0.8.5
* Remove old web_ui example

## 0.6.1

* Fix bug with chained opens of multiple stores, followed by a read.

## 0.6.0

* No more explicit version for indexed, it's automatically handled.
* Better support for multiple store names per IndexedDB.
  * Thanks to https://github.com/davidB

## 0.5.0

* Added factory constructor to automatically choose the best store.
* Updated to hop standalone.

## 0.4.2

* Added IndexedDbStore.supported
* Added WebSqlStore.supported
* Renamed all the adapters to stores
* The TODO sample app now works in Safari, Chrome, and Firefox
