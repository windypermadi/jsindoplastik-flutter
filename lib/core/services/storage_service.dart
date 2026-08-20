import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../constants/api_endpoints.dart';

class StorageService {
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserRole = 'user_role';
  static const String keyBaseUrl = 'api_base_url';
  static const String keyMockMode = 'use_mock_mode';

  static Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyToken, token);
    await prefs.setString(keyUserId, user.id);
    await prefs.setString(keyUserName, user.name);
    await prefs.setString(keyUserPhone, user.phone);
    await prefs.setString(keyUserRole, user.role.name);
  }

  static Future<UserModel?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(keyUserId);
    final name = prefs.getString(keyUserName);
    final phone = prefs.getString(keyUserPhone);
    final roleStr = prefs.getString(keyUserRole);

    if (id == null || name == null || phone == null || roleStr == null) {
      return null;
    }

    final role = roleStr == 'owner' ? UserRole.owner : UserRole.sales;
    return UserModel(
      id: id,
      name: name,
      phone: phone,
      role: role,
    );
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(keyUserId);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserPhone);
    await prefs.remove(keyUserRole);
  }

  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyBaseUrl, url);
    ApiEndpoints.baseUrl = url;
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(keyBaseUrl);
    if (saved != null && saved.isNotEmpty) {
      ApiEndpoints.baseUrl = saved;
      return saved;
    }
    return ApiEndpoints.baseUrl;
  }

  static const String keyLocalProducts = 'local_products_db';
  static const String keyLastProductSync = 'last_product_sync_time';

  static Future<void> saveLocalProducts(List<Map<String, dynamic>> productsJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(productsJson);
      await prefs.setString(keyLocalProducts, jsonStr);
    } catch (_) {
      // Ignore disk storage exception if any
    }
  }

  static Future<List<ProductModel>> getLocalProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyLocalProducts);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List decoded = jsonDecode(jsonStr);
      final List<ProductModel> result = [];
      for (final e in decoded) {
        if (e is Map) {
          try {
            result.add(ProductModel.fromJson(Map<String, dynamic>.from(e)));
          } catch (_) {
            // Ignore single malformed product item
          }
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  static Future<int> getLocalProductsCount() async {
    final products = await getLocalProducts();
    return products.length;
  }

  static Future<void> saveLastProductSyncTime(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastProductSync, dateTime.toIso8601String());
  }

  static Future<DateTime?> getLastProductSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(keyLastProductSync);
    if (str == null || str.isEmpty) return null;
    return DateTime.tryParse(str);
  }

  static Future<void> setMockMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyMockMode, enabled);
  }

  static Future<bool> isMockMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyMockMode) ?? false;
  }
}
