import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isMockMode = true;
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
        _currentUser = UserModel.fromJson(response.data);
        notifyListeners();
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
          final data = response.data;
          
          String? token;
          if (data is Map<String, dynamic>) {
            token = data['token'] ?? data['access_token'] ?? data['data']?['token'];
          }

          final userData = (data is Map<String, dynamic> && data.containsKey('user')) 
              ? data['user'] 
              : data;

          _currentUser = UserModel.fromJson(userData is Map<String, dynamic> ? userData : {
            'id': 'e56a74fe-c476-4ce8-8bca-c3cd297ee207',
            'name': 'Ashlynn Donin',
            'phone': phone,
            'role': password.contains('owner') ? 'owner' : 'sales',
          });

          await StorageService.saveSession(
            token: token ?? 'bearer_token_sample',
            user: _currentUser!,
          );

          // Fetch full user info after login
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
    _currentUser = null;
    await StorageService.clearSession();
    notifyListeners();
  }
}
