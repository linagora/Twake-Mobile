const String ALTER_AUTHENTICATION_ADD_CONSOLE_TOKEN_V6 = '''
ALTER TABLE authentication ADD COLUMN console_token TEXT;
''';
const String ALTER_AUTHENTICATION_ADD_ID_TOKEN_V6 = '''
ALTER TABLE authentication ADD COLUMN id_token TEXT;
''';
const String ALTER_AUTHENTICATION_ADD_CONSOLE_REFRESH_V6 = '''
ALTER TABLE authentication ADD COLUMN console_refresh TEXT;
''';
const String ALTER_AUTHENTICATION_ADD_CONSOLE_EXPIRATION_V6 = '''
ALTER TABLE authentication ADD COLUMN console_expiration int;
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
CREATE INDEX user_firstname_idx ON account(firstname);
''';

const String CREATE_INDEX_ACCOUNT_LASTNAME_V6 = '''
CREATE INDEX user_lastname_idx ON account(lastname);
''';

const DDL_V6 = [
  ALTER_AUTHENTICATION_ADD_CONSOLE_EXPIRATION_V6,
  ALTER_AUTHENTICATION_ADD_CONSOLE_REFRESH_V6,
  ALTER_AUTHENTICATION_ADD_ID_TOKEN_V6,
  ALTER_AUTHENTICATION_ADD_CONSOLE_TOKEN_V6,
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
