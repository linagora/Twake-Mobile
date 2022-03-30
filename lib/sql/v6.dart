const String CREATE_AUTHENTICATION_V5 = '''
CREATE TABLE authentication (
    token TEXT PRIMARY KEY,
    refresh_token TEXT NOT NULL,
    expiration INT NOT NULL,
    refresh_expiration INT NOT NULL,
    console_token TEXT NOT NULL,
    id_token TEXT NOT NULL,
    console_refresh TEXT NOT NULL,
    console_expiration INT NOT NULL
)
''';

const String CREATE_COMPANY_V5 = '''
CREATE TABLE company (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    logo TEXT,
    total_members INT DEFAULT 0,
    selected_workspace TEXT,
    role TEXT NOT NULL
)
''';

const String CREATE_WORKSPACE_V5 = '''
CREATE TABLE workspace (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    company_id TEXT NOT NULL,
    logo TEXT,
    total_members INT DEFAULT 0,
    role TEXT NOT NULL
);
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
    members TEXT DEFAULT "[]",
    members_count INT DEFAULT 0,
    role TEXT NOT NULL,
    last_message TEXT,
    draft TEXT,
    stats TEXT
);
''';

const String CREATE_MESSAGE_V5 = '''
CREATE TABLE message (
    id TEXT PRIMARY KEY,
    thread_id TEXT,
    channel_id TEXT NOT NULL,
    responses_count INT DEFAULT 0,
    user_id TEXT NOT NULL,
    created_at INT NOT NULL,
    updated_at INT NOT NULL,
    text TEXT DEFAULT "",
    files TEXT DEFAULT "[]",
    subtype TEXT,
    blocks TEXT DEFAULT "[]",
    reactions TEXT DEFAULT "[]",
    draft TEXT,
    username TEXT,
    first_name TEXT,
    last_name TEXT,
    picture TEXT,
    is_read INT DEFAULT 1,
    delivery TEXT DEFAULT "delivered",
    pinned_info TEXT DEFAULT "[]"
);
''';

const String CREATE_ACCOUNT_V5 = '''
CREATE TABLE account (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    username TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    picture TEXT,
    provider_id TEXT,
    status TEXT,
    language TEXT,
    is_verified INT DEFAULT 0,
    deleted INT DEFAULT 0,
    last_activity INT NOT NULL,
    workspace_id TEXT,
    company_id TEXT
);
''';

const String CREATE_ACCOUNT2WORKSPACE_V5 = '''
CREATE TABLE account2workspace (
    user_id TEXT,
    workspace_id TEXT,
    UNIQUE(user_id, workspace_id)
);
''';

const String CREATE_GLOBALS_V5 = '''
CREATE TABLE globals (
    user_id TEXT PRIMARY KEY,
    host TEXT NOT NULL,
    company_id TEXT,
    workspace_id TEXT,
    channels_type TEXT DEFAULT "commons",
    tabs TEXT DEFAULT "channels",
    channel_id TEXT,
    thread_id TEXT,
    token TEXT,
    fcm_token TEXT NOT NULL,
    oidc_authority TEXT,
    client_id TEXT
);
''';

const String CREATE_BADGE_V5 = '''
CREATE TABLE badge (
    type TEXT NOT NULL,
    id TEXT PRIMARY KEY,
    count INT DEFAULT 0
);
''';

const String CREATE_SHARED_LOCATION_TABLE_V10 = '''
CREATE TABLE sharedlocation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_id TEXT NOT NULL,
    workspace_id TEXT NOT NULL,
    channel_id TEXT NOT NULL
);
''';

const String CREATE_INDEX_WORKSPACE_COMPANY_V6 = '''
CREATE INDEX workspace_company_idx ON workspace(company_id);
''';

const String CREATE_INDEX_CHANNEL_WORKSPACE_V6 = '''
CREATE INDEX channel_workspace_idx ON channel(workspace_id);
''';

const String CREATE_INDEX_CHANNEL_COMPANY_V6 = '''
CREATE INDEX channel_company_idx ON channel(company_id);
''';

const String CREATE_INDEX_MESSAGE_USER_V6 = '''
CREATE INDEX message_user_idx ON message(user_id);
''';

const String CREATE_INDEX_MESSAGE_CHANNEL_V6 = '''
CREATE INDEX message_channel_idx ON message(channel_id);
''';

const String CREATE_INDEX_MESSAGE_THREAD_V6 = '''
CREATE INDEX message_thread_idx ON message(thread_id);
''';

const String CREATE_INDEX_ACCOUNT_EMAIL_V6 = '''
CREATE INDEX user_email_idx ON account(email);
''';

const String CREATE_INDEX_ACCOUNT_USERNAME_V6 = '''
CREATE INDEX user_username_idx ON account(username);
''';

const String CREATE_INDEX_ACCOUNT_FIRSTNAME_V6 = '''
CREATE INDEX user_firstname_idx ON account(first_name);
''';

const String CREATE_INDEX_ACCOUNT_LASTNAME_V6 = '''
CREATE INDEX user_lastname_idx ON account(last_name);
''';

const DDL_V6 = [
  CREATE_AUTHENTICATION_V5,
  CREATE_ACCOUNT_V5,
  CREATE_ACCOUNT2WORKSPACE_V5,
  CREATE_COMPANY_V5,
  CREATE_WORKSPACE_V5,
  CREATE_CHANNEL_V5,
  CREATE_MESSAGE_V5,
  CREATE_GLOBALS_V5,
  CREATE_BADGE_V5,
  CREATE_SHARED_LOCATION_TABLE_V10,
  CREATE_INDEX_WORKSPACE_COMPANY_V6,
  CREATE_INDEX_CHANNEL_COMPANY_V6,
  CREATE_INDEX_CHANNEL_WORKSPACE_V6,
  CREATE_INDEX_MESSAGE_USER_V6,
  CREATE_INDEX_MESSAGE_CHANNEL_V6,
  CREATE_INDEX_MESSAGE_THREAD_V6,
  CREATE_INDEX_ACCOUNT_EMAIL_V6,
  CREATE_INDEX_ACCOUNT_USERNAME_V6,
  CREATE_INDEX_ACCOUNT_FIRSTNAME_V6,
  CREATE_INDEX_ACCOUNT_LASTNAME_V6,
];
