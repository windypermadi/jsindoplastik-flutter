import 'package:flutter/foundation.dart';
import '../models/kasbon_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class KasbonProvider with ChangeNotifier {
  List<KasbonModel> _kasbonList = [];
  String _filterStatus = 'Semua';
  String _searchQuery = '';
  bool _isLoading = false;

  List<KasbonModel> get kasbonList {
    return _kasbonList.where((k) {
      final matchesStatus = _filterStatus == 'Semua' || k.status == _filterStatus;
      final matchesSearch = k.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          k.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  double get totalActiveKasbon => _kasbonList
      .where((k) => k.status != 'Lunas')
      .fold(0.0, (sum, k) => sum + k.remainingDebt);

  String get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  KasbonProvider() {
    fetchKasbon();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchKasbon() async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _kasbonList = _getMockKasbon();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.kasbon);
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List ? response.data : (response.data['kasbon'] ?? []);
      _kasbonList = list.map((e) => KasbonModel.fromJson(e)).toList();
    } else {
      _kasbonList = _getMockKasbon();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> payKasbon(String id, double payAmount) async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _kasbonList.indexWhere((k) => k.id == id);
      if (idx != -1) {
        final current = _kasbonList[idx];
        final newPaid = current.paidAmount + payAmount;
        final newRemaining = current.totalDebt - newPaid;
        final newStatus = newRemaining <= 0 ? 'Lunas' : 'Sebagian';

        _kasbonList[idx] = KasbonModel(
          id: current.id,
          customerId: current.customerId,
          customerName: current.customerName,
          orderNumber: current.orderNumber,
          totalDebt: current.totalDebt,
          paidAmount: newPaid,
          remainingDebt: newRemaining < 0 ? 0 : newRemaining,
          status: newStatus,
          date: current.date,
          dueDate: current.dueDate,
          notes: current.notes,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    final response = await ApiService.post(ApiEndpoints.kasbonPay, {
      'kasbon_id': id,
      'amount': payAmount,
    });

    if (response.isSuccess) {
      await fetchKasbon();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<KasbonModel> _getMockKasbon() {
    return [
      KasbonModel(
        id: 'K001',
        customerId: 'C001',
        customerName: 'Toko Berkah Plastik (Ibu Maryam)',
        orderNumber: 'INV-20260815-001',
        totalDebt: 450000,
        paidAmount: 150000,
        remainingDebt: 300000,
        status: 'Sebagian',
        date: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 5)),
        notes: 'Hutang kantong kresek & thinwall',
      ),
      KasbonModel(
        id: 'K002',
        customerId: 'C003',
        customerName: 'Warung Makan Sederhana (Pak Bambang)',
        orderNumber: 'INV-20260814-004',
        totalDebt: 280000,
        paidAmount: 0,
        remainingDebt: 280000,
        status: 'Belum Lunas',
        date: DateTime.now().subtract(const Duration(days: 3)),
        dueDate: DateTime.now().add(const Duration(days: 4)),
        notes: 'Pembelian mika bento & sendok',
      ),
    ];
  }
}
