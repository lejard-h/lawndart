#library('test');

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
  .chain((v) => idb.nuke())
  .chain((v) => idb.save("hello, world", "key"))
  .chain((v) => idb.getByKey("key"))
  .chain((v) => idb.removeByKey('key'))
  .chain((v) => idb.all())
  .chain((v) => idb.batch(['o1', 'o2', 'o3'], ['k1', 'k2', 'k3']))
  .chain((v) => idb.all())
  .chain((v) => idb.getByKeys(['k1', 'k2']))
  .chain((v) => idb.getByKey('does not exist'))
  .chain((v) => idb.removeByKeys(['k1', 'k2']))
  .chain((v) => idb.all())
  .then((v) => p('Got all remaining: $v'));
}