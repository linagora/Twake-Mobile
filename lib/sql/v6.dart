import 'migrations.dart';

const String ALTER_MEMBER_ADD_EMAIL = '''
ALTER TABLE member ADD COLUMN email TEXT; 
''';

const String ALTER_CHANNEL_ADD_LAST_ACCESS = '''
ALTER TABLE channel ADD COLUMN user_last_access INT DEFAULT 0; 
''';

const String ALTER_DIRECT_ADD_LAST_ACCESS = '''
ALTER TABLE direct ADD COLUMN user_last_access INT DEFAULT 0; 
''';

const DDL_V6 = [
  ...DDL_V5,
  ...MIGRATION_6,
];

const MIGRATION_6 = [
  ALTER_MEMBER_ADD_EMAIL,
  ALTER_CHANNEL_ADD_LAST_ACCESS,
  ALTER_DIRECT_ADD_LAST_ACCESS,
];
