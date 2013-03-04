library hop_runner;

import 'package:bot/hop.dart';
import 'package:bot/hop_tasks.dart';

void main() {
  addTask('docs', createDartDocTask(['lib/lawndart.dart'],
      linkApi: true,
      excludeLibs: ['meta', 'metadata']));
  runHopCore();
}
