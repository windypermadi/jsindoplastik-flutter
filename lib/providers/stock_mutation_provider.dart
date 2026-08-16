import 'package:flutter/foundation.dart';
import '../models/stock_mutation_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class StockMutationProvider with ChangeNotifier {
  List<StockMutationModel> _mutations = [];
  bool _isLoading = false;

  List<StockMutationModel> get mutations => List.unmodifiable(_mutations);
  bool get isLoading => _isLoading;

  StockMutationProvider() {
    fetchMutations();
  }

  Future<void> fetchMutations() async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _mutations = _getMockMutations();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.stockMutations);
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List ? response.data : (response.data['mutations'] ?? []);
      _mutations = list.map((e) => StockMutationModel.fromJson(e)).toList();
    } else {
      _mutations = _getMockMutations();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMutation(StockMutationModel item) async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _mutations.insert(0, item);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    final response = await ApiService.post(ApiEndpoints.stockMutations, item.toJson());
    if (response.isSuccess) {
      _mutations.insert(0, item);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<StockMutationModel> _getMockMutations() {
    return [
      StockMutationModel(
        id: 'M001',
        productId: 'P001',
        productName: 'Kantong Kresek HD Uk. 24 Bening',
        type: MutationType.inbound,
        quantity: 50,
        unit: 'Pack',
        notes: 'Restok Kiriman Pabrik PT Plastik Nusantara',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        userName: 'Bpk. Hendra (Owner)',
      ),
      StockMutationModel(
        id: 'M002',
        productId: 'P005',
        productName: 'Cup Plastik Oval 16oz Heavy',
        type: MutationType.outbound,
        quantity: 2,
        unit: 'Slop',
        notes: 'Kemasan Rusak / Cacat Pabrik',
        date: DateTime.now().subtract(const Duration(days: 1)),
        userName: 'Rudi (Sales)',
      ),
    ];
  }
}
