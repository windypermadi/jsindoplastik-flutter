import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class UserManagementProvider with ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;

  List<UserModel> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;

  UserManagementProvider() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _users = _getMockUsers();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.users);
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List ? response.data : (response.data['users'] ?? []);
      _users = list.map((e) => UserModel.fromJson(e)).toList();
    } else {
      _users = _getMockUsers();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _users.add(user);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    final response = await ApiService.post(ApiEndpoints.users, user.toJson());
    if (response.isSuccess) {
      await fetchUsers();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(String id) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final old = _users[idx];
      _users[idx] = UserModel(
        id: old.id,
        name: old.name,
        phone: old.phone,
        role: old.role,
        isActive: !old.isActive,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  List<UserModel> _getMockUsers() {
    return [
      UserModel(
        id: 'U001',
        name: 'Bpk. Hendra (Owner)',
        phone: '081234567890',
        role: UserRole.owner,
        isActive: true,
      ),
      UserModel(
        id: 'U002',
        name: 'Rudi (Sales)',
        phone: '089876543210',
        role: UserRole.sales,
        isActive: true,
      ),
      UserModel(
        id: 'U003',
        name: 'Budi (Sales Lapangan)',
        phone: '085211223344',
        role: UserRole.sales,
        isActive: true,
      ),
    ];
  }
}
