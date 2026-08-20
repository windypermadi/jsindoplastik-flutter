enum MutationType {
  inbound, // Masuk ("in")
  outbound, // Keluar ("out")
}

extension MutationTypeExtension on MutationType {
  String get label {
    switch (this) {
      case MutationType.inbound:
        return 'Stok Masuk (In)';
      case MutationType.outbound:
        return 'Stok Keluar (Out)';
    }
  }

  String get apiValue {
    switch (this) {
      case MutationType.inbound:
        return 'in';
      case MutationType.outbound:
        return 'out';
    }
  }
}

class StockItemModel {
  final String id;
  final String sku;
  final String name;
  final String? longName;
  final String? parentCategoryName;
  final String? childCategoryName;
  final String? typeName;
  final String? imageUrl;
  final int minimum;
  final int total;
  final String? lastUpdated;

  StockItemModel({
    required this.id,
    required this.sku,
    required this.name,
    this.longName,
    this.parentCategoryName,
    this.childCategoryName,
    this.typeName,
    this.imageUrl,
    this.minimum = 0,
    this.total = 0,
    this.lastUpdated,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    final itemMap = (json['item'] is Map) ? json['item'] as Map : json;

    String? pCat;
    String? cCat;
    if (itemMap['category'] is Map) {
      final catMap = itemMap['category'] as Map;
      if (catMap['parent'] is Map) {
        pCat = catMap['parent']['name']?.toString();
      } else if (catMap['parent'] != null) {
        pCat = catMap['parent'].toString();
      }

      if (catMap['child'] is Map) {
        cCat = catMap['child']['name']?.toString();
      } else if (catMap['child'] != null) {
        cCat = catMap['child'].toString();
      }
    } else if (itemMap['category'] != null) {
      pCat = itemMap['category'].toString();
    }

    String? tName;
    if (itemMap['type'] is Map) {
      tName = itemMap['type']['name']?.toString();
    } else if (itemMap['type'] != null) {
      tName = itemMap['type'].toString();
    }

    return StockItemModel(
      id: json['id']?.toString() ?? itemMap['id']?.toString() ?? '',
      sku: itemMap['sku']?.toString() ?? itemMap['code']?.toString() ?? 'SKU',
      name: itemMap['name']?.toString() ?? itemMap['nama']?.toString() ?? 'Produk',
      longName: itemMap['long_name']?.toString(),
      parentCategoryName: pCat,
      childCategoryName: cCat,
      typeName: tName,
      imageUrl: itemMap['image']?.toString() ?? itemMap['image_url']?.toString(),
      minimum: _parseInt(json['minimum'] ?? itemMap['minimum']),
      total: _parseInt(json['total'] ?? itemMap['total']),
      lastUpdated: json['last_updated']?.toString() ?? itemMap['last_updated']?.toString(),
    );
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }
}

class StockDetailHistoryModel {
  final dynamic id;
  final String notes;
  final int qtyIn;
  final int qtyOut;
  final int qtyHold;
  final String? lastUpdated;

  StockDetailHistoryModel({
    required this.id,
    required this.notes,
    required this.qtyIn,
    required this.qtyOut,
    required this.qtyHold,
    this.lastUpdated,
  });

  factory StockDetailHistoryModel.fromJson(Map<String, dynamic> json) {
    return StockDetailHistoryModel(
      id: json['id'],
      notes: json['notes']?.toString() ?? '-',
      qtyIn: _parseInt(json['in']),
      qtyOut: _parseInt(json['out']),
      qtyHold: _parseInt(json['hold']),
      lastUpdated: json['last_updated']?.toString(),
    );
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }
}

class StockDetailModel {
  final StockItemModel item;
  final List<StockDetailHistoryModel> historyDetails;
  final int minimum;
  final int total;
  final String? lastUpdated;

  StockDetailModel({
    required this.item,
    required this.historyDetails,
    required this.minimum,
    required this.total,
    this.lastUpdated,
  });

  factory StockDetailModel.fromJson(Map<String, dynamic> json) {
    final itemObj = StockItemModel.fromJson(json);
    List<StockDetailHistoryModel> details = [];

    if (json['details'] is Map && json['details']['data'] is List) {
      final list = json['details']['data'] as List;
      details = list.map((e) => StockDetailHistoryModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    } else if (json['details'] is List) {
      final list = json['details'] as List;
      details = list.map((e) => StockDetailHistoryModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    } else if (json['data'] is List) {
      final list = json['data'] as List;
      details = list.map((e) => StockDetailHistoryModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    }

    return StockDetailModel(
      item: itemObj,
      historyDetails: details,
      minimum: StockItemModel._parseInt(json['minimum'] ?? (json['item'] is Map ? json['item']['minimum'] : null)),
      total: StockItemModel._parseInt(json['total'] ?? (json['item'] is Map ? json['item']['total'] : null)),
      lastUpdated: json['last_updated']?.toString() ?? (json['item'] is Map ? json['item']['last_updated']?.toString() : null),
    );
  }
}

// Legacy StockMutationModel maintained for backwards compatibility if needed
class StockMutationModel {
  final String id;
  final String productId;
  final String productName;
  final MutationType type;
  final int quantity;
  final String unit;
  final String notes;
  final DateTime date;
  final String userName;

  StockMutationModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.notes,
    required this.date,
    required this.userName,
  });

  factory StockMutationModel.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? 'inbound').toString().toLowerCase();
    return StockMutationModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? json['nama_produk'] ?? '',
      type: typeStr.contains('out') || typeStr.contains('keluar')
          ? MutationType.outbound
          : MutationType.inbound,
      quantity: (json['quantity'] ?? json['jumlah'] ?? 0).toInt(),
      unit: json['unit'] ?? json['satuan'] ?? 'pcs',
      notes: json['notes'] ?? json['keterangan'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now() : DateTime.now(),
      userName: json['user_name'] ?? json['petugas'] ?? 'Admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'type': type == MutationType.inbound ? 'in' : 'out',
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'date': date.toIso8601String(),
      'user_name': userName,
    };
  }
}
