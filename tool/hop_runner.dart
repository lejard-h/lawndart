library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

void main(List<String> args) {
  addTask('docs', createDartDocTask(['lib/lawndart.dart'],
      linkApi: true,
      excludeLibs: ['meta', 'metadata']));
  runHop(args);
}
