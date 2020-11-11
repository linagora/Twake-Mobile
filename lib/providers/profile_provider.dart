import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/company.dart';
import 'package:twake_mobile/models/profile.dart';
import 'package:twake_mobile/models/workspace.dart';
import 'package:twake_mobile/services/twake_api.dart';

class ProfileProvider with ChangeNotifier {
  Profile _currentProfile;
  bool loaded = false;

  Profile get currentProfile => _currentProfile;

  List<Company> get companies => _currentProfile.companies;

  bool isMe(String id) => _currentProfile.userId == id;

  List<Workspace> companyWorkspaces(String companyId) {
    return _currentProfile.companies
        .firstWhere((c) => c.id == companyId)
        .workspaces;
  }

  String get firstWorkspaceId {
    return _currentProfile.companies[0].workspaces[0].id;
  }

  Future<void> loadProfile(TwakeApi api) async {
    try {
      final response = await api.currentProfileGet();
      _currentProfile = Profile.fromJson(response);
      loaded = true;
      notifyListeners();
    } catch (error) {
      print('Error while loading user profile\n$error');
      throw error;
    }
  }
}
