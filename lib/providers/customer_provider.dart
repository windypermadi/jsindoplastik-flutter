import 'package:flutter/foundation.dart';
import '../models/customer_model.dart';
import '../models/user_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class CustomerProvider with ChangeNotifier {
  List<CustomerModel> _customers = [];
  List<UserModel> _salesUsers = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Pagination & Search/Filter
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalCustomers = 0;
  int _pageSize = 10;
  String _searchQuery = '';
  String? _selectedFilter;

  List<CustomerModel> get customers => List.unmodifiable(_customers);
  List<UserModel> get salesUsers => List.unmodifiable(_salesUsers);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalCustomers => _totalCustomers;
  int get pageSize => _pageSize;
  String get searchQuery => _searchQuery;
  String? get selectedFilter => _selectedFilter;
  bool get hasNextPage => _currentPage < _lastPage;
  bool get hasPrevPage => _currentPage > 1;

  CustomerProvider() {
    fetchCustomers();
    fetchSalesUsers();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    fetchCustomers();
  }

  void setFilter(String? filter) {
    if (filter == 'Semua') {
      _selectedFilter = null;
    } else {
      _selectedFilter = filter;
    }
    _currentPage = 1;
    fetchCustomers();
  }

  void setPageSize(int size) {
    _pageSize = size;
    _currentPage = 1;
    fetchCustomers();
  }

  Future<void> nextPage() async {
    if (hasNextPage) {
      await fetchCustomers(page: _currentPage + 1);
    }
  }

  Future<void> prevPage() async {
    if (hasPrevPage) {
      await fetchCustomers(page: _currentPage - 1);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= _lastPage) {
      await fetchCustomers(page: page);
    }
  }

  Future<void> fetchSalesUsers() async {
    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _salesUsers = [
        UserModel(
          id: '40c4f2dd-f8d4-4b96-b50d-626ec4889d9d',
          name: 'Lucas Daniel (Sales)',
          phone: '6281234567892',
          role: UserRole.sales,
        ),
        UserModel(
          id: 'U002',
          name: 'Rudi (Sales)',
          phone: '089876543210',
          role: UserRole.sales,
        ),
      ];
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getUsersFiltered(pageSize: 100);
    final response = await ApiService.get(url);
    if (response.isSuccess && response.data != null) {
      final dynamic resData = response.data;
      List rawList = [];
      if (resData is Map) {
        if (resData['data'] is List) {
          rawList = resData['data'] as List;
        } else if (resData['content'] != null && resData['content']['data'] is List) {
          rawList = resData['content']['data'] as List;
        }
      } else if (resData is List) {
        rawList = resData;
      }
      _salesUsers = rawList.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))).toList();
      notifyListeners();
    }
  }

  Future<void> fetchCustomers({int page = 1, bool isRefresh = false}) async {
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
      var list = _getMockCustomers();
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        list = list.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.phone.contains(q) ||
              (c.address ?? '').toLowerCase().contains(q) ||
              (c.namaToko ?? '').toLowerCase().contains(q);
        }).toList();
      }
      _customers = list;
      _totalCustomers = list.length;
      _lastPage = 1;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getCustomersFiltered(
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
        } else if (resData['customers'] is List) {
          rawList = resData['customers'] as List;
        } else if (resData['content'] != null && resData['content']['data'] is List) {
          rawList = resData['content']['data'] as List;
        }

        final contentMap = (resData['content'] is Map) ? resData['content'] : resData;

        _currentPage = int.tryParse(contentMap['current_page']?.toString() ?? '$_currentPage') ?? _currentPage;
        _lastPage = int.tryParse(contentMap['last_page']?.toString() ?? '1') ?? 1;
        _totalCustomers = int.tryParse(contentMap['total']?.toString() ?? '${rawList.length}') ?? rawList.length;
        _pageSize = int.tryParse(contentMap['per_page']?.toString() ?? '$_pageSize') ?? _pageSize;
      } else if (resData is List) {
        rawList = resData;
        _totalCustomers = rawList.length;
        _lastPage = 1;
      }

      _customers = rawList.map((e) => CustomerModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      _errorMessage = response.message;
      if (_customers.isEmpty) {
        _customers = _getMockCustomers();
        _totalCustomers = _customers.length;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCustomer(Map<String, dynamic> rawBody) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final newCust = CustomerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        salesId: rawBody['sales_id']?.toString(),
        name: rawBody['nama']?.toString() ?? 'Pelanggan Baru',
        phone: rawBody['nomor_telpon']?.toString() ?? '',
        email: rawBody['email']?.toString(),
        address: rawBody['alamat']?.toString(),
        alamatMaps: rawBody['alamat_maps']?.toString(),
        namaToko: rawBody['nama_toko']?.toString(),
        tipeCustomer: int.tryParse(rawBody['tipe_customer']?.toString() ?? '3') ?? 3,
      );
      _customers.insert(0, newCust);
      _isSubmitting = false;
      notifyListeners();
      return true;
    }

    final response = await ApiService.post(ApiEndpoints.customerCreate, rawBody);
    _isSubmitting = false;

    if (response.isSuccess) {
      await fetchCustomers(isRefresh: true);
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(String id, Map<String, dynamic> rawBody) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _customers.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final old = _customers[idx];
        _customers[idx] = old.copyWith(
          salesId: rawBody['sales_id']?.toString() ?? old.salesId,
          name: rawBody['nama']?.toString() ?? old.name,
          phone: rawBody['nomor_telpon']?.toString() ?? old.phone,
          email: rawBody['email']?.toString() ?? old.email,
          address: rawBody['alamat']?.toString() ?? old.address,
          alamatMaps: rawBody['alamat_maps']?.toString() ?? old.alamatMaps,
          namaToko: rawBody['nama_toko']?.toString() ?? old.namaToko,
          tipeCustomer: int.tryParse(rawBody['tipe_customer']?.toString() ?? '3') ?? old.tipeCustomer,
        );
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    }

    var response = await ApiService.post(ApiEndpoints.customerUpdate(id), rawBody);
    if (!response.isSuccess) {
      response = await ApiService.put(ApiEndpoints.customerUpdate(id), rawBody);
    }
    _isSubmitting = false;

    if (response.isSuccess) {
      await fetchCustomers(page: _currentPage);
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    return deleteManyCustomers([id]);
  }

  Future<bool> deleteManyCustomers(List<String> ids) async {
    if (ids.isEmpty) return true;

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _customers.removeWhere((c) => ids.contains(c.id));
      notifyListeners();
      return true;
    }

    final payload = {
      'id': ids,
    };

    var response = await ApiService.delete(ApiEndpoints.customerDeleteMany, payload);
    if (!response.isSuccess && ids.length == 1) {
      response = await ApiService.delete(ApiEndpoints.customerDelete(ids.first));
    }

    if (response.isSuccess) {
      await fetchCustomers(page: _currentPage);
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  List<CustomerModel> _getMockCustomers() {
    return [
      CustomerModel(
        id: 'C001',
        salesId: '40c4f2dd-f8d4-4b96-b50d-626ec4889d9d',
        name: 'Toko Berkah Plastik (Ibu Maryam)',
        phone: '6281298765432',
        email: 'berkahplastik@gmail.com',
        address: 'Jl. Pasar Baru No. 12, Bandung',
        namaToko: 'Toko Berkah Plastik',
        tipeCustomer: 1,
        debtBalance: 450000,
      ),
      CustomerModel(
        id: 'C002',
        salesId: '40c4f2dd-f8d4-4b96-b50d-626ec4889d9d',
        name: 'Depot Es Boba & Juice (Mas Agus)',
        phone: '6285712345678',
        address: 'Jl. Raya Kopo No. 88, Bandung',
        namaToko: 'Depot Es Boba',
        tipeCustomer: 2,
        debtBalance: 0,
      ),
      CustomerModel(
        id: 'C003',
        name: 'Test Customer Retail',
        phone: '6281923812938',
        address: 'Jl. Cibaduyut No. 45',
        tipeCustomer: 3,
        debtBalance: 280000,
      ),
    ];
  }
}
