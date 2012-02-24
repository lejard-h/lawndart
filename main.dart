#import('lawndart.dart');

main() {
  Lawndart<String, String> lawndart = new Lawndart<String, String>();
  lawndart.save("foo", "bar").then((o) => print("saved $o"));
}
