import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isMockMode = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isMockMode => _isMockMode;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  UserRole get role => _currentUser?.role ?? UserRole.sales;
  bool get isOwner => _currentUser?.role == UserRole.owner;
  bool get isSales => _currentUser?.role == UserRole.sales;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isMockMode = await StorageService.isMockMode();
    _currentUser = await StorageService.getUserSession();
    if (_currentUser != null) {
      fetchUserInfo();
    }
    notifyListeners();
  }

  Future<void> toggleMockMode(bool value) async {
    _isMockMode = value;
    await StorageService.setMockMode(value);
    notifyListeners();
  }

  Future<void> fetchUserInfo() async {
    if (_isMockMode) return;

    try {
      final response = await ApiService.get(ApiEndpoints.getUserInfo);
      if (response.isSuccess && response.data != null) {
        final dynamic resData = response.data;
        final userData = (resData is Map && resData['content'] != null)
            ? resData['content']
            : (resData is Map && resData['data'] != null)
                ? resData['data']
                : resData;

        if (userData is Map<String, dynamic>) {
          _currentUser = UserModel.fromJson(userData);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_isMockMode) {
        await Future.delayed(const Duration(milliseconds: 600));

        UserRole role = UserRole.sales;
        String name = 'Ashlynn Donin';

        if (phone.contains('891') || phone.contains('owner') || password.contains('owner')) {
          role = UserRole.owner;
          name = 'Ashlynn Donin';
        } else {
          name = 'Loma Zieme';
        }

        _currentUser = UserModel(
          id: 'e56a74fe-c476-4ce8-8bca-c3cd297ee207',
          name: name,
          phone: phone,
          email: 'linnea19@yahoo.com',
          address: 'Jalan Beo, Catur tunggal, Demangan Yogyakarta',
          avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
          role: role,
        );

        await StorageService.saveSession(
          token: 'mock_bearer_token_${_currentUser!.id}',
          user: _currentUser!,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Real REST API Call to {{url}}auth/login
        final response = await ApiService.post(ApiEndpoints.login, {
          'phone': phone,
          'password': password,
        });

        if (response.isSuccess && response.data != null) {
          final dynamic resData = response.data;
          Map<String, dynamic> dataMap = {};
          if (resData is Map<String, dynamic>) {
            if (resData['content'] is Map<String, dynamic>) {
              dataMap = resData['content'];
            } else if (resData['data'] is Map<String, dynamic>) {
              dataMap = resData['data'];
            } else {
              dataMap = resData;
            }
          }

          String? token = dataMap['token']?.toString() ??
              dataMap['access_token']?.toString() ??
              (resData is Map ? resData['token']?.toString() : null);

          UserRole role = UserRole.sales;
          if (phone.contains('891') || password.toLowerCase().contains('owner')) {
            role = UserRole.owner;
          }

          final userData = (dataMap['user'] is Map<String, dynamic>) ? dataMap['user'] : null;

          _currentUser = userData != null
              ? UserModel.fromJson(userData)
              : UserModel(
                  id: '1',
                  name: role == UserRole.owner ? 'Owner POS' : 'Sales POS',
                  phone: phone,
                  role: role,
                );

          if (token != null && token.isNotEmpty) {
            await StorageService.saveSession(
              token: token,
              user: _currentUser!,
            );
          }

          // Fetch full profile user info with Bearer token
          await fetchUserInfo();

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = response.message;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan login: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfileDetails({
    required String name,
    required String phone,
    required String address,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        address: address,
        avatar: avatarUrl ?? _currentUser!.avatar,
      );

      final token = await StorageService.getToken();
      if (token != null) {
        await StorageService.saveSession(token: token, user: _currentUser!);
      }
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    if (!_isMockMode) {
      try {
        await ApiService.post(ApiEndpoints.logout, {});
      } catch (e) {
        debugPrint('Logout API error: $e');
      }
    }

    _currentUser = null;
    await StorageService.clearSession();
    _isLoading = false;
    notifyListeners();
  }
}
