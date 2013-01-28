library memory_tests;

import 'package:unittest/unittest.dart';
import 'package:lawndart/lawndart.dart';

main() {
  
  Store<String, String> store;
  
  group('memory', () {
    
    setUp(() => store = new MemoryAdapter<String, String>());
    
    test('open', () {
      var future = store.open();
      expect(future, completion(true));
    });
    
    group('before open', () {
      setUp(() => store = new MemoryAdapter<String, String>());
      
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
        // ensure it's clear for each test, see http://dartbug.com/8157
        store = new MemoryAdapter<String, String>();
        store.open();
      });
      
      test('keys is empty', () {
        var future = store.keys();
        expect(future, completion(hasLength(0)));
          // See http://dartbug.com/8159
          //expect(future, completion(isEmpty));
      });
      
      test('get by key return null', () {
        var future = store.getByKey("foo");
        expect(future, completion(null));
      });
      
      test('save returns true', () {
        var future = store.save("key", "value");
        expect(future, completion(true));
      });
      
      test('exists returns false', () {
        var future = store.exists("foo");
        expect(future, completion(false));
      });
    });
  });
}