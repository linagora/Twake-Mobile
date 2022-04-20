import 'package:twake/models/account/account.dart';
import 'package:twake/models/account/account2workspace_hive.dart';
import 'package:twake/models/account/account_hive.dart';
import 'package:twake/models/authentication/authentication.dart';
import 'package:twake/models/authentication/authentication_hive.dart';
import 'package:twake/models/badge/badge.dart' hide BadgeType;
import 'package:twake/models/badge/badge_hive.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/channel/channel_hive.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/company/company_hive.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/globals/globals_hive.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/message/message_hive.dart';
import 'package:twake/models/receive_sharing/shared_location.dart';
import 'package:twake/models/receive_sharing/shared_location_hive.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/models/workspace/workspace_hive.dart';

extension AccountExtension on Account {
  AccountHive toAccountHive() => AccountHive(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        username: username,
        picture: picture,
        providerId: providerId,
        status: status,
        language: language,
        lastActivity: lastActivity,
        recentWorkspaceId: recentWorkspaceId,
        recentCompanyId: recentCompanyId,
        verified: verified,
        deleted: deleted,
      );
}

extension AccountHiveExtension on AccountHive {
  Account toAccount() => Account(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        username: username ?? '',
        picture: picture,
        providerId: providerId,
        status: status,
        language: language,
        lastActivity: lastActivity ?? 0,
        recentWorkspaceId: recentWorkspaceId,
        recentCompanyId: recentCompanyId,
        verified: verified ?? 0,
        deleted: deleted ?? 0,
      );
}

extension AuthenticationExtension on Authentication {
  AuthenticationHive toAuthenticationHive() => AuthenticationHive(
        token: token,
        refreshToken: refreshToken,
        expiration: expiration,
        refreshExpiration: refreshExpiration,
        consoleToken: consoleToken,
        idToken: idToken,
        consoleRefresh: consoleRefresh,
        consoleExpiration: consoleExpiration,
      );
}

extension AuthenticationHiveExtension on AuthenticationHive {
  Authentication toAuthentication() => Authentication(
        token: token,
        refreshToken: refreshToken,
        expiration: expiration,
        refreshExpiration: refreshExpiration,
        consoleToken: consoleToken,
        idToken: idToken,
        consoleRefresh: consoleRefresh,
        consoleExpiration: consoleExpiration,
      );
}

extension BadgeExtension on Badge {
  BadgeHive toBadgeHive() => BadgeHive(
        type: type,
        id: id,
        count: count,
      );
}

extension BadgeHiveExtension on BadgeHive {
  Badge toBadge() => Badge(
        type: type,
        id: id,
        count: count ?? 0,
      );
}

extension Account2WorkspaceExtension on Account2Workspace {
  Account2WorkspaceHive toAccount2WorkspaceHive() => Account2WorkspaceHive(
        userId: userId,
        workspaceId: workspaceId,
      );
}

extension Account2WorkspaceHiveExtension on Account2WorkspaceHive {
  Account2Workspace toAccount2Workspace() => Account2Workspace(
        userId: userId,
        workspaceId: workspaceId,
      );
}

extension CompanyExtension on Company {
  CompanyHive toCompanyHive() => CompanyHive(
        id: id,
        name: name,
        totalMembers: totalMembers,
        logo: logo,
        selectedWorkspace: selectedWorkspace,
        role: role,
      );
}

extension CompanyHiveExtension on CompanyHive {
  Company toCompany() => Company(
        id: id,
        name: name,
        totalMembers: totalMembers,
        logo: logo,
        selectedWorkspace: selectedWorkspace,
        role: role,
      );
}

extension WorkspaceExtension on Workspace {
  WorkspaceHive toWorkspaceHive() => WorkspaceHive(
        id: id,
        name: name,
        logo: logo,
        companyId: companyId,
        totalMembers: totalMembers,
        role: role,
      );
}

extension WorkspaceHiveExtension on WorkspaceHive {
  Workspace toWorkspace() => Workspace(
        id: id,
        name: name,
        logo: logo,
        companyId: companyId,
        totalMembers: totalMembers,
        role: role,
      );
}

extension ChannelExtension on Channel {
  ChannelHive toChannelHive() => ChannelHive(
        id: id,
        name: name,
        icon: icon,
        description: description,
        companyId: companyId,
        workspaceId: workspaceId,
        lastMessage: lastMessage,
        members: members,
        visibility: visibility,
        lastActivity: lastActivity,
        membersCount: membersCount,
        role: role,
        userLastAccess: userLastAccess,
        draft: draft,
        stats: stats,
      );
}

extension ChannelHiveExtension on ChannelHive {
  Channel toChannel() => Channel(
        id: id,
        name: name,
        icon: icon,
        description: description,
        companyId: companyId,
        workspaceId: workspaceId,
        lastMessage: lastMessage,
        members: members,
        visibility: visibility,
        lastActivity: lastActivity,
        membersCount: membersCount,
        role: role,
        userLastAccess: userLastAccess,
        draft: draft,
        stats: stats,
      );
}

extension MessageExtension on Message {
  MessageHive toMessageHive() => MessageHive(
        id: id,
        threadId: threadId,
        channelId: channelId,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        responsesCount: responsesCount,
        text: text,
        blocks: blocks,
        reactions: reactions,
        files: files,
        delivery: Delivery.delivered,
        username: username,
        firstName: firstName,
        lastName: lastName,
        picture: picture,
        draft: draft,
      );
}

extension MessageHiveExtension on MessageHive {
  Message toMessage() => Message(
        id: id,
        threadId: threadId,
        channelId: channelId,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        responsesCount: responsesCount,
        text: text,
        blocks: blocks,
        reactions: reactions,
        files: files,
        delivery: Delivery.delivered,
        username: username,
        firstName: firstName,
        lastName: lastName,
        picture: picture,
        draft: draft,
      );
}

extension GlobalsExtension on Globals {
  GlobalsHive toGlobalsHive() => GlobalsHive(
        host: host,
        companyId: companyId,
        workspaceId: workspaceId,
        channelId: channelId,
        threadId: threadId,
        channelsType: channelsType,
        token: token ?? '',
        fcmToken: fcmToken,
        userId: userId,
        clientId: clientId,
        oidcAuthority: oidcAuthority,
      );
}

extension GlobalsHiveExtension on GlobalsHive {
  Globals toGlobals() => Globals(
        host: host,
        companyId: companyId,
        workspaceId: workspaceId,
        channelId: channelId,
        threadId: threadId,
        channelsType: channelsType,
        token: token,
        fcmToken: fcmToken,
        userId: userId,
      );
}

extension SharedLocationExtension on SharedLocation {
  SharedLocationHive toSharedLocationHive() => SharedLocationHive(
        id: id,
        companyId: companyId,
        workspaceId: workspaceId,
        channelId: channelId,
      );
}

extension SharedLocationHiveExtension on SharedLocationHive {
  SharedLocation toSharedLocation() => SharedLocation(
        id: id,
        companyId: companyId,
        workspaceId: workspaceId,
        channelId: channelId,
      );
}
