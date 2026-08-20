import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/saved_transaction_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  List<SavedTransactionModel> _savedTransactions = [];

  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _lastPage = 1;
  int _totalSaved = 0;

  List<OrderModel> get orders {
    if (_searchQuery.isEmpty) return _orders;
    return _orders.where((o) {
      return o.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<SavedTransactionModel> get savedTransactions {
    if (_searchQuery.isEmpty) return _savedTransactions;
    return _savedTransactions.where((t) {
      final q = _searchQuery.toLowerCase();
      return t.cartId.toLowerCase().contains(q) ||
          t.customer.name.toLowerCase().contains(q) ||
          t.user.name.toLowerCase().contains(q);
    }).toList();
  }

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalSaved => _totalSaved;

  OrderProvider() {
    fetchSavedTransactions();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchSavedTransactions({int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _savedTransactions = _getMockSavedTransactions();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getTransactionSavedUrl(page: page);
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

      final List dataList = contentMap['data'] as List? ?? [];
      _currentPage = contentMap['current_page'] ?? 1;
      _lastPage = contentMap['last_page'] ?? 1;
      _totalSaved = contentMap['total'] ?? dataList.length;

      _savedTransactions = dataList
          .map((e) => SavedTransactionModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .toList();
    } else {
      _errorMessage = response.message;
      _savedTransactions = _getMockSavedTransactions();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<SavedTransactionDetailModel?> fetchSavedTransactionDetail(String cartId) async {
    final isMock = await StorageService.isMockMode();
    if (isMock) {
      return SavedTransactionDetailModel(
        salesId: 'e56a74fe',
        salesName: 'Mrs. Loma Zieme',
        customerName: 'Retail',
        customerType: 'Retail',
        date: '2026-08-20 22:23:43',
        items: [
          SavedTransactionDetailItemModel(
            id: '0819df64',
            name: 'SEDOTAN MM',
            longName: 'PIPET PUTIH TEKUK PREMIUM',
            qty: 1,
            price: 18000,
            subtotal: 18000,
            parentCategory: 'Alat Makan',
            childCategory: 'Pipet',
            typeName: '-',
          ),
        ],
        discStatus: false,
        discount: '0',
        beforeDisc: 18000,
        afterDisc: 18000,
      );
    }

    final url = ApiEndpoints.getTransactionSavedDetailUrl(cartId);
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

      return SavedTransactionDetailModel.fromJson(contentMap);
    }
    return null;
  }

  Future<void> fetchOrders() async {
    fetchSavedTransactions();
  }

  Future<ApiResponse> processCheckoutApi({
    required String cartId,
    required String transactionType,
    required String paymentType,
    String? acquirer,
    String? notes,
    String? dueDate,
    double? downPayment,
    required double paymentAmount,
  }) async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      _isLoading = false;
      notifyListeners();
      return ApiResponse(isSuccess: true, message: 'Checkout mock berhasil', data: {'message': 'Checkout mock berhasil'});
    }

    final payload = <String, dynamic>{
      'cart_id': cartId,
      'transaction_type': transactionType,
      'payment_type': paymentType,
      'acquirer': acquirer,
      'notes': notes,
      'due_date': dueDate,
      'down_payment': downPayment,
      'payment_amount': paymentAmount,
    };

    final response = await ApiService.post(ApiEndpoints.checkout, payload);
    _isLoading = false;
    notifyListeners();
    return response;
  }

  List<SavedTransactionModel> _getMockSavedTransactions() {
    return [
      SavedTransactionModel(
        cartId: 'b2055319-2b0b-4576-8f6d-371dbb67f436',
        customer: SavedTransactionCustomerModel(id: null, name: 'Retail', type: 'Retail'),
        user: SavedTransactionUserModel(id: 'e56a74fe', name: 'Mrs. Loma Zieme', type: 'Owner'),
        disc: SavedTransactionDiscModel(status: false, isPercent: null, discount: '0'),
        subtotal: 18000,
        total: 18000,
        date: '2026-08-20 22:23:43',
        isOpen: false,
      ),
      SavedTransactionModel(
        cartId: 'afbd4921-663e-4c0b-87a9-758211c2528e',
        customer: SavedTransactionCustomerModel(id: null, name: 'Retail', type: 'Retail'),
        user: SavedTransactionUserModel(id: 'e56a74fe', name: 'Mrs. Loma Zieme', type: 'Owner'),
        disc: SavedTransactionDiscModel(status: false, isPercent: null, discount: '0'),
        subtotal: 3000,
        total: 3000,
        date: '2026-08-20 22:19:51',
        isOpen: false,
      ),
      SavedTransactionModel(
        cartId: 'd895f197-6ece-4d42-b96e-b27321ef8fe6',
        customer: SavedTransactionCustomerModel(id: '967c6c87', name: 'Umi', type: 'Retail'),
        user: SavedTransactionUserModel(id: 'e56a74fe', name: 'Mrs. Loma Zieme', type: 'Owner'),
        disc: SavedTransactionDiscModel(status: false, isPercent: null, discount: '0'),
        subtotal: 18000,
        total: 18000,
        date: '2026-08-20 09:54:28',
        isOpen: false,
      ),
      SavedTransactionModel(
        cartId: '9476cccd-a0cf-4932-ab58-360a720f3e11',
        customer: SavedTransactionCustomerModel(id: 'c4cd8fe6', name: 'Yolanda', type: 'VIP'),
        user: SavedTransactionUserModel(id: 'e56a74fe', name: 'Mrs. Loma Zieme', type: 'Owner'),
        disc: SavedTransactionDiscModel(status: true, isPercent: false, discount: '5000'),
        subtotal: 160000,
        total: 155000,
        date: '2026-08-18 15:39:14',
        isOpen: false,
      ),
    ];
  }
}
