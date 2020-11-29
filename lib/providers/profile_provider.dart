import 'package:flutter/foundation.dart';
import 'package:twake_mobile/models/company.dart';
import 'package:twake_mobile/models/profile.dart';
import 'package:twake_mobile/models/workspace.dart';
import 'package:twake_mobile/services/db.dart';
import 'package:twake_mobile/services/twake_api.dart';

class ProfileProvider with ChangeNotifier {
  Profile _currentProfile;
  bool loaded = false;
  String _selectedCompanyId;
  String _selectedWorkspaceId;

  ProfileProvider() {
    DB.profileLoad().then((p) {
      print('DEBUG: loading profile from local data store');
      _currentProfile = Profile.fromJson(p);

      /// By default we are selecting first company
      _selectedCompanyId = _currentProfile.companies[0].id;

      /// And first workspace in that company
      _selectedWorkspaceId = _currentProfile.companies[0].workspaces[0].id;
      loaded = true;
    }).catchError((e) => print('Error loading profile from data store\n$e'));
  }

  Profile get currentProfile => _currentProfile;

  List<Company> get companies => _currentProfile.companies;

  bool isMe(String id) => _currentProfile.userId == id;

  List<Workspace> companyWorkspaces(String companyId) {
    return _currentProfile.companies
        .firstWhere((c) => c.id == companyId)
        .workspaces;
  }

  void currentCompanySet(String companyId) {
    _selectedCompanyId = companyId;
    notifyListeners();
  }

  void currentWorkspaceSet(String workspaceId) {
    _selectedWorkspaceId = workspaceId;
    notifyListeners();
  }

  Company get selectedCompany {
    return _currentProfile.companies
        .firstWhere((c) => c.id == _selectedCompanyId);
  }

  Workspace get selectedWorkspace {
    return selectedCompany.workspaces
        .firstWhere((w) => w.id == _selectedWorkspaceId);
  }

  void logout(TwakeApi api) {
    _currentProfile = null;
    _selectedCompanyId = null;
    _selectedWorkspaceId = null;
    loaded = false;
    DB.profileClean();
    api.isAuthorized = false;
  }

  Future<void> loadProfile(TwakeApi api) async {
    // if (loaded) return;
    print('DEBUG: loading profile over network');
    try {
      print('MAKING REQUEST');
      final response = await api.currentProfileGet();
      print('PARSING REQUEST');
      // final response = DUMMY_USER;
      _currentProfile = Profile.fromJson(response);

      /// By default we are selecting first company
      _selectedCompanyId = _currentProfile.companies[0].id;

      /// And first workspace in that company
      _selectedWorkspaceId = _currentProfile.companies[0].workspaces[0].id;
      loaded = true;
      print('SAVING DATA TO STORE');
      DB.profileSave(_currentProfile);
      notifyListeners();
    } catch (error) {
      print('Error while loading user profile\n$error');
      // throw error;
    }
  }
}
