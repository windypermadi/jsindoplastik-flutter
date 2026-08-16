import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  double price;
  String? note;

  CartItemModel({
    required this.product,
    required this.quantity,
    required this.price,
    this.note,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'note': note,
    };
  }
}
