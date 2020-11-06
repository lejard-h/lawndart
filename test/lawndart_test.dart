//Copyright 2014 Google
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

library store_tests;

import 'dart:async';
import 'dart:indexed_db';
import 'package:test/test.dart';
import 'package:lawndart/lawndart.dart';

typedef Future<Store> StoreGenerator();

void run(StoreGenerator generator) {
  late Store store;

  group('with no values', () {
    setUp(() async {
      store = await generator();
      await store.nuke();
    });

    test('keys is empty', () async {
      var keys = await store.keys().toList();
      expect(keys, hasLength(0));
    });

    test('get by key return null', () {
      Future future = store.getByKey("foo");
      expect(future, completion(null));
    });

    test('get by keys return empty collection', () async {
      var list = await store.getByKeys(["foo"]).toList();
      expect(list, hasLength(0));
    });

    test('save completes', () {
      Future future = store.save("value", "key");
      expect(future, completion("key"));
    });

    test('exists returns false', () {
      Future future = store.exists("foo");
      expect(future, completion(false));
    });

    test('all is empty', () {
      Future future = store.all().toList();
      expect(future, completion(hasLength(0)));
    });

    test('remove by key completes', () {
      Future future = store.removeByKey("foo");
      expect(future, completes);
    });

    test('remove by keys completes', () {
      Future future = store.removeByKeys(["foo"]);
      expect(future, completes);
    });

    test('nuke completes', () {
      Future future = store.nuke();
      expect(future, completes);
    });

    test('batch completes', () {
      Future future = store.batch({'foo': 'bar'});
      expect(future, completes);
    });
  });

  group('with a few values', () {
    setUp(() async {
      // ensure it's clear for each test, see http://dartbug.com/8157
      store = await generator();

      await store.nuke();
      await store.save("world", "hello");
      await store.save("is fun", "dart");
    });

    test('keys has them', () {
      Future<Iterable> future = store.keys().toList();
      future.then((Iterable keys) {
        expect(keys, hasLength(2));
        expect(keys, contains("hello"));
        expect(keys, contains("dart"));
      });
      expect(future, completes);
    });

    test('get by key', () {
      Future future = store.getByKey("hello");
      future.then((value) {
        expect(value, "world");
      });
      expect(future, completes);
    });

    test('get by keys', () {
      Future future = store.getByKeys(["hello", "dart"]).toList();
      future.then((values) {
        expect(values, hasLength(2));
        expect(values.contains("world"), true);
        expect(values.contains("is fun"), true);
      });
      expect(future, completes);
    });

    test('exists is true', () {
      Future future = store.exists("hello");
      future.then((exists) {
        expect(exists, true);
      });
      expect(future, completes);
    });

    test('all has everything', () {
      Future future = store.all().toList();
      future.then((all) {
        expect(all, hasLength(2));
        expect(all.contains("world"), true);
        expect(all.contains("is fun"), true);
      });
      expect(future, completes);
    });

    test('remove by key', () {
      Future future =
          store.removeByKey("hello").then((_) => store.all().toList());
      future.then((remaining) {
        expect(remaining, hasLength(1));
        expect(remaining.contains("world"), false);
        expect(remaining.contains("is fun"), true);
      });
      expect(future, completes);
    });
  });
}

void main() {
  group('memory', () {
    run(() => MemoryStore.open());
  });

  group('local storage', () {
    run(() => LocalStorageStore.open());
  });

  if (IdbFactory.supported) {
    group('indexed db store0', () {
      run(() => IndexedDbStore.open("test-db", "test-store0"));
    });
    group('indexed db store1', () {
      run(() => IndexedDbStore.open("test-db", "test-store1"));
    });
  }
}
