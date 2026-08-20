import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class UserManagementProvider with ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Pagination & Filter States
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalUsers = 0;
  int _pageSize = 10;
  String _searchQuery = '';
  String? _selectedFilter;

  List<UserModel> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalUsers => _totalUsers;
  int get pageSize => _pageSize;
  String get searchQuery => _searchQuery;
  String? get selectedFilter => _selectedFilter;
  bool get hasNextPage => _currentPage < _lastPage;
  bool get hasPrevPage => _currentPage > 1;

  UserManagementProvider() {
    fetchUsers();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    fetchUsers();
  }

  void setFilter(String? filter) {
    if (filter == 'Semua') {
      _selectedFilter = null;
    } else {
      _selectedFilter = filter;
    }
    _currentPage = 1;
    fetchUsers();
  }

  void setPageSize(int size) {
    _pageSize = size;
    _currentPage = 1;
    fetchUsers();
  }

  Future<void> nextPage() async {
    if (hasNextPage) {
      await fetchUsers(page: _currentPage + 1);
    }
  }

  Future<void> prevPage() async {
    if (hasPrevPage) {
      await fetchUsers(page: _currentPage - 1);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= _lastPage) {
      await fetchUsers(page: page);
    }
  }

  Future<void> fetchUsers({int page = 1, bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    } else {
      _currentPage = page;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      var list = _getMockUsers();
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        list = list.where((u) {
          return u.name.toLowerCase().contains(q) ||
              u.phone.contains(q) ||
              (u.email ?? '').toLowerCase().contains(q);
        }).toList();
      }
      if (_selectedFilter != null && _selectedFilter!.isNotEmpty && _selectedFilter != 'Semua') {
        final f = _selectedFilter!.toLowerCase();
        list = list.where((u) {
          return u.rawRole.toLowerCase() == f || u.role.displayName.toLowerCase() == f;
        }).toList();
      }
      _users = list;
      _totalUsers = list.length;
      _lastPage = 1;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getUsersFiltered(
      page: _currentPage,
      pageSize: _pageSize,
      filter: _selectedFilter,
      query: _searchQuery,
    );

    final response = await ApiService.get(url);
    if (response.isSuccess && response.data != null) {
      final dynamic resData = response.data;
      List rawList = [];

      if (resData is Map) {
        if (resData['data'] is List) {
          rawList = resData['data'] as List;
        } else if (resData['users'] is List) {
          rawList = resData['users'] as List;
        } else if (resData['content'] != null && resData['content']['data'] is List) {
          rawList = resData['content']['data'] as List;
        }

        final contentMap = (resData['content'] is Map) ? resData['content'] : resData;

        _currentPage = int.tryParse(contentMap['current_page']?.toString() ?? '$_currentPage') ?? _currentPage;
        _lastPage = int.tryParse(contentMap['last_page']?.toString() ?? '1') ?? 1;
        _totalUsers = int.tryParse(contentMap['total']?.toString() ?? '${rawList.length}') ?? rawList.length;
        _pageSize = int.tryParse(contentMap['per_page']?.toString() ?? '$_pageSize') ?? _pageSize;
      } else if (resData is List) {
        rawList = resData;
        _totalUsers = rawList.length;
        _lastPage = 1;
      }

      _users = rawList.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      _errorMessage = response.message;
      if (_users.isEmpty) {
        _users = _getMockUsers();
        _totalUsers = _users.length;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<UserModel?> fetchUserDetail(String id) async {
    final isMock = await StorageService.isMockMode();
    if (isMock) {
      return _users.firstWhere((u) => u.id == id, orElse: () => _getMockUsers().first);
    }

    final response = await ApiService.get(ApiEndpoints.userDetail(id));
    if (response.isSuccess && response.data != null) {
      final dataMap = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : <String, dynamic>{};
      return UserModel.fromJson(dataMap);
    }
    return _users.firstWhere((u) => u.id == id, orElse: () => _users.first);
  }

  Future<bool> addUser(Map<String, dynamic> payload) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: payload['name']?.toString() ?? 'User Baru',
        phone: payload['phone']?.toString() ?? '',
        email: payload['email']?.toString(),
        address: payload['address']?.toString(),
        avatar: payload['avatar']?.toString(),
        role: (payload['role']?.toString().toLowerCase().contains('admin') ?? false)
            ? UserRole.admin
            : (payload['role']?.toString().toLowerCase().contains('owner') ?? false)
                ? UserRole.owner
                : UserRole.sales,
        rawRole: payload['role']?.toString() ?? 'Sales',
        isActive: payload['is_active'] ?? true,
      );
      _users.insert(0, newUser);
      _isSubmitting = false;
      notifyListeners();
      return true;
    }

    final response = await ApiService.post(ApiEndpoints.userCreate, payload);
    _isSubmitting = false;

    if (response.isSuccess) {
      await fetchUsers(isRefresh: true);
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> payload) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx != -1) {
        final old = _users[idx];
        _users[idx] = old.copyWith(
          name: payload['name']?.toString() ?? old.name,
          phone: payload['phone']?.toString() ?? old.phone,
          email: payload['email']?.toString() ?? old.email,
          address: payload['address']?.toString() ?? old.address,
          avatar: payload['avatar']?.toString() ?? old.avatar,
          rawRole: payload['role']?.toString() ?? old.rawRole,
          isActive: payload['is_active'] ?? old.isActive,
        );
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    }

    final response = await ApiService.put(ApiEndpoints.userUpdate(id), payload);
    _isSubmitting = false;

    if (response.isSuccess) {
      await fetchUsers(page: _currentPage);
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(String id, bool currentStatus) async {
    final newStatus = !currentStatus;
    final isMock = await StorageService.isMockMode();
    if (isMock) {
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(isActive: newStatus);
        notifyListeners();
        return true;
      }
      return false;
    }

    final response = await ApiService.put(
      ApiEndpoints.userUpdate(id),
      {'is_active': newStatus},
    );

    if (response.isSuccess) {
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(isActive: newStatus);
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteUser(String id) async {
    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    }

    final response = await ApiService.delete(ApiEndpoints.userDelete(id));
    if (response.isSuccess) {
      await fetchUsers(page: _currentPage);
      return true;
    }
    return false;
  }

  List<UserModel> _getMockUsers() {
    return [
      UserModel(
        id: '40c4f2dd-f8d4-4b96-b50d-626ec4889d9d',
        name: 'Lucas Daniel',
        phone: '6281234567892',
        email: 'gstiedemann@hotmail.com',
        role: UserRole.admin,
        rawRole: 'Admin',
        isActive: true,
        updatedAt: '2026-08-15 11:42:19',
        avatar: 'http://poswenapidev.nalentora.cloud/storage/images/default/no-image.png',
      ),
      UserModel(
        id: 'U001',
        name: 'Bpk. Hendra',
        phone: '081234567890',
        email: 'hendra@jsindoplastik.com',
        role: UserRole.owner,
        rawRole: 'Owner',
        isActive: true,
      ),
      UserModel(
        id: 'U002',
        name: 'Rudi',
        phone: '089876543210',
        email: 'rudi@jsindoplastik.com',
        role: UserRole.sales,
        rawRole: 'Sales',
        isActive: true,
      ),
      UserModel(
        id: 'U003',
        name: 'Budi',
        phone: '085211223344',
        email: 'budi@jsindoplastik.com',
        role: UserRole.sales,
        rawRole: 'Sales',
        isActive: false,
      ),
    ];
  }
}
