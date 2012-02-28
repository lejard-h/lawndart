#import('lawndart.dart');
#import('dart:html');

p(msg) {
  print(msg);
  var output = document.query('#output');
  var li = new Element.tag('li');
  li.text = msg;
  output.elements.add(li);
}

testAdapter(adapter) {
  adapter.open()
  .chain((v) {
    p('Database opened');
    return adapter.nuke();
  })
  .chain((v) {
    p('Nuked!');
    return adapter.save("hello, world", "key");
  })
  .chain((v) {
    p('Added with key $v!');
    return adapter.save({'x': ['foo', {'bar':2}]}, "map");
  })
  .chain((v) {
    p('Added map of list of maps!');
    return adapter.getByKey("map");
  })
  .chain((v) {
    p("Value is $v and ${v['x']}!");
    return adapter.removeByKey('key');
  })
  .chain((v) {
    p('Removed a single key: $v');
    return adapter.all();
  })
  .chain((v) {
    p("All that's left: $v");
    return adapter.batch(['o1', 'o2', 'o3'], ['k1', 'k2', 'k3']);
  })
  .chain((v) {
    p("Stored three new keys!");
    return adapter.all();
  })
  .chain((v) {
    p('Got them all: $v');
    return adapter.getByKeys(['k1', 'k2']);
  })
  .chain((v) {
    p('Got some: $v');
    return adapter.getByKey('does not exist');
  })
  .chain((v) {
    p('Does not exist: $v');
    return adapter.removeByKeys(['k1', 'k2']);
  })
  .chain((v) {
    p('Removed some: $v');
    return adapter.all();
  })
  .then((v) {
    p('Got all remaining: $v');
  });
}

main() {
  //testAdapter(new IndexedDbAdapter({'dbName': "test", 'storeName': "test"}));
  testAdapter(new WebSqlAdapter({'dbName': "test", 'storeName': "test"}));
}