#import('lawndart.dart');

main() {
  var idb = new IndexedDbAdapter("test", "test");
  idb.open()
  .chain((v) {
  	print('Database opened');
  	return idb.nuke();
  })
  .chain((v) {
  	print('Nuked!');
  	return idb.save("hello, world", "key");
  })
  .chain((v) {
  	print('Added!');
  	return idb.getByKey("key");
  })
  .then((v) {
  	print("Value is $v");
  });
}