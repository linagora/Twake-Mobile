import 'package:twake/sql/v2.dart';

const String CREATE_TABLE_APPLICATIONS = '''
CREATE TABLE application (
  id TEXT PRIMARY KEY,
  name TEXT,
  icon_url TEXT,
  description TEXT,
  website TEXT
)
''';

const DDL_V3 = [
  ...DDL_V2,
  ...MIGRATION_3,
];

const MIGRATION_3 = [CREATE_TABLE_APPLICATIONS];
