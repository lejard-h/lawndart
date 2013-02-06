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
    
  });
//    
//    test('get by key return null', () {
//      var future = store.getByKey("foo");
//      expect(future, completion(null));
//    });
//    
//    test('get by keys return empty collection', () {
//      var future = store.getByKeys(["foo"]);
//      expect(future, completion(hasLength(0)));
//    });
//    
//    test('save completes', () {
//      var future = store.save("key", "value");
//      expect(future, completion(true));
//    });
//    
//    test('exists returns false', () {
//      var future = store.exists("foo");
//      expect(future, completion(false));
//    });
//    
//    test('all is empty', () {
//      var future = store.all();
//      expect(future, completion(hasLength(0)));
//    });
//    
//    test('remove by key completes', () {
//      var future = store.removeByKey("foo");
//      expect(future, completes);
//    });
//    
//    test('remove by keys completes', () {
//      var future = store.removeByKeys(["foo"]);
//      expect(future, completes);
//    });
//    
//    test('nuke completes', () {
//      var future = store.nuke();
//      expect(future, completes);
//    });
//    
//    test('batch completes', () {
//      var future = store.batch({'foo':'bar'});
//      expect(future, completes);
//    });
//  });
  
//  group('with a few values', () {
//    setUp(() {
//      // ensure it's clear for each test, see http://dartbug.com/8157
//      store = generator();
//    });
//    
//    Future asyncSetup() {
//      store.open().then((_) => store.nuke()).then((_) => store.save("hello", "world"));
//    }
//    
//    test('keys has it', () {
//      asyncSetup().then((_) {
//        var future = store.keys();
//        future.then((keys) {
//          expect(keys, hasLength(1));
//          expect(keys.first, "world");
//        });
//        expect(future, completes);
//      });
//    });
//  });
}

main() {
  group('memory', () {
    run(() => new MemoryAdapter<String, String>());
  });
  
  group('local storage', () {
    run(() => new LocalStorageAdapter<String, String>());
  });
}