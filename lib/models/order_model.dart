import 'cart_item_model.dart';
import 'product_model.dart';


enum PaymentMethod {
  tunai,
  qris,
  transfer,
  kasbon,
}

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.tunai:
        return 'Tunai';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.transfer:
        return 'Transfer Bank';
      case PaymentMethod.kasbon:
        return 'Kasbon / Hutang';
    }
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final String? customerId;
  final String customerName;
  final List<CartItemModel> items;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final PaymentMethod paymentMethod;
  final String cashierName;
  final String status; // Selesai, Pending, Batal

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.paidAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.cashierName,
    this.status = 'Selesai',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final methodStr = (json['payment_method'] ?? 'tunai').toString().toLowerCase();
    PaymentMethod method = PaymentMethod.tunai;
    if (methodStr.contains('qris')) method = PaymentMethod.qris;
    if (methodStr.contains('transfer')) method = PaymentMethod.transfer;
    if (methodStr.contains('kasbon')) method = PaymentMethod.kasbon;

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? json['no_transaksi'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      customerId: json['customer_id']?.toString(),
      customerName: json['customer_name'] ?? json['pelanggan'] ?? 'Pelanggan Umum',
      items: (json['items'] as List<dynamic>?)?.map((i) {
        return CartItemModel(
          product: ProductModel.fromJson(i['product'] ?? i),
          quantity: i['quantity'] ?? i['jumlah'] ?? 1,
          price: (i['price'] ?? i['harga'] ?? 0).toDouble(),
        );
      }).toList() ?? [],
      totalAmount: (json['total_amount'] ?? json['total_harga'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? json['bayar'] ?? 0).toDouble(),
      changeAmount: (json['change_amount'] ?? json['kembali'] ?? 0).toDouble(),
      paymentMethod: method,
      cashierName: json['cashier_name'] ?? json['kasir'] ?? 'Sales',
      status: json['status'] ?? 'Selesai',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
      'customer_id': customerId,
      'customer_name': customerName,
      'items': items.map((i) => i.toJson()).toList(),
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'change_amount': changeAmount,
      'payment_method': paymentMethod.name,
      'cashier_name': cashierName,
      'status': status,
    };
  }
}
