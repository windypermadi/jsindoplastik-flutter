class RiwayatOrderItemModel {
  final String code;
  final String name;
  final String parentCategory;
  final String childCategory;
  final double unitPrice;
  final int qty;
  final String unit;
  final double subtotal;

  RiwayatOrderItemModel({
    required this.code,
    required this.name,
    required this.parentCategory,
    required this.childCategory,
    required this.unitPrice,
    required this.qty,
    this.unit = 'pcs',
    required this.subtotal,
  });

  factory RiwayatOrderItemModel.fromJson(Map<String, dynamic> json) {
    return RiwayatOrderItemModel(
      code: json['code']?.toString() ?? '01',
      name: json['name']?.toString() ?? '',
      parentCategory: json['parent_category']?.toString() ?? '',
      childCategory: json['child_category']?.toString() ?? '',
      unitPrice: (json['unit_price'] ?? json['price'] ?? 0).toDouble(),
      qty: int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      unit: json['unit']?.toString() ?? 'pcs',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}

class RiwayatTransaksiItemModel {
  final String id;
  final String customerName;
  final String customerType;
  final String salesName;
  final String date;
  final double subtotal;
  final double totalDiscount;
  final double totalAmount;
  final String paymentMethod;
  final List<RiwayatOrderItemModel> items;

  RiwayatTransaksiItemModel({
    required this.id,
    required this.customerName,
    required this.customerType,
    required this.salesName,
    required this.date,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.items,
  });

  int get totalProductCount => items.fold(0, (sum, item) => sum + item.qty);

  factory RiwayatTransaksiItemModel.fromJson(Map<String, dynamic> json) {
    List<RiwayatOrderItemModel> orderItems = [];
    if (json['items'] is List) {
      orderItems = (json['items'] as List)
          .map((e) => RiwayatOrderItemModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .toList();
    }

    return RiwayatTransaksiItemModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ?? json['customer'] ?? 'Retail',
      customerType: json['customer_type'] ?? 'Retail',
      salesName: json['sales_name'] ?? json['sales'] ?? 'Sales',
      date: json['date']?.toString() ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalDiscount: (json['total_discount'] ?? json['diskon'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? json['total'] ?? 0).toDouble(),
      paymentMethod: json['payment_method']?.toString() ?? 'Tunai',
      items: orderItems,
    );
  }
}

class RiwayatTransaksiGroupModel {
  final String dateDay;
  final String dateMonthYear;
  final String dayOfWeek;
  final double dailyTotal;
  final List<RiwayatTransaksiItemModel> transactions;

  RiwayatTransaksiGroupModel({
    required this.dateDay,
    required this.dateMonthYear,
    required this.dayOfWeek,
    required this.dailyTotal,
    required this.transactions,
  });

  factory RiwayatTransaksiGroupModel.fromJson(Map<String, dynamic> json) {
    List<RiwayatTransaksiItemModel> txs = [];
    if (json['transactions'] is List) {
      txs = (json['transactions'] as List)
          .map((e) => RiwayatTransaksiItemModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .toList();
    }

    return RiwayatTransaksiGroupModel(
      dateDay: json['date_day']?.toString() ?? '27',
      dateMonthYear: json['date_month_year']?.toString() ?? 'Juni 2024',
      dayOfWeek: json['day_of_week']?.toString() ?? 'Kamis',
      dailyTotal: (json['daily_total'] ?? 0).toDouble(),
      transactions: txs,
    );
  }
}
