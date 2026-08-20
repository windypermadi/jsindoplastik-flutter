import 'package:flutter/foundation.dart';
import '../models/stock_mutation_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class StockMutationProvider with ChangeNotifier {
  List<StockItemModel> _stockItems = [];
  StockDetailModel? _selectedStockDetail;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Pagination & Filter States
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;
  int _pageSize = 10;
  String _searchQuery = '';
  String? _selectedFilter; // 'total', 'last_update', or null
  String _sortOrder = 'desc'; // 'asc' or 'desc'

  List<StockItemModel> get stockItems => List.unmodifiable(_stockItems);
  StockDetailModel? get selectedStockDetail => _selectedStockDetail;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalItems => _totalItems;
  int get pageSize => _pageSize;
  String get searchQuery => _searchQuery;
  String? get selectedFilter => _selectedFilter;
  String get sortOrder => _sortOrder;
  bool get hasNextPage => _currentPage < _lastPage;
  bool get hasPrevPage => _currentPage > 1;

  StockMutationProvider() {
    fetchStockItems();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    fetchStockItems();
  }

  void setFilter(String? filter) {
    if (filter == 'Semua') {
      _selectedFilter = null;
    } else {
      _selectedFilter = filter;
    }
    _currentPage = 1;
    fetchStockItems();
  }

  void toggleSortOrder() {
    _sortOrder = _sortOrder == 'desc' ? 'asc' : 'desc';
    _currentPage = 1;
    fetchStockItems();
  }

  void setSortOrder(String sort) {
    _sortOrder = sort;
    _currentPage = 1;
    fetchStockItems();
  }

  void setPageSize(int size) {
    _pageSize = size;
    _currentPage = 1;
    fetchStockItems();
  }

  Future<void> nextPage() async {
    if (hasNextPage) {
      await fetchStockItems(page: _currentPage + 1);
    }
  }

  Future<void> prevPage() async {
    if (hasPrevPage) {
      await fetchStockItems(page: _currentPage - 1);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= _lastPage) {
      await fetchStockItems(page: page);
    }
  }

  // 1. GET Stock List ({{url}}stock?page=1&pageSize=10&filter=total&sort=desc&search=...)
  Future<void> fetchStockItems({int page = 1, bool isRefresh = false}) async {
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
      var list = _getMockStockItems();

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        list = list.where((s) {
          return s.name.toLowerCase().contains(q) ||
              s.sku.toLowerCase().contains(q) ||
              (s.longName ?? '').toLowerCase().contains(q);
        }).toList();
      }

      if (_selectedFilter == 'total') {
        list.sort((a, b) => _sortOrder == 'asc' ? a.total.compareTo(b.total) : b.total.compareTo(a.total));
      }

      _stockItems = list;
      _totalItems = list.length;
      _lastPage = 1;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getStockFiltered(
      page: _currentPage,
      pageSize: _pageSize,
      filter: _selectedFilter,
      sort: _sortOrder,
      search: _searchQuery,
    );

    final response = await ApiService.get(url);
    if (response.isSuccess && response.data != null) {
      final dynamic resData = response.data;
      List rawList = [];

      if (resData is Map) {
        final contentMap = (resData['content'] is Map) ? resData['content'] : resData;
        if (contentMap['data'] is List) {
          rawList = contentMap['data'] as List;
        } else if (resData['data'] is List) {
          rawList = resData['data'] as List;
        }

        _currentPage = int.tryParse(contentMap['current_page']?.toString() ?? '$_currentPage') ?? _currentPage;
        _lastPage = int.tryParse(contentMap['last_page']?.toString() ?? '1') ?? 1;
        _totalItems = int.tryParse(contentMap['total']?.toString() ?? '${rawList.length}') ?? rawList.length;
        _pageSize = int.tryParse(contentMap['per_page']?.toString() ?? '$_pageSize') ?? _pageSize;
      } else if (resData is List) {
        rawList = resData;
        _totalItems = rawList.length;
        _lastPage = 1;
      }

      _stockItems = rawList.map((e) => StockItemModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    } else {
      _errorMessage = response.message;
      if (_stockItems.isEmpty) {
        _stockItems = _getMockStockItems();
        _totalItems = _stockItems.length;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. GET Stock Detail ({{url}}stock/:id)
  Future<StockDetailModel?> fetchStockDetail(String stockId) async {
    _isLoadingDetail = true;
    _selectedStockDetail = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final mockItem = _stockItems.firstWhere(
        (s) => s.id == stockId,
        orElse: () => _getMockStockItems().first,
      );

      _selectedStockDetail = StockDetailModel(
        item: mockItem,
        historyDetails: [
          StockDetailHistoryModel(
            id: 7,
            notes: 'Modal Awal Item',
            qtyIn: 14,
            qtyOut: 0,
            qtyHold: 0,
            lastUpdated: '2026-08-15 11:52:48',
          ),
          StockDetailHistoryModel(
            id: 47,
            notes: 'Test Adjustment',
            qtyIn: 2,
            qtyOut: 0,
            qtyHold: 0,
            lastUpdated: '2026-08-20 19:38:47',
          ),
          StockDetailHistoryModel(
            id: 52,
            notes: 'masuk',
            qtyIn: 500,
            qtyOut: 0,
            qtyHold: 0,
            lastUpdated: '2026-08-20 20:09:51',
          ),
          StockDetailHistoryModel(
            id: 53,
            notes: 'keluar',
            qtyIn: 0,
            qtyOut: 16,
            qtyHold: 0,
            lastUpdated: '2026-08-20 20:52:03',
          ),
        ],
        minimum: mockItem.minimum > 0 ? mockItem.minimum : 10,
        total: 500,
        lastUpdated: '2026-08-20 20:52:03',
      );

      _isLoadingDetail = false;
      notifyListeners();
      return _selectedStockDetail;
    }

    final url = ApiEndpoints.getStockDetailUrl(stockId);
    final response = await ApiService.get(url);

    if (response.isSuccess && response.data != null) {
      final dynamic resData = response.data;
      Map<String, dynamic> contentMap = {};

      if (resData is Map) {
        if (resData['content'] is Map) {
          contentMap = Map<String, dynamic>.from(resData['content'] as Map);
        } else {
          contentMap = Map<String, dynamic>.from(resData);
        }
      }

      _selectedStockDetail = StockDetailModel.fromJson(contentMap);
    }

    _isLoadingDetail = false;
    notifyListeners();
    return _selectedStockDetail;
  }

  // 3. POST Stock Adjustment ({{url}}stock/:id/adjustment)
  Future<bool> adjustStock({
    required String stockId,
    required String type, // "in" or "out"
    required int qty,
    required String notes,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final payload = <String, dynamic>{
      'type': type,
      'qty': qty,
      'notes': notes,
    };

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      final idx = _stockItems.indexWhere((s) => s.id == stockId);
      if (idx != -1) {
        final old = _stockItems[idx];
        final newTotal = type == 'in' ? old.total + qty : (old.total - qty).clamp(0, 999999);
        _stockItems[idx] = StockItemModel(
          id: old.id,
          sku: old.sku,
          name: old.name,
          longName: old.longName,
          parentCategoryName: old.parentCategoryName,
          childCategoryName: old.childCategoryName,
          typeName: old.typeName,
          imageUrl: old.imageUrl,
          minimum: old.minimum,
          total: newTotal,
          lastUpdated: DateTime.now().toIso8601String(),
        );
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    }

    final url = ApiEndpoints.getStockAdjustmentUrl(stockId);
    var response = await ApiService.put(url, payload);
    if (!response.isSuccess) {
      response = await ApiService.post(url, payload);
    }

    _isSubmitting = false;
    if (response.isSuccess) {
      await fetchStockItems(page: _currentPage);
      await fetchStockDetail(stockId);
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  List<StockItemModel> _getMockStockItems() {
    return [
      StockItemModel(
        id: '2029c6b2-82f0-477a-afdf-9a14c164d2bb',
        sku: 'CJL90ML',
        name: 'CUP JELLY 90ML',
        longName: 'CUP JELLY PLASTIK 90MM + TUTUP',
        parentCategoryName: 'Food Pack',
        childCategoryName: 'Cup',
        typeName: 'Jelly',
        minimum: 10,
        total: 14,
        lastUpdated: '2026-08-15 11:52:48',
        imageUrl: 'http://poswenapidev.nalentora.cloud/storage/images/default/no-image.png',
      ),
      StockItemModel(
        id: '07050da9-e8f7-4ef3-8ab4-d2b9fc50a6c2',
        sku: 'TSK015H',
        name: 'TAS K015H',
        longName: 'TAS HD HITAM BERINGIN KECIL 1532 HIJAU',
        parentCategoryName: 'Kantong Plastik',
        childCategoryName: 'HD',
        typeName: 'Tas',
        minimum: 100,
        total: 1000,
        lastUpdated: '2026-08-15 11:52:50',
        imageUrl: 'http://poswenapidev.nalentora.cloud/storage/images/default/no-image.png',
      ),
      StockItemModel(
        id: '0819df64-d52e-4762-938f-26af5788c6a5',
        sku: 'SDTMM',
        name: 'SEDOTAN MM',
        longName: 'PIPET PUTIH TEKUK PREMIUM',
        parentCategoryName: 'Sedotan',
        childCategoryName: 'Pipet',
        typeName: 'Tekuk',
        minimum: 10,
        total: 40,
        lastUpdated: '2026-08-15 11:52:48',
        imageUrl: 'http://poswenapidev.nalentora.cloud/storage/images/default/no-image.png',
      ),
    ];
  }
}
