import 'package:twake/sql/v3.dart';

const String CREATE_TABLE_USER2WORKSPACE = '''
CREATE TABLE user2workspace (
    user_id TEXT,
    workspace_id TEXT
);
''';

const DDL_V4 = [
  ...DDL_V3,
  ...MIGRATION_4,
];

const MIGRATION_4 = [CREATE_TABLE_USER2WORKSPACE];
