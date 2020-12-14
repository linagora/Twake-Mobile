import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
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
  final logger = Logger();

  static final ProfileProvider _profileProvider = ProfileProvider._internal();

  factory ProfileProvider() {
    return _profileProvider;
  }

  // making it a singleton
  ProfileProvider._internal() {
    DB.profileLoad().then((p) {
      logger.d('DEBUG: loading profile from local data store');
      _currentProfile = Profile.fromJson(p);

      /// By default we are selecting first company
      /// after trying to retrieve user selected company first
      final selectedCompany = _currentProfile.companies.firstWhere(
          (c) => c.isSelected,
          orElse: () => _currentProfile.companies[0]);
      _selectedCompanyId = selectedCompany.id;

      /// And first workspace in that company
      _selectedWorkspaceId = selectedCompany.workspaces
          .firstWhere((w) => w.isSelected,
              orElse: () => selectedCompany.workspaces[0])
          .id;
      loaded = true;
    }).catchError((e) => logger.d('Error loading profile from data store\n$e'));
  }

  Profile get currentProfile => _currentProfile;

  List<Company> get companies => _currentProfile.companies;
  List<Workspace> get workspaces => _currentProfile.companies
      .firstWhere((c) => c.id == _selectedCompanyId)
      .workspaces;

  bool isMe(String id) => _currentProfile.userId == id;

  List<Workspace> companyWorkspaces(String companyId) {
    return _currentProfile.companies
        .firstWhere((c) => c.id == companyId)
        .workspaces;
  }

  void currentCompanySet(String companyId, {bool notify: true}) {
    _selectedCompanyId = companyId;
    // Select workspace in case of change of company
    // Check if workspace was selected before
    // if nothing is found return first workspace
    var company =
        _currentProfile.companies.firstWhere((c) => c.id == _selectedCompanyId);
    companies.forEach((c) {
      c.isSelected = c.id == companyId;
    });
    var workspace = company.workspaces
        .firstWhere((w) => w.isSelected, orElse: () => workspaces[0]);
    _selectedWorkspaceId = workspace.id;
    if (notify) notifyListeners();
    _updateWorkspaceSelection(_selectedWorkspaceId);
    DB.profileSave(_currentProfile);
  }

  void _updateWorkspaceSelection(String workspaceId) {
    workspaces.forEach((w) {
      w.isSelected = w.id == workspaceId;
    });
  }

  void currentWorkspaceSet(String workspaceId, {bool notify: true}) {
    _selectedWorkspaceId = workspaceId;
    _updateWorkspaceSelection(_selectedWorkspaceId);
    if (notify) notifyListeners();
    workspaces.firstWhere((w) => w.id == workspaceId).isSelected = true;
    DB.profileSave(_currentProfile);
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
    // if (loaded) {
    // return;
    // }
    logger.d('DEBUG: loading profile over network');
    try {
      final response = await api.currentProfileGet();
      // final response = DUMMY_USER;
      final profile = Profile.fromJson(response);
      if (loaded) {
        for (int i = 0;
            i < min(profile.companies.length, _currentProfile.companies.length);
            i++) {
          profile.companies[i].isSelected =
              _currentProfile.companies[i].isSelected;
          final wnew = profile.companies[i].workspaces;
          final wold = _currentProfile.companies[i].workspaces;
          for (int j = 0; j < min(wnew.length, wold.length); j++) {
            wnew[j].isSelected = wold[j].isSelected;
          }
        }
      } else {
        /// By default we are selecting first company
        _selectedCompanyId = profile.companies[0].id;

        /// And first workspace in that company
        _selectedWorkspaceId = profile.companies[0].workspaces[0].id;
      }
      _currentProfile = profile;

      loaded = true;
      DB.profileSave(_currentProfile);
      notifyListeners();
    } catch (error) {
      logger.d('Error while loading user profile\n$error');
      // throw error;
    }
  }
}
