import 'package:twake/sql/v1.dart';

const String CREATE_DRAFT_V2 = '''
CREATE TABLE draft (
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL
)
''';

const DDL_V2 = [
  ...DDL_V1,
  ...MIGRATION_2,
];

const MIGRATION_2 = [
  CREATE_DRAFT_V2,
];
