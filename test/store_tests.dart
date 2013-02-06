library store_tests;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:lawndart/lawndart.dart';

typedef Store<String, String> StoreGenerator();

run(StoreGenerator generator) {
  Store<String, String> store;
  
  setUp(() => store = generator());
  
  test('open', () {
    var future = store.open();
    expect(future, completion(true));
  });
  
  group('before open', () {
    setUp(() => store = generator());
    
    test('keys throws stateerror', () {
      // TODO replace with type check
      expect(() => store.keys(), throws);
    });
    
    test('save throws stateerror', () {
      expect(() => store.save('key', 'value'), throws);
    });
    
    test('batch throws stateerror', () {
      expect(() => store.batch({'foo': 'bar'}), throws);
    });
    
    test('get by key throws stateerror', () {
      expect(() => store.getByKey('foo'), throws);
    });
    
    test('get by keys throws stateerror', () {
      expect(() => store.getByKeys(['foo']), throws);
    });
    
    test('exists throws stateerror', () {
      expect(() => store.exists('foo'), throws);
    });
    
    test('all throws stateerror', () {
      expect(() => store.all(), throws);
    });
    
    test('remove by key throws stateerror', () {
      expect(() => store.removeByKey('foo'), throws);
    });
    
    test('remove by keys throws stateerror', () {
      expect(() => store.removeByKeys(['foo']), throws);
    });
    
    test('nuke throws stateerror', () {
      expect(() => store.nuke(), throws);
    });
  });
  
  group('with no values', () {
    setUp(() {
      store = generator();
    });
    
    Future asyncSetup() {
      return store.open().then((_) => store.nuke());
    }
    
    test('keys is empty', () {
      var future = asyncSetup().then((_) => store.keys());
      future.then((keys) {
        expect(keys, hasLength(0));
      });
      expect(future, completes);
    });

    test('get by key return null', () {
      var future = asyncSetup().then((_) => store.getByKey("foo"));
      expect(future, completion(null));
    });
    
    test('get by keys return empty collection', () {
      var future = asyncSetup().then((_) => store.getByKeys(["foo"]));
      expect(future, completion(hasLength(0)));
    });
    
    test('save completes', () {
      var future = asyncSetup().then((_) => store.save("key", "value"));
      expect(future, completion(true));
    });
    
    test('exists returns false', () {
      var future = asyncSetup().then((_) => store.exists("foo"));
      expect(future, completion(false));
    });
    
    test('all is empty', () {
      var future = asyncSetup().then((_) => store.all());
      expect(future, completion(hasLength(0)));
    });
    
    test('remove by key completes', () {
      var future = asyncSetup().then((_) => store.removeByKey("foo"));
      expect(future, completes);
    });
    
    test('remove by keys completes', () {
      var future = asyncSetup().then((_) => store.removeByKeys(["foo"]));
      expect(future, completes);
    });
    
    test('nuke completes', () {
      var future = asyncSetup().then((_) => store.nuke());
      expect(future, completes);
    });
    
    test('batch completes', () {
      var future = asyncSetup().then((_) => store.batch({'foo':'bar'}));
      expect(future, completes);
    });
  });
  
  group('with a few values', () {
    setUp(() {
      // ensure it's clear for each test, see http://dartbug.com/8157
      store = generator();
    });
    
    Future asyncSetup() {
      return store.open().then((_) => store.nuke()).then((_) {
        return store.save("world", "hello");
      }).then((_) {
        return store.save("is fun", "dart");
      });
    }
    
    test('keys has them', () {
      Future<Iterable> future = asyncSetup().then((_) => store.keys());
      future.then((Iterable keys) {
          expect(keys, hasLength(2));
          
          // BUG: matchers contains needs to take iterable
//          expect(keys, contains("hello"));
//          expect(keys, contains("dart"));
          
          expect(keys.contains("hello"), true);
          expect(keys.contains("dart"), true);
      });
      expect(future, completes);
    });
    
    test('get by key', () {
      Future future = asyncSetup().then((_) => store.getByKey("hello"));
      future.then((value) {
        expect(value, "world");
      });
      expect(future, completes);
    });
    
    test('get by keys', () {
      Future future = asyncSetup().then((_) => store.getByKeys(["hello", "dart"]));
      future.then((values) {
        expect(values, hasLength(2));
        expect(values.contains("world"), true);
        expect(values.contains("is fun"), true);
      });
      expect(future, completes);
    });
    
    test('exists is true', () {
      Future future = asyncSetup().then((_) => store.exists("hello"));
      future.then((exists) {
        expect(exists, true);
      });
      expect(future, completes);
    });
    
    test('all has everything', () {
      Future future = asyncSetup().then((_) => store.all());
      future.then((all) {
        expect(all, hasLength(2));
        expect(all.contains("world"), true);
        expect(all.contains("is fun"), true);
      });
      expect(future, completes);
    });
  });
}

main() {
  group('memory', () {
    run(() => new MemoryAdapter<String, String>());
  });
  
  group('local storage', () {
    run(() => new LocalStorageAdapter<String, String>());
  });
}