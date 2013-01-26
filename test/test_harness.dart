import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'memory_tests.dart' as memory;

main() {
  useHtmlEnhancedConfiguration();
  memory.main();
}