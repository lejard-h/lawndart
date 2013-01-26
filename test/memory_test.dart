import 'package:unittest/unittest.dart';
import 'package:lawndart/lawndart.dart';

main() {
  group('memory', () {
    Store store;
    setUp(() => store = new MemoryAdapter());
    
    test('open', () {
      var future = store.open();
      expect(future, completion(true));
    });
  });
}