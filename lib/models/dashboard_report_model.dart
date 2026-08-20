class DashboardTransactionGroupModel {
  final int items;
  final double total;

  DashboardTransactionGroupModel({
    this.items = 0,
    this.total = 0.0,
  });

  factory DashboardTransactionGroupModel.fromJson(Map<String, dynamic> json) {
    return DashboardTransactionGroupModel(
      items: _parseInt(json['items']),
      total: _parseDouble(json['total']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}

class DashboardTransactionSummaryModel {
  final DashboardTransactionGroupModel inGroup;
  final DashboardTransactionGroupModel savedGroup;
  final double nett;

  DashboardTransactionSummaryModel({
    required this.inGroup,
    required this.savedGroup,
    this.nett = 0.0,
  });

  factory DashboardTransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    final inMap = (json['in'] is Map) ? json['in'] as Map<String, dynamic> : <String, dynamic>{};
    final savedMap = (json['saved'] is Map) ? json['saved'] as Map<String, dynamic> : <String, dynamic>{};

    return DashboardTransactionSummaryModel(
      inGroup: DashboardTransactionGroupModel.fromJson(inMap),
      savedGroup: DashboardTransactionGroupModel.fromJson(savedMap),
      nett: _parseDouble(json['nett']),
    );
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}

class DashboardStockItemModel {
  final String id;
  final String name;
  final String? longName;
  final String? image;
  final String unit;
  final String? parentCategory;
  final String? childCategory;
  final String type;
  final int qty;

  DashboardStockItemModel({
    required this.id,
    required this.name,
    this.longName,
    this.image,
    this.unit = 'Pcs',
    this.parentCategory,
    this.childCategory,
    this.type = '-',
    this.qty = 0,
  });

  factory DashboardStockItemModel.fromJson(Map<String, dynamic> json) {
    String iName = '';
    String? iLongName;
    String? iImage;
    String iUnit = 'Pcs';

    if (json['item'] is Map) {
      final iMap = json['item'] as Map;
      iName = iMap['name']?.toString() ?? '';
      iLongName = iMap['long_name']?.toString();
      iImage = iMap['image']?.toString();
      iUnit = iMap['unit']?.toString() ?? 'Pcs';
    } else {
      iName = json['name']?.toString() ?? 'Item';
    }

    String? parentCat;
    String? childCat;
    if (json['category'] is Map) {
      final cMap = json['category'] as Map;
      parentCat = cMap['parent']?.toString();
      childCat = cMap['child']?.toString();
    } else if (json['category'] != null) {
      parentCat = json['category'].toString();
    }

    return DashboardStockItemModel(
      id: json['id']?.toString() ?? '',
      name: iName,
      longName: iLongName,
      image: iImage,
      unit: iUnit,
      parentCategory: parentCat,
      childCategory: childCat,
      type: json['type']?.toString() ?? '-',
      qty: _parseInt(json['qty']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}

class DashboardReportModel {
  final DashboardTransactionSummaryModel transaction;
  final List<DashboardStockItemModel> stock;

  DashboardReportModel({
    required this.transaction,
    required this.stock,
  });

  factory DashboardReportModel.fromJson(Map<String, dynamic> json) {
    final txMap = (json['transaction'] is Map) ? json['transaction'] as Map<String, dynamic> : <String, dynamic>{};
    List<DashboardStockItemModel> stockList = [];

    if (json['stock'] is List) {
      final list = json['stock'] as List;
      stockList = list.map((e) => DashboardStockItemModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    }

    return DashboardReportModel(
      transaction: DashboardTransactionSummaryModel.fromJson(txMap),
      stock: stockList,
    );
  }
}

class DashboardOrderInModel {
  final String invoice;
  final String customerName;
  final String customerType;
  final String salesName;
  final String transactionType;
  final String transactionDate;
  final double total;

  DashboardOrderInModel({
    required this.invoice,
    this.customerName = 'Retail',
    this.customerType = 'Retail',
    this.salesName = 'Sales',
    this.transactionType = 'Tunai',
    this.transactionDate = '',
    this.total = 0.0,
  });

  factory DashboardOrderInModel.fromJson(Map<String, dynamic> json) {
    String custName = 'Retail';
    String custType = 'Retail';
    if (json['customer'] is Map) {
      final cMap = json['customer'] as Map;
      custName = cMap['name']?.toString() ?? 'Retail';
      custType = cMap['type']?.toString() ?? 'Retail';
    }

    String sName = 'Sales';
    if (json['sales'] is Map) {
      sName = json['sales']['name']?.toString() ?? 'Sales';
    }

    String txType = 'Tunai';
    String txDate = '';
    double txTotal = 0.0;
    if (json['transaction'] is Map) {
      final tMap = json['transaction'] as Map;
      txType = tMap['type']?.toString() ?? 'Tunai';
      txDate = tMap['date']?.toString() ?? '';
      txTotal = double.tryParse(tMap['total']?.toString() ?? '0') ?? 0.0;
    }

    return DashboardOrderInModel(
      invoice: json['invoice']?.toString() ?? '',
      customerName: custName,
      customerType: custType,
      salesName: sName,
      transactionType: txType,
      transactionDate: txDate,
      total: txTotal,
    );
  }
}

class DashboardOrderSavedModel {
  final String cartId;
  final String customerName;
  final String customerType;
  final String salesName;
  final String date;
  final double totalTransaction;

  DashboardOrderSavedModel({
    required this.cartId,
    this.customerName = 'Retail',
    this.customerType = 'Retail',
    this.salesName = 'Sales',
    this.date = '',
    this.totalTransaction = 0.0,
  });

  factory DashboardOrderSavedModel.fromJson(Map<String, dynamic> json) {
    String custName = 'Retail';
    String custType = 'Retail';
    if (json['customer'] is Map) {
      final cMap = json['customer'] as Map;
      custName = cMap['name']?.toString() ?? 'Retail';
      custType = cMap['type']?.toString() ?? 'Retail';
    }

    String sName = 'Sales';
    if (json['sales'] is Map) {
      sName = json['sales']['name']?.toString() ?? 'Sales';
    }

    return DashboardOrderSavedModel(
      cartId: json['cart']?.toString() ?? json['id']?.toString() ?? '',
      customerName: custName,
      customerType: custType,
      salesName: sName,
      date: json['date']?.toString() ?? '',
      totalTransaction: double.tryParse(json['total_transaction']?.toString() ?? json['total']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DashboardOrderDetailItemModel {
  final String name;
  final String? longName;
  final String? parentCategory;
  final String? childCategory;
  final String type;
  final double price;
  final int qty;
  final double subtotal;

  DashboardOrderDetailItemModel({
    required this.name,
    this.longName,
    this.parentCategory,
    this.childCategory,
    this.type = '-',
    this.price = 0.0,
    this.qty = 1,
    this.subtotal = 0.0,
  });

  factory DashboardOrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    String? pCat;
    String? cCat;
    if (json['category'] is Map) {
      final cMap = json['category'] as Map;
      pCat = cMap['parent']?.toString();
      cCat = cMap['child']?.toString();
    }

    return DashboardOrderDetailItemModel(
      name: json['name']?.toString() ?? 'Item',
      longName: json['long_name']?.toString(),
      parentCategory: pCat,
      childCategory: cCat,
      type: json['type']?.toString() ?? '-',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      qty: int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DashboardOrderDetailModel {
  final String idOrInvoice;
  final String customerName;
  final String customerType;
  final String salesName;
  final int totalItems;
  final List<DashboardOrderDetailItemModel> items;
  final bool? isPercentDiscount;
  final double discountValue;
  final double subtotal;
  final double total;

  DashboardOrderDetailModel({
    required this.idOrInvoice,
    this.customerName = 'Retail',
    this.customerType = 'Retail',
    this.salesName = 'Sales',
    this.totalItems = 0,
    this.items = const [],
    this.isPercentDiscount,
    this.discountValue = 0.0,
    this.subtotal = 0.0,
    this.total = 0.0,
  });

  factory DashboardOrderDetailModel.fromJson(Map<String, dynamic> json) {
    String custName = 'Retail';
    String custType = 'Retail';
    if (json['customer'] is Map) {
      final cMap = json['customer'] as Map;
      custName = cMap['name']?.toString() ?? 'Retail';
      custType = cMap['type']?.toString() ?? 'Retail';
    }

    String sName = 'Sales';
    if (json['sales'] is Map) {
      sName = json['sales']['name']?.toString() ?? 'Sales';
    }

    int tItems = 0;
    List<DashboardOrderDetailItemModel> itemList = [];

    if (json['items'] is Map) {
      final iMap = json['items'] as Map;
      tItems = int.tryParse(iMap['total']?.toString() ?? '0') ?? 0;

      final dynamic detailListRaw = iMap['detail'] ?? iMap['details'];
      if (detailListRaw is List) {
        itemList = detailListRaw.map((e) => DashboardOrderDetailItemModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
      }
    }

    bool? isPercent;
    double dVal = 0.0;
    if (json['discount'] is Map) {
      final dMap = json['discount'] as Map;
      final rawIsP = dMap['is_percent'] ?? dMap['is_pecent'];
      if (rawIsP != null) {
        isPercent = (rawIsP == true || rawIsP.toString() == '1' || rawIsP.toString() == 'true');
      }
      dVal = double.tryParse(dMap['value']?.toString() ?? '0') ?? 0.0;
    }

    final sub = double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0;
    final tot = double.tryParse(json['total']?.toString() ?? '0') ?? 0.0;

    return DashboardOrderDetailModel(
      idOrInvoice: json['invoice']?.toString() ?? json['id']?.toString() ?? '',
      customerName: custName,
      customerType: custType,
      salesName: sName,
      totalItems: tItems > 0 ? tItems : itemList.length,
      items: itemList,
      isPercentDiscount: isPercent,
      discountValue: dVal,
      subtotal: sub,
      total: tot,
    );
  }

  double get calculatedDiscountAmount {
    if (subtotal > 0 && total > 0 && subtotal > total) {
      return subtotal - total;
    }
    if (isPercentDiscount == true && discountValue > 0) {
      return subtotal * (discountValue / 100);
    }
    return discountValue;
  }
}
