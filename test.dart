#import('lawndart.dart');
#import('dart:html');

p(msg) {
  var output = document.query('#output');
  var li = new Element.tag('li');
  li.text = msg;
  output.elements.add(li);
}

main() {
  var idb = new IndexedDbAdapter("test", "test");
  idb.open()
  .chain((v) {
  	p('Database opened');
  	return idb.nuke();
  })
  .chain((v) {
  	p('Nuked!');
  	return idb.save("hello, world", "key");
  })
  .chain((v) {
  	p('Added!');
  	return idb.getByKey("key");
  })
  .chain((v) {
  	p("Value is $v!");
  	return idb.removeByKey('key');
  })
  .chain((v) {
  	p('Removed a single key: $v');
  	return idb.all();
  })
  .chain((v) {
  	p("All that's left: $v");
  	return idb.batch(['o1', 'o2', 'o3'], ['k1', 'k2', 'k3']);
  })
  .chain((v) {
  	p("Stored three new keys!");
  	return idb.all();
  })
  .chain((v) {
  	p('Got them all: $v');
  	return idb.getByKeys(['k1', 'k2']);
  })
  .chain((v) {
  	p('Got some: $v');
  	return idb.getByKey('does not exist');
  })
  .chain((v) {
  	p('Does not exist: $v');
  	return idb.removeByKeys(['k1', 'k2']);
  })
  .chain((v) {
  	p('Removed some: $v');
  	return idb.all();
  })
  .then((v) {
  	p('Got all remaining: $v');
  });
}