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
  	return idb.batch(['o1', 'o2'], ['k1', 'k2']);
  })
  .chain((v) {
  	p("Stored them!");
  	return idb.all();
  })
  .chain((v) {
  	p('Got them all: $v');
  	return idb.getByKeys(['k1', 'key']);
  })
  .then((v) {
  	p('Got some: $v');
  });
}