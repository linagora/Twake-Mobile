import 'migrations.dart';

const String CREATE_MEMBER_V5 = '''
CREATE TABLE member (
    id TEXT PRIMARY KEY,
    type TEXT DEFAULT member,
    notification_level TEXT,
    company_id TEXT NOT NULL,
    workspace_id TEXT NOT NULL,
    channel_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    favorite INT DEFAULT 0,
    is_selected INT DEFAULT 0
);
CREATE INDEX member_user_idx ON user(user_id);
''';

const DDL_V5 = [
  ...DDL_V4,
  ...MIGRATION_5,
];

const MIGRATION_5 = [
  CREATE_MEMBER_V5,
];