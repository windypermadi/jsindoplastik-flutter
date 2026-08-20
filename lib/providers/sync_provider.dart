import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';
import '../models/product_model.dart';
import 'product_provider.dart';

class SyncProvider with ChangeNotifier {
  bool _isSyncing = false;
  double _syncProgress = 0.0;
  int _syncedProductsCount = 0;
  int _localProductsCount = 0;
  DateTime? _lastSyncTime;
  String _syncMessage = 'Siap melakukan sinkronisasi data produk';

  bool get isSyncing => _isSyncing;
  double get syncProgress => _syncProgress;
  int get syncedProductsCount => _syncedProductsCount;
  int get localProductsCount => _localProductsCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get syncMessage => _syncMessage;

  SyncProvider() {
    initSyncState();
  }

  Future<void> initSyncState() async {
    _lastSyncTime = await StorageService.getLastProductSyncTime();
    _localProductsCount = await StorageService.getLocalProductsCount();
    notifyListeners();
  }

  Future<void> syncNow({ProductProvider? productProvider}) async {
    _isSyncing = true;
    _syncProgress = 0.05;
    _syncMessage = 'Menghubungkan ke server {{url}}product/get-all...';
    notifyListeners();

    try {
      final isMock = await StorageService.isMockMode();
      if (isMock) {
        await Future.delayed(const Duration(seconds: 1));
        _syncProgress = 0.5;
        _syncMessage = 'Mengunduh data produk mock...';
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));

        final mockListRaw = [
          {
            "id": "07050da9-e8f7-4ef3-8ab4-d2b9fc50a6c2",
            "name": "TAS K015H",
            "long_name": "TAS HD HITAM BERINGIN KECIL 1532 HIJAU",
            "updated_at": DateTime.now().toIso8601String(),
            "is_active": 1,
            "image": "http://poswenapidev.nalentora.cloud/storage/images/default/no-image.png",
            "tipe": "items",
            "total": 1000
          },
          {
            "id": "0819df64-d52e-4762-938f-26af5788c6a5",
            "name": "SEDOTAN MM",
            "long_name": "PIPET PUTIH TEKUK PREMIUM",
            "updated_at": DateTime.now().toIso8601String(),
            "is_active": 1,
            "image": "http://poswenapidev.nalentora.cloud/storage/images/default/no-image.png",
            "tipe": "items",
            "total": 40
          }
        ];

        final List<Map<String, dynamic>> mockClean = [];
        for (final item in mockListRaw) {
          final model = ProductModel.fromJson(item);
          mockClean.add(model.toJson());
        }

        await StorageService.saveLocalProducts(mockClean);
        _lastSyncTime = DateTime.now();
        await StorageService.saveLastProductSyncTime(_lastSyncTime!);
        _localProductsCount = mockClean.length;
        _syncedProductsCount = mockClean.length;
        _syncProgress = 1.0;
        _syncMessage = 'Sinkronisasi berhasil! ${mockClean.length} produk tersimpan di database lokal.';
        if (productProvider != null) {
          await productProvider.loadLocalProducts();
        }
        return;
      }

      int page = 1;
      int lastPage = 1;
      final List<Map<String, dynamic>> allProductsClean = [];

      do {
        _syncMessage = 'Mengunduh produk halaman $page...';
        notifyListeners();

        final url = ApiEndpoints.getProductsSyncUrl(page: page, pageSize: 50);
        final response = await ApiService.get(url);

        if (response.isSuccess && response.data != null) {
          final dynamic resData = response.data;
          List pageData = [];
          Map? contentMap;

          if (resData is Map) {
            if (resData['content'] is Map) {
              contentMap = resData['content'] as Map;
            } else {
              contentMap = resData;
            }

            if (contentMap['data'] is List) {
              pageData = contentMap['data'] as List;
            } else if (resData['data'] is List) {
              pageData = resData['data'] as List;
            }

            final lp = contentMap['last_page'] ?? resData['last_page'];
            if (lp != null) {
              lastPage = int.tryParse(lp.toString()) ?? lastPage;
            }
          } else if (resData is List) {
            pageData = resData;
            lastPage = 1;
          }

          if (pageData.isEmpty) {
            break;
          }

          for (final item in pageData) {
            if (item is Map) {
              try {
                final model = ProductModel.fromJson(Map<String, dynamic>.from(item));
                allProductsClean.add(model.toJson());
              } catch (_) {
                // Ignore individual item parsing issue
              }
            }
          }

          if (contentMap?['last_page'] == null && resData['last_page'] == null) {
            if (pageData.length >= 50) {
              lastPage = page + 1;
            } else {
              lastPage = page;
            }
          }

          _syncProgress = (page / (lastPage > 0 ? lastPage : 1)).clamp(0.05, 0.95);
          notifyListeners();
          page++;
        } else {
          _syncMessage = 'Gagal mengunduh halaman $page: ${response.message}';
          break;
        }
      } while (page <= lastPage);

      if (allProductsClean.isNotEmpty) {
        _syncMessage = 'Menyimpan ${allProductsClean.length} produk ke database lokal...';
        notifyListeners();

        await StorageService.saveLocalProducts(allProductsClean);
        _lastSyncTime = DateTime.now();
        await StorageService.saveLastProductSyncTime(_lastSyncTime!);

        _localProductsCount = allProductsClean.length;
        _syncedProductsCount = allProductsClean.length;
        _syncProgress = 1.0;
        _syncMessage = 'Sinkronisasi berhasil! $_syncedProductsCount produk tersimpan di database lokal.';

        if (productProvider != null) {
          await productProvider.loadLocalProducts();
        }
      } else {
        if (_syncMessage.startsWith('Mengunduh')) {
          _syncMessage = 'Tidak ada data produk yang berhasil diunduh dari API server.';
        }
      }
    } catch (e) {
      _syncMessage = 'Error sinkronisasi produk: ${e.toString()}';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
