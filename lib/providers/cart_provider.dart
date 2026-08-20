import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];
  CustomerModel? _selectedCustomer;
  PaymentMethod _paymentMethod = PaymentMethod.tunai;
  double _discountAmount = 0.0;
  double _paidAmount = 0.0;

  // Cart API States
  String? _activeCartId;
  List<CartSummaryModel> _savedCarts = [];
  CartDetailModel? _activeCartDetail;
  bool _isLoading = false;
  bool _isAddingToCart = false;
  String? _errorMessage;

  // Pagination for Saved Carts
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalCarts = 0;

  List<CartItemModel> get items => List.unmodifiable(_items);
  CustomerModel? get selectedCustomer => _selectedCustomer;
  PaymentMethod get paymentMethod => _paymentMethod;
  double get discountAmount => _discountAmount;
  double get paidAmount => _paidAmount;

  String? get activeCartId => _activeCartId;
  List<CartSummaryModel> get savedCarts => List.unmodifiable(_savedCarts);
  CartDetailModel? get activeCartDetail => _activeCartDetail;
  bool get isLoading => _isLoading;
  bool get isAddingToCart => _isAddingToCart;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalCarts => _totalCarts;

  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal {
    if (_activeCartDetail != null && _activeCartDetail!.totalAfter > 0) {
      return _activeCartDetail!.totalAfter;
    }
    return _items.fold(0.0, (sum, i) => sum + i.subtotal);
  }

  double get totalAmount {
    final net = subtotal - _discountAmount;
    return net < 0 ? 0 : net;
  }

  double get changeAmount {
    if (_paymentMethod == PaymentMethod.kasbon) return 0.0;
    final diff = _paidAmount - totalAmount;
    return diff > 0 ? diff : 0.0;
  }

  CartProvider() {
    fetchCartList();
  }

  void setActiveCartId(String? cartId) {
    _activeCartId = cartId;
    notifyListeners();
    if (cartId != null && cartId.isNotEmpty) {
      fetchCartDetail(cartId);
    }
  }

  // Assign Customer to Cart API ({{url}}cart/:id/customer)
  Future<bool> assignCustomerToCartApi(CustomerModel? customer) async {
    _selectedCustomer = customer;
    notifyListeners();

    if (_activeCartId == null || _activeCartId!.isEmpty || customer == null) {
      return true;
    }

    final isMock = await StorageService.isMockMode();
    if (isMock) return true;

    final url = ApiEndpoints.getCartCustomerUrl(_activeCartId!);
    final payload = <String, dynamic>{
      'cust_id': customer.id,
    };

    try {
      var response = await ApiService.put(url, payload);
      if (!response.isSuccess) {
        response = await ApiService.post(url, payload);
      }
      if (response.isSuccess) {
        await fetchCartDetail(_activeCartId!);
        return true;
      }
    } catch (e) {
      debugPrint('Error assigning customer to cart: $e');
    }
    return false;
  }

  // Remove Cart Discount API ({{url}}cart/:id/discount/remove)
  Future<bool> removeCartDiscountApi() async {
    _discountAmount = 0.0;
    notifyListeners();

    if (_activeCartId == null || _activeCartId!.isEmpty) {
      return true;
    }

    final isMock = await StorageService.isMockMode();
    if (isMock) return true;

    final url = ApiEndpoints.getCartDiscountRemoveUrl(_activeCartId!);
    try {
      final response = await ApiService.post(url, {});
      if (response.isSuccess) {
        await fetchCartDetail(_activeCartId!);
        return true;
      }
    } catch (e) {
      debugPrint('Error removing cart discount API: $e');
    }
    return false;
  }

  // Update Cart Discount API ({{url}}cart/:id/discount)
  Future<bool> updateCartDiscountApi({bool? isPercent, required double value}) async {
    if (isPercent == null || value <= 0) {
      return await removeCartDiscountApi();
    }

    if (isPercent == true) {
      _discountAmount = (subtotal * value) / 100;
    } else {
      _discountAmount = value;
    }
    notifyListeners();

    if (_activeCartId == null || _activeCartId!.isEmpty) {
      return true;
    }

    final isMock = await StorageService.isMockMode();
    if (isMock) return true;

    final url = ApiEndpoints.getCartDiscountUrl(_activeCartId!);
    final payload = <String, dynamic>{
      'is_percent': isPercent,
      'value': value,
    };

    try {
      final response = await ApiService.post(url, payload);
      if (response.isSuccess) {
        await fetchCartDetail(_activeCartId!);
        return true;
      }
    } catch (e) {
      debugPrint('Error updating cart discount API: $e');
    }
    return false;
  }

  // 1. POST Add to Cart ({{url}}cart/add)
  Future<bool> addToCartApi({
    required String itemId,
    int qty = 1,
    String? custId,
    ProductModel? fallbackProduct,
  }) async {
    _isAddingToCart = true;
    _errorMessage = null;
    notifyListeners();

    // Local fallback update for instant UI feedback
    if (fallbackProduct != null) {
      addToCart(fallbackProduct, qty: qty);
    }

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _isAddingToCart = false;
      notifyListeners();
      return true;
    }

    final payload = <String, dynamic>{
      'cart_id': _activeCartId,
      'cust_id': custId ?? _selectedCustomer?.id,
      'item_id': itemId,
      'qty': qty,
    };

    try {
      final response = await ApiService.post(ApiEndpoints.cartAdd, payload);
      _isAddingToCart = false;

      if (response.isSuccess && response.data != null) {
        final dynamic resData = response.data;
        String? returnedCartId;

        if (resData is Map) {
          final content = (resData['content'] is Map) ? resData['content'] : resData;
          returnedCartId = content['cart']?.toString() ??
              content['cart_id']?.toString() ??
              content['id']?.toString() ??
              resData['cart']?.toString() ??
              resData['cart_id']?.toString() ??
              resData['id']?.toString();
        }

        if (returnedCartId != null && returnedCartId.isNotEmpty) {
          _activeCartId = returnedCartId;
        }

        if (_activeCartId != null && _activeCartId!.isNotEmpty) {
          await fetchCartDetail(_activeCartId!);
        }
        await fetchCartList();
        return true;
      } else {
        // Network offline / API failed: local cart item is preserved gracefully
        debugPrint('Cart API offline / fallback: ${response.message}');
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Cart API exception / offline mode: $e');
      _isAddingToCart = false;
      notifyListeners();
      return true;
    }
  }

  // 2. GET List Cart ({{url}}cart?page=1)
  Future<void> fetchCartList({int page = 1}) async {
    _currentPage = page;
    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _savedCarts = [
        CartSummaryModel(
          id: '7124f8a9-37eb-4b7f-a09a-35ee6db80f14',
          userName: 'Mrs. Loma Zieme',
          qty: 1,
          createdAt: '2026-08-19 15:07:24',
        ),
        CartSummaryModel(
          id: '9476cccd-a0cf-4932-ab58-360a720f3e11',
          userName: 'Mrs. Loma Zieme',
          custName: 'Yola',
          custType: 'VIP',
          qty: 1,
          createdAt: '2026-08-18 15:39:14',
        ),
      ];
      _totalCarts = _savedCarts.length;
      _lastPage = 1;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getCartListUrl(page: _currentPage);
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
        _totalCarts = int.tryParse(contentMap['total']?.toString() ?? '${rawList.length}') ?? rawList.length;
      } else if (resData is List) {
        rawList = resData;
        _totalCarts = rawList.length;
        _lastPage = 1;
      }

      _savedCarts = rawList.map((e) => CartSummaryModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    }
    notifyListeners();
  }

  // 3. GET Cart Detail ({{url}}cart/:id)
  Future<CartDetailModel?> fetchCartDetail(String cartId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _isLoading = false;
      notifyListeners();
      return _activeCartDetail;
    }

    final url = ApiEndpoints.getCartDetailUrl(cartId);
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

      _activeCartDetail = CartDetailModel.fromJson(contentMap);
      _activeCartId = _activeCartDetail?.id ?? cartId;

      // Synchronize local items array with active cart detail from backend API
      if (_activeCartDetail != null && _activeCartDetail!.items.isNotEmpty) {
        _items.clear();
        for (final detailItem in _activeCartDetail!.items) {
          _items.add(CartItemModel(
            product: detailItem.toProductModel(),
            quantity: detailItem.qty,
            price: detailItem.price > 0 ? detailItem.price : detailItem.normalPrice,
          ));
        }
      }
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return _activeCartDetail;
  }

  void addToCart(ProductModel product, {int qty = 1}) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx != -1) {
      _items[idx].quantity += qty;
    } else {
      _items.add(CartItemModel(
        product: product,
        quantity: qty,
        price: product.sellPrice,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int newQty) {
    if (newQty <= 0) {
      removeFromCart(productId);
      return;
    }
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx != -1) {
      _items[idx].quantity = newQty;
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void setCustomer(CustomerModel? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setDiscount(double discount) {
    _discountAmount = discount;
    notifyListeners();
  }

  void setPaidAmount(double paid) {
    _paidAmount = paid;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _activeCartId = null;
    _activeCartDetail = null;
    _selectedCustomer = null;
    _paymentMethod = PaymentMethod.tunai;
    _discountAmount = 0.0;
    _paidAmount = 0.0;
    notifyListeners();
  }
}
