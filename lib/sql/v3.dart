import 'migrations.dart';

const String ALTER_CHANNEL_ADD_HAS_UNREAD = '''
ALTER TABLE channel ADD COLUMN has_unread INT DEFAULT 0;
''';

const String ALTER_DIRECT_ADD_HAS_UNREAD = '''
ALTER TABLE direct ADD COLUMN has_unread INT DEFAULT 0;
''';

const DDL_V3 = [
  ...DDL_V1,
  ...DDL_V2,
  MIGRATION_3,
];

const MIGRATION_3 = [
  ALTER_DIRECT_ADD_HAS_UNREAD,
  ALTER_CHANNEL_ADD_HAS_UNREAD,
];
