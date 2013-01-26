library memory_tests;

import 'package:unittest/unittest.dart';
import 'package:lawndart/lawndart.dart';

main() {
  
  group('memory', () {
    Store store;
    setUp(() => store = new MemoryAdapter());
    
    group('before open', () {
      setUp(() => store = new MemoryAdapter());
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
    });
    
    test('open', () {
      var future = store.open();
      expect(future, completion(true));
    });
    
    group('with no values', () {
      setUp(() => store = new MemoryAdapter());
      test('keys is empty', () {
        var future = store.keys();
        future.then((keys) {
          expect(keys.length, 0);
        });
      });
      
      test('save', () {
        var future = store.save("key", "value");
        expect(future, completion(true));
      });
    });
    
    group('with saved value', () {
      setUp(() => store.save("key", "value"));
      
      test('keys', () {
        
      });
    });
  });
}