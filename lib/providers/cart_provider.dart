import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];
  CustomerModel? _selectedCustomer;
  PaymentMethod _paymentMethod = PaymentMethod.tunai;
  double _discountAmount = 0.0;
  double _paidAmount = 0.0;

  List<CartItemModel> get items => List.unmodifiable(_items);
  CustomerModel? get selectedCustomer => _selectedCustomer;
  PaymentMethod get paymentMethod => _paymentMethod;
  double get discountAmount => _discountAmount;
  double get paidAmount => _paidAmount;

  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.subtotal);

  double get totalAmount {
    final net = subtotal - _discountAmount;
    return net < 0 ? 0 : net;
  }

  double get changeAmount {
    if (_paymentMethod == PaymentMethod.kasbon) return 0.0;
    final diff = _paidAmount - totalAmount;
    return diff > 0 ? diff : 0.0;
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
    _selectedCustomer = null;
    _paymentMethod = PaymentMethod.tunai;
    _discountAmount = 0.0;
    _paidAmount = 0.0;
    notifyListeners();
  }
}
