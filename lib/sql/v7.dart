import 'package:twake/sql/v6.dart';

const String ALTER_CHANNEL_ADD_STATS = '''
ALTER TABLE channel ADD COLUMN stats TEXT; 
''';

const DDL_V7 = [
  ...DDL_V6,
  ...MIGRATION_7
];

const MIGRATION_7 = [ALTER_CHANNEL_ADD_STATS];
