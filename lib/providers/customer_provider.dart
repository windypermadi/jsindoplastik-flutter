import 'package:flutter/foundation.dart';
import '../models/customer_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class CustomerProvider with ChangeNotifier {
  List<CustomerModel> _customers = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<CustomerModel> get customers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery);
    }).toList();
  }

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  CustomerProvider() {
    fetchCustomers();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _customers = _getMockCustomers();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.customers);
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List ? response.data : (response.data['customers'] ?? []);
      _customers = list.map((e) => CustomerModel.fromJson(e)).toList();
    } else {
      _customers = _getMockCustomers();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCustomer(CustomerModel customer) async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _customers.add(customer);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    final response = await ApiService.post(ApiEndpoints.customers, customer.toJson());
    if (response.isSuccess) {
      await fetchCustomers();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<CustomerModel> _getMockCustomers() {
    return [
      CustomerModel(
        id: 'C001',
        name: 'Toko Berkah Plastik (Ibu Maryam)',
        phone: '081298765432',
        address: 'Jl. Pasar Baru No. 12, Bandung',
        debtBalance: 450000,
      ),
      CustomerModel(
        id: 'C002',
        name: 'Depot Es Boba & Juice (Mas Agus)',
        phone: '085712345678',
        address: 'Jl. Raya Kopo No. 88, Bandung',
        debtBalance: 0,
      ),
      CustomerModel(
        id: 'C003',
        name: 'Warung Makan Sederhana (Pak Bambang)',
        phone: '081377889900',
        address: 'Jl. Cibaduyut No. 45',
        debtBalance: 280000,
      ),
      CustomerModel(
        id: 'C004',
        name: 'Katering Sedap Rasa (Ibu Ani)',
        phone: '089611223344',
        address: 'Komplek Permata Indah B4',
        debtBalance: 0,
      ),
    ];
  }
}
