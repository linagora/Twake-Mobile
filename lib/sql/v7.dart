import 'migrations.dart';

const String CREATE_CONFIGURATION_V7 = '''
CREATE TABLE configuration (
  id TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''';

const DDL_V7 = [
  ...DDL_V6,
  ...MIGRATION_7,
];

const MIGRATION_7 = [
  CREATE_CONFIGURATION_V7,
];