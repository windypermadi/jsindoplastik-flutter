import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class SyncProvider with ChangeNotifier {
  bool _isSyncing = false;
  int _pendingCount = 2; // Mock pending offline transactions
  DateTime? _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 45));
  String _syncMessage = 'Siap melakukan sinkronisasi';

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get syncMessage => _syncMessage;

  Future<void> syncNow() async {
    _isSyncing = true;
    _syncMessage = 'Menghubungkan ke API server...';
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(seconds: 2));
      _pendingCount = 0;
      _lastSyncTime = DateTime.now();
      _syncMessage = 'Sinkronisasi lokal (Mock) berhasil! 0 data tertunda.';
      _isSyncing = false;
      notifyListeners();
      return;
    }

    try {
      final response = await ApiService.post(ApiEndpoints.syncPush, {
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (response.isSuccess) {
        _pendingCount = 0;
        _lastSyncTime = DateTime.now();
        _syncMessage = 'Sinkronisasi API server berhasil!';
      } else {
        _syncMessage = 'Gagal sinkronisasi: ${response.message}';
      }
    } catch (e) {
      _syncMessage = 'Error sinkronisasi: ${e.toString()}';
    }

    _isSyncing = false;
    notifyListeners();
  }
}
