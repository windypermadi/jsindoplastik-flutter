import 'product_model.dart';

class CartSummaryModel {
  final String id;
  final String? userName;
  final String? custName;
  final String? custType;
  final int qty;
  final String? createdAt;

  CartSummaryModel({
    required this.id,
    this.userName,
    this.custName,
    this.custType,
    this.qty = 0,
    this.createdAt,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      id: json['id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? json['user']?['name']?.toString(),
      custName: json['cust_name']?.toString() ?? json['cust']?['name']?.toString(),
      custType: json['cust_type']?.toString() ?? json['cust']?['type']?.toString(),
      qty: _parseInt(json['qty']),
      createdAt: json['created_at']?.toString(),
    );
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }
}

class CartDetailItemModel {
  final dynamic detailId;
  final String itemId;
  final String name;
  final String? longName;
  final int stock;
  final String unit;
  final int qty;
  final double normalPrice;
  final double price;
  final double subtotal;
  final String? image;

  CartDetailItemModel({
    required this.detailId,
    required this.itemId,
    required this.name,
    this.longName,
    this.stock = 0,
    this.unit = 'Pcs',
    this.qty = 1,
    this.normalPrice = 0.0,
    this.price = 0.0,
    this.subtotal = 0.0,
    this.image,
  });

  factory CartDetailItemModel.fromJson(Map<String, dynamic> json) {
    final itemMap = (json['item'] is Map) ? json['item'] as Map : json;

    return CartDetailItemModel(
      detailId: json['id'],
      itemId: itemMap['id']?.toString() ?? '',
      name: itemMap['name']?.toString() ?? itemMap['nama']?.toString() ?? 'Item',
      longName: itemMap['long_name']?.toString(),
      stock: _parseInt(itemMap['stock']),
      unit: itemMap['unit']?.toString() ?? 'Pcs',
      qty: _parseInt(itemMap['qty'] ?? json['qty'] ?? 1),
      normalPrice: _parseDouble(itemMap['normal_price'] ?? itemMap['price'] ?? json['normal_price']),
      price: _parseDouble(itemMap['price'] ?? itemMap['normal_price'] ?? json['price']),
      subtotal: _parseDouble(itemMap['subtotal'] ?? json['subtotal']),
      image: itemMap['image']?.toString() ?? itemMap['image_url']?.toString(),
    );
  }

  ProductModel toProductModel() {
    return ProductModel(
      id: itemId,
      code: itemId.length > 8 ? itemId.substring(0, 8).toUpperCase() : 'SKU',
      name: name,
      longName: longName,
      category: 'Umum',
      buyPrice: normalPrice,
      sellPrice: price,
      stock: stock,
      unit: unit,
      imageUrl: image,
    );
  }

  static double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }
}

class CartDetailModel {
  final String id;
  final String? userId;
  final String? userName;
  final String? custName;
  final String? custType;
  final List<CartDetailItemModel> items;
  final double discountValue;
  final double totalBefore;
  final double totalAfter;
  final String? createdAt;

  CartDetailModel({
    required this.id,
    this.userId,
    this.userName,
    this.custName,
    this.custType,
    required this.items,
    this.discountValue = 0.0,
    this.totalBefore = 0.0,
    this.totalAfter = 0.0,
    this.createdAt,
  });

  factory CartDetailModel.fromJson(Map<String, dynamic> json) {
    String? uId;
    String? uName;
    if (json['user'] is Map) {
      final uMap = json['user'] as Map;
      uId = uMap['id']?.toString();
      uName = uMap['name']?.toString();
    }

    String? cName;
    String? cType;
    if (json['cust'] is Map) {
      final cMap = json['cust'] as Map;
      cName = cMap['name']?.toString();
      cType = cMap['type']?.toString();
    }

    List<CartDetailItemModel> itemList = [];
    if (json['detail'] is List) {
      final list = json['detail'] as List;
      itemList = list.map((e) => CartDetailItemModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    }

    double discVal = 0.0;
    if (json['discount'] is Map) {
      discVal = _parseDouble(json['discount']['value']);
    }

    double totBefore = 0.0;
    double totAfter = 0.0;
    if (json['total'] is Map) {
      totBefore = _parseDouble(json['total']['before']);
      totAfter = _parseDouble(json['total']['after']);
    } else if (json['total'] != null) {
      totAfter = _parseDouble(json['total']);
    }

    return CartDetailModel(
      id: json['id']?.toString() ?? '',
      userId: uId,
      userName: uName,
      custName: cName,
      custType: cType,
      items: itemList,
      discountValue: discVal,
      totalBefore: totBefore,
      totalAfter: totAfter,
      createdAt: json['created_at']?.toString(),
    );
  }

  static double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }
}

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
