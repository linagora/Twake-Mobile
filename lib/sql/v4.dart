import 'migrations.dart';

const String ALTER_CHANNEL_ADD_VISIBILITY = '''
ALTER TABLE channel ADD COLUMN visibility TEXT DEFAULT public;
''';

const DDL_V4 = [
  ...DDL_V3,
  ...MIGRATION_4,
];

const MIGRATION_4 = [
  ALTER_CHANNEL_ADD_VISIBILITY,
];
