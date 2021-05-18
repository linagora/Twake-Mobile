const String CREATE_SETTINGS_V1 = '''
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL
)
''';

const String CREATE_COMPANY_V1 = '''
CREATE TABLE company (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    logo TEXT,
    total_members INT DEFAULT 0,
    is_selected INT DEFAULT 0
)
''';

const String CREATE_WORKSPACE_V1 = '''
CREATE TABLE workspace (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    company_id TEXT NOT NULL,
    logo TEXT,
    color TEXT,
    user_last_access INT,
    total_members INT DEFAULT 0,
    is_selected INT DEFAULT 0
);
CREATE INDEX workspace_company_idx ON workspace(company_id);
''';

const String CREATE_CHANNEL_V1 = '''
CREATE TABLE channel (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    workspace_id TEXT NOT NULL,
    icon TEXT NOT NULL,
    description TEXT,
    last_activity INT,
    user_last_access INT DEFAULT 0,
    has_unread INT DEFAULT 0,
    visibility TEXT DEFAULT "public",
    members_count INT DEFAULT 0,
    last_message TEXT,
    messages_unread INT DEFAULT 0,
    is_selected INT DEFAULT 0
);
CREATE INDEX channel_workspace_idx ON channel(workspace_id);
''';

const String CREATE_DIRECT_V1 = '''
CREATE TABLE direct (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    company_id TEXT NOT NULL,
    members TEXT NOT NULL,
    icon TEXT,
    description TEXT,
    last_activity INT,
    user_last_access INT DEFAULT 0,
    members_count INT DEFAULT 0,
    messages_unread INT DEFAULT 0,
    last_message TEXT,
    is_selected INT DEFAULT 0,
    has_unread INT DEFAULT 0
);
CREATE INDEX direct_company_idx ON direct(company_id);
''';

const String CREATE_MESSAGE_V1 = '''
CREATE TABLE message (
    id TEXT PRIMARY KEY,
    thread_id TEXT,
    channel_id TEXT NOT NULL,
    responses_count INT DEFAULT 0,
    user_id TEXT,
    app_id TEXT,
    creation_date INT NOT NULL,
    content TEXT,
    reactions TEXT,
    is_selected INT DEFAULT 0
);
CREATE INDEX message_channel_idx ON message(channel_id);
CREATE INDEX message_thread_idx ON message(thread_id);
''';

const String CREATE_USER_V1 = '''
CREATE TABLE user (
    id TEXT PRIMARY KEY,
    username TEXT,
    firstname TEXT,
    lastname TEXT,
    thumbnail TEXT
)
''';

const String CREATE_DRAFT_V1 = '''
CREATE TABLE draft (
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL
)
''';

const String CREATE_MEMBER_V1 = '''
CREATE TABLE member (
    id TEXT PRIMARY KEY,
    type TEXT DEFAULT "member",
    notification_level TEXT,
    company_id TEXT NOT NULL,
    workspace_id TEXT NOT NULL,
    channel_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    favorite INT DEFAULT 0,
    is_selected INT DEFAULT 0,
    email TEXT
);
CREATE INDEX member_user_idx ON user(user_id);
''';

const String CREATE_CONFIGURATION_V1 = '''
CREATE TABLE configuration (
  id TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''';

const DDL_V1 = [
  CREATE_SETTINGS_V1,
  CREATE_COMPANY_V1,
  CREATE_WORKSPACE_V1,
  CREATE_CHANNEL_V1,
  CREATE_DIRECT_V1,
  CREATE_MESSAGE_V1,
  CREATE_USER_V1,
  CREATE_DRAFT_V1,
  CREATE_MEMBER_V1,
  CREATE_CONFIGURATION_V1,
];
