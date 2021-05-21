const String CREATE_AUTHENTICATION_V5 = '''
CREATE TABLE authentication (
    token TEXT NOT NULL,
    refresh_token TEXT NOT NULL,
    expiration INT NOT NULL,
    refresh_expiration INT NOT NULL,
)
''';

const String CREATE_COMPANY_V5 = '''
CREATE TABLE company (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    logo TEXT,
    total_members INT DEFAULT 0,
    selected_workspace TEXT,
    permissions TEXT DEFAULT "[]"
)
''';

const String CREATE_WORKSPACE_V5 = '''
CREATE TABLE workspace (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    company_id TEXT NOT NULL,
    logo TEXT,
    user_last_access INT DEFAULT 0,
    total_members INT DEFAULT 0,
    permissions TEXT DEFAULT "[]"
);
CREATE INDEX workspace_company_idx ON workspace(company_id);
''';

const String CREATE_CHANNEL_V5 = '''
CREATE TABLE channel (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    company_id TEXT NOT NULL,
    workspace_id TEXT NOT NULL,
    icon TEXT,
    description TEXT,
    last_activity INT DEFAULT 0,
    user_last_access INT DEFAULT 0,
    visibility TEXT DEFAULT "public",
    members_count INT DEFAULT 0,
    members TEXT DEFAULT "[]",
    last_message TEXT,
    permissions TEXT DEFAULT "[]",
    draft TEXT
);
CREATE INDEX channel_workspace_idx ON channel(workspace_id);
CREATE INDEX channel_company_idx ON channel(company_id);
''';

const String CREATE_MESSAGE_V5 = '''
CREATE TABLE message (
    id TEXT PRIMARY KEY,
    thread_id TEXT,
    channel_id TEXT NOT NULL,
    responses_count INT DEFAULT 0,
    user_id TEXT NOT NULL,
    creation_date INT NOT NULL,
    modification_date INT NOT NULL,
    content TEXT NOT NULL,
    reactions TEXT DEFAULT "[]",
    username TEXT NOT NULL,
    firstname TEXT,
    lastname TEXT,
    thumbnail TEXT,
    draft TEXT,
    is_read INT DEFAULT 1
);
CREATE INDEX message_channel_idx ON message(channel_id);
CREATE INDEX message_thread_idx ON message(thread_id);
''';

const String CREATE_ACCOUNT_V5 = '''
CREATE TABLE account (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    username TEXT NOT NULL,
    firstname TEXT,
    lastname TEXT,
    thumbnail TEXT,
    console_id TEXT,
    status_icon TEXT,
    status TEXT,
    language TEXT,
    last_activity INT NOT NULL
);
CREATE INDEX user_email_idx ON user(email);
CREATE INDEX user_username_idx ON user(username);
CREATE INDEX user_firstname_idx ON message(firstname);
CREATE INDEX user_lastname_idx ON message(lastname);
''';

const String CREATE_GLOBALS_V5 = '''
CREATE TABLE globals (
    user_id TEXT PRIMARY KEY,
    host TEXT NOT NULL,
    company_id TEXT,
    workspace_id TEXT,
    channels_type TEXT NOT NULL,
    tabs TEXT NOT NULL,
    channel_id TEXT,
    thread_id TEXT,
    token TEXT NOT NULL,
    fcm_token TEXT NOT NULL
);
''';

const DDL_V5 = [
  CREATE_AUTHENTICATION_V5,
  CREATE_ACCOUNT_V5,
  CREATE_COMPANY_V5,
  CREATE_WORKSPACE_V5,
  CREATE_CHANNEL_V5,
  CREATE_MESSAGE_V5,
  CREATE_GLOBALS_V5,
];
