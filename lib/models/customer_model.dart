class CustomerModel {
  final String id;
  final String? salesId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? alamatMaps;
  final String? namaToko;
  final int tipeCustomer;
  final double debtBalance;
  final String? salesName;
  final String? typeName;

  CustomerModel({
    required this.id,
    this.salesId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.alamatMaps,
    this.namaToko,
    this.tipeCustomer = 3,
    this.debtBalance = 0.0,
    this.salesName,
    this.typeName,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    String addrStr = '';
    if (json['address'] is Map) {
      addrStr = json['address']['label']?.toString() ?? json['address']['link']?.toString() ?? '';
    } else if (json['address'] != null) {
      addrStr = json['address'].toString();
    } else if (json['alamat'] != null) {
      addrStr = json['alamat'].toString();
    }

    int typeId = 3;
    String? tName;
    if (json['type'] is Map) {
      final tMap = json['type'] as Map;
      typeId = int.tryParse(tMap['id']?.toString() ?? '3') ?? 3;
      tName = tMap['name']?.toString();
    } else if (json['tipe_customer'] != null) {
      typeId = int.tryParse(json['tipe_customer'].toString()) ?? 3;
    }

    tName ??= (typeId == 1 ? 'VIP' : typeId == 2 ? 'Grosir' : 'Retail');

    return CustomerModel(
      id: json['id']?.toString() ?? '',
      salesId: json['sales_id']?.toString() ?? json['sales']?['id']?.toString(),
      name: json['nama']?.toString() ?? json['name']?.toString() ?? '',
      phone: json['nomor_telpon']?.toString() ?? json['phone']?.toString() ?? json['nomor_telepon']?.toString() ?? '',
      email: json['email']?.toString(),
      address: addrStr,
      alamatMaps: json['alamat_maps']?.toString(),
      namaToko: json['shop_name']?.toString() ?? json['nama_toko']?.toString(),
      tipeCustomer: typeId,
      debtBalance: double.tryParse(json['debt_balance']?.toString() ?? json['total_kasbon']?.toString() ?? '0') ?? 0.0,
      salesName: json['sales_name']?.toString() ?? json['sales']?['name']?.toString(),
      typeName: tName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sales_id': salesId,
      'nama': name,
      'nomor_telpon': int.tryParse(phone) ?? phone,
      'email': email,
      'alamat': address,
      'alamat_maps': alamatMaps,
      'nama_toko': namaToko,
      'tipe_customer': tipeCustomer,
      'debt_balance': debtBalance,
    };
  }

  Map<String, dynamic> toApiBody() {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final num? parsedPhone = num.tryParse(cleanedPhone);

    return {
      'sales_id': salesId ?? '',
      'nama': name,
      'nomor_telpon': parsedPhone ?? phone,
      'email': (email != null && email!.trim().isNotEmpty) ? email!.trim() : null,
      'alamat': (address != null && address!.trim().isNotEmpty) ? address!.trim() : null,
      'alamat_maps': (alamatMaps != null && alamatMaps!.trim().isNotEmpty) ? alamatMaps!.trim() : null,
      'nama_toko': (namaToko != null && namaToko!.trim().isNotEmpty) ? namaToko!.trim() : null,
      'tipe_customer': tipeCustomer,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? salesId,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? alamatMaps,
    String? namaToko,
    int? tipeCustomer,
    double? debtBalance,
    String? salesName,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      salesId: salesId ?? this.salesId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      alamatMaps: alamatMaps ?? this.alamatMaps,
      namaToko: namaToko ?? this.namaToko,
      tipeCustomer: tipeCustomer ?? this.tipeCustomer,
      debtBalance: debtBalance ?? this.debtBalance,
      salesName: salesName ?? this.salesName,
    );
  }
}
