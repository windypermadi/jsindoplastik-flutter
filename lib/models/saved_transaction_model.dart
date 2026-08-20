class SavedTransactionCustomerModel {
  final String? id;
  final String name;
  final String type;

  SavedTransactionCustomerModel({
    this.id,
    required this.name,
    required this.type,
  });

  factory SavedTransactionCustomerModel.fromJson(Map<String, dynamic> json) {
    return SavedTransactionCustomerModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Retail',
      type: json['type']?.toString() ?? 'Retail',
    );
  }
}

class SavedTransactionUserModel {
  final String? id;
  final String name;
  final String? image;
  final String type;

  SavedTransactionUserModel({
    this.id,
    required this.name,
    this.image,
    required this.type,
  });

  factory SavedTransactionUserModel.fromJson(Map<String, dynamic> json) {
    return SavedTransactionUserModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Sales',
      image: json['image']?.toString(),
      type: json['type']?.toString() ?? 'Owner',
    );
  }
}

class SavedTransactionDiscModel {
  final bool status;
  final bool? isPercent;
  final String discount;

  SavedTransactionDiscModel({
    required this.status,
    this.isPercent,
    required this.discount,
  });

  factory SavedTransactionDiscModel.fromJson(Map<String, dynamic> json) {
    return SavedTransactionDiscModel(
      status: json['status'] == true,
      isPercent: json['is_percent'] is bool ? json['is_percent'] : null,
      discount: json['discount']?.toString() ?? '0',
    );
  }
}

class SavedTransactionModel {
  final String cartId;
  final SavedTransactionCustomerModel customer;
  final SavedTransactionUserModel user;
  final SavedTransactionDiscModel disc;
  final double subtotal;
  final double total;
  final String date;
  final bool isOpen;

  SavedTransactionModel({
    required this.cartId,
    required this.customer,
    required this.user,
    required this.disc,
    required this.subtotal,
    required this.total,
    required this.date,
    required this.isOpen,
  });

  factory SavedTransactionModel.fromJson(Map<String, dynamic> json) {
    return SavedTransactionModel(
      cartId: json['cart_id']?.toString() ?? '',
      customer: SavedTransactionCustomerModel.fromJson(
        Map<String, dynamic>.from(json['customer'] is Map ? json['customer'] : {}),
      ),
      user: SavedTransactionUserModel.fromJson(
        Map<String, dynamic>.from(json['user'] is Map ? json['user'] : {}),
      ),
      disc: SavedTransactionDiscModel.fromJson(
        Map<String, dynamic>.from(json['disc'] is Map ? json['disc'] : {}),
      ),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      date: json['date']?.toString() ?? '',
      isOpen: json['is_open'] == true,
    );
  }
}

class SavedTransactionDetailItemModel {
  final String id;
  final String name;
  final String? longName;
  final int qty;
  final String? image;
  final double price;
  final double subtotal;
  final String parentCategory;
  final String childCategory;
  final String typeName;

  SavedTransactionDetailItemModel({
    required this.id,
    required this.name,
    this.longName,
    required this.qty,
    this.image,
    required this.price,
    required this.subtotal,
    required this.parentCategory,
    required this.childCategory,
    required this.typeName,
  });

  factory SavedTransactionDetailItemModel.fromJson(Map<String, dynamic> json) {
    String pCat = '';
    String cCat = '';
    if (json['category'] is Map) {
      final catMap = json['category'] as Map;
      if (catMap['parent'] is Map) {
        pCat = catMap['parent']['name']?.toString() ?? '';
      }
      if (catMap['child'] is Map) {
        cCat = catMap['child']['name']?.toString() ?? '';
      }
    }

    String tName = '-';
    if (json['type'] is Map) {
      tName = json['type']['name']?.toString() ?? '-';
    }

    return SavedTransactionDetailItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      longName: json['long_name']?.toString(),
      qty: int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      image: json['image']?.toString(),
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      parentCategory: pCat,
      childCategory: cCat,
      typeName: tName,
    );
  }
}

class SavedTransactionDetailModel {
  final String salesId;
  final String salesName;
  final String? customerId;
  final String customerName;
  final String customerType;
  final String date;
  final List<SavedTransactionDetailItemModel> items;
  final bool discStatus;
  final bool? discIsPercent;
  final String discount;
  final double beforeDisc;
  final double afterDisc;

  SavedTransactionDetailModel({
    required this.salesId,
    required this.salesName,
    this.customerId,
    required this.customerName,
    required this.customerType,
    required this.date,
    required this.items,
    required this.discStatus,
    this.discIsPercent,
    required this.discount,
    required this.beforeDisc,
    required this.afterDisc,
  });

  factory SavedTransactionDetailModel.fromJson(Map<String, dynamic> json) {
    String sId = '';
    String sName = 'Sales';
    if (json['sales'] is Map) {
      sId = json['sales']['id']?.toString() ?? '';
      sName = json['sales']['name']?.toString() ?? 'Sales';
    }

    String? cId;
    String cName = 'Retail';
    String cType = 'Retail';
    if (json['customer'] is Map) {
      cId = json['customer']['id']?.toString();
      cName = json['customer']['name']?.toString() ?? 'Retail';
      cType = json['customer']['type']?.toString() ?? 'Retail';
    }

    List<SavedTransactionDetailItemModel> itemList = [];
    if (json['items'] is List) {
      itemList = (json['items'] as List)
          .map((e) => SavedTransactionDetailItemModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .toList();
    }

    bool dStatus = false;
    bool? dIsPercent;
    String dVal = '0';
    if (json['disc'] is Map) {
      dStatus = json['disc']['status'] == true;
      dIsPercent = json['disc']['is_percent'] is bool ? json['disc']['is_percent'] : null;
      dVal = json['disc']['discount']?.toString() ?? '0';
    }

    double bDisc = 0.0;
    double aDisc = 0.0;
    if (json['total'] is Map) {
      bDisc = (json['total']['before_disc'] ?? 0).toDouble();
      aDisc = (json['total']['after_disc'] ?? 0).toDouble();
    }

    return SavedTransactionDetailModel(
      salesId: sId,
      salesName: sName,
      customerId: cId,
      customerName: cName,
      customerType: cType,
      date: json['date']?.toString() ?? '',
      items: itemList,
      discStatus: dStatus,
      discIsPercent: dIsPercent,
      discount: dVal,
      beforeDisc: bDisc,
      afterDisc: aDisc,
    );
  }
}
