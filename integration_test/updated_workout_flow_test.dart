import 'package:integration_test/integration_test.dart';

import '../test/updated_workout_flow_test.dart' as regression;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  regression.main();
}
