import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<OrderModel> get orders {
    if (_searchQuery.isEmpty) return _orders;
    return _orders.where((o) {
      return o.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  OrderProvider() {
    fetchOrders();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _orders = _getMockOrders();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.orders);
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List ? response.data : (response.data['orders'] ?? []);
      _orders = list.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      _orders = _getMockOrders();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder(OrderModel order) async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    final response = await ApiService.post(ApiEndpoints.checkout, order.toJson());
    if (response.isSuccess) {
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        id: 'ORD-101',
        orderNumber: 'INV-20260816-001',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        customerName: 'Toko Berkah Plastik',
        items: [],
        totalAmount: 320000,
        paidAmount: 350000,
        changeAmount: 30000,
        paymentMethod: PaymentMethod.tunai,
        cashierName: 'Rudi (Sales)',
      ),
      OrderModel(
        id: 'ORD-102',
        orderNumber: 'INV-20260816-002',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        customerName: 'Depot Es Boba & Juice',
        items: [],
        totalAmount: 185000,
        paidAmount: 185000,
        changeAmount: 0,
        paymentMethod: PaymentMethod.qris,
        cashierName: 'Rudi (Sales)',
      ),
      OrderModel(
        id: 'ORD-103',
        orderNumber: 'INV-20260815-003',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        customerName: 'Pelanggan Umum',
        items: [],
        totalAmount: 75000,
        paidAmount: 100000,
        changeAmount: 25000,
        paymentMethod: PaymentMethod.tunai,
        cashierName: 'Bpk. Hendra (Owner)',
      ),
    ];
  }
}
