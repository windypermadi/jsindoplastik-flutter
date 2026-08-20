class ProductModel {
  final String id;
  final String code;
  final String name;
  final String? longName;
  final String category;
  final String? idKategori;
  final String? idType;
  final String? merek;
  final double buyPrice;
  final double sellPrice;
  final double? hargaReseller;
  final int stock;
  final int? batasStok;
  final String unit; // Pack, Bal, Roll, Dus, pcs
  final String? imageUrl;
  final bool isActive;
  final double? grosir1;
  final double? grosir2;
  final double? grosir3;
  final int? minBelanja1;
  final int? minBelanja2;
  final int? minBelanja3;
  final Map<String, dynamic>? rawJson;

  ProductModel({
    required this.id,
    required this.code,
    required this.name,
    this.longName,
    required this.category,
    this.idKategori,
    this.idType,
    this.merek,
    required this.buyPrice,
    required this.sellPrice,
    this.hargaReseller,
    required this.stock,
    this.batasStok,
    required this.unit,
    this.imageUrl,
    this.isActive = true,
    this.grosir1,
    this.grosir2,
    this.grosir3,
    this.minBelanja1,
    this.minBelanja2,
    this.minBelanja3,
    this.rawJson,
  });

  static double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? fallback;
    }
    return fallback;
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? fallback;
    }
    return fallback;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? '';
    final codeFallback = rawId.length > 8 ? rawId.substring(0, 8).toUpperCase() : (rawId.isNotEmpty ? rawId.toUpperCase() : 'SKU');

    // Parse category, jenis, tipe objects if present
    String? parsedParentId;
    String? parsedJenisId;
    String? parsedTypeId;
    String categoryName = 'Umum';

    if (json['kategori'] is Map) {
      final katMap = json['kategori'] as Map;
      parsedParentId = katMap['id']?.toString();
      categoryName = katMap['name']?.toString() ?? 'Umum';
    } else if (json['kategori'] != null) {
      categoryName = json['kategori'].toString();
    } else if (json['category'] != null) {
      categoryName = json['category'].toString();
    }

    if (json['jenis'] is Map) {
      final jenisMap = json['jenis'] as Map;
      parsedJenisId = jenisMap['id']?.toString();
    }

    if (json['tipe'] is Map) {
      final tipeMap = json['tipe'] as Map;
      parsedTypeId = tipeMap['id']?.toString();
    }

    final finalIdKategori = parsedJenisId ?? json['id_kategori']?.toString() ?? json['kategori_id']?.toString() ?? parsedParentId;
    final finalIdType = parsedTypeId ?? json['id_type']?.toString() ?? json['type_id']?.toString() ?? json['id_tipe']?.toString();

    // Parse price object safely
    double modalPrice = _parseDouble(json['harga_modal'] ?? json['buy_price'] ?? json['harga_beli']);
    double retailPrice = _parseDouble(json['harga_retail'] ?? json['sell_price'] ?? json['harga_jual'] ?? (json['price'] is! Map ? json['price'] : null));
    double? resellerPrice = json['harga_reseller'] != null ? _parseDouble(json['harga_reseller']) : null;

    double? g1, g2, g3;
    int? m1, m2, m3;

    if (json['price'] is Map) {
      final priceMap = json['price'] as Map;
      if (priceMap['modal'] != null) modalPrice = _parseDouble(priceMap['modal']);
      if (priceMap['retail'] != null) retailPrice = _parseDouble(priceMap['retail']);
      if (priceMap['reseller'] != null) resellerPrice = _parseDouble(priceMap['reseller']);

      if (priceMap['grosir'] is List) {
        final gList = priceMap['grosir'] as List;
        if (gList.isNotEmpty && gList[0] is Map) {
          g1 = _parseDouble(gList[0]['harga']);
          m1 = _parseInt(gList[0]['min_tr']);
        }
        if (gList.length > 1 && gList[1] is Map) {
          g2 = _parseDouble(gList[1]['harga']);
          m2 = _parseInt(gList[1]['min_tr']);
        }
        if (gList.length > 2 && gList[2] is Map) {
          g3 = _parseDouble(gList[2]['harga']);
          m3 = _parseInt(gList[2]['min_tr']);
        }
      }
    }

    if (g1 == null && json['grosir_1'] != null) g1 = _parseDouble(json['grosir_1']);
    if (g2 == null && json['grosir_2'] != null) g2 = _parseDouble(json['grosir_2']);
    if (g3 == null && json['grosir_3'] != null) g3 = _parseDouble(json['grosir_3']);

    if (m1 == null && json['min_belanja_1'] != null) m1 = _parseInt(json['min_belanja_1']);
    if (m2 == null && json['min_belanja_2'] != null) m2 = _parseInt(json['min_belanja_2']);
    if (m3 == null && json['min_belanja_3'] != null) m3 = _parseInt(json['min_belanja_3']);

    // Parse stock safely
    int stockTotal = 0;
    if (json['total'] != null && json['total'] is! Map) {
      stockTotal = _parseInt(json['total']);
    } else if (json['stok_awal'] != null && json['stok_awal'] is! Map) {
      stockTotal = _parseInt(json['stok_awal']);
    } else if (json['stok'] != null && json['stok'] is! Map) {
      stockTotal = _parseInt(json['stok']);
    } else if (json['stock'] != null && json['stock'] is! Map) {
      stockTotal = _parseInt(json['stock']);
    }

    int? minStock = json['batas_stok'] != null ? _parseInt(json['batas_stok']) : null;
    String stockUnit = json['satuan']?.toString() ?? json['unit']?.toString() ?? 'Pcs';

    if (json['stock'] is Map) {
      final stockMap = json['stock'] as Map;
      if (stockMap['total'] != null) stockTotal = _parseInt(stockMap['total']);
      if (stockMap['minimum'] != null) minStock = _parseInt(stockMap['minimum']);
      if (stockMap['unit'] != null) stockUnit = stockMap['unit'].toString();
    }

    return ProductModel(
      id: rawId,
      code: json['sku']?.toString() ?? json['code']?.toString() ?? json['kode']?.toString() ?? codeFallback,
      name: json['name']?.toString() ?? json['short_name']?.toString() ?? json['nama']?.toString() ?? 'Produk',
      longName: json['long_name']?.toString(),
      category: categoryName,
      idKategori: finalIdKategori,
      idType: finalIdType,
      merek: json['merek']?.toString() ?? json['brand']?.toString(),
      buyPrice: modalPrice,
      sellPrice: retailPrice,
      hargaReseller: resellerPrice,
      stock: stockTotal,
      batasStok: minStock,
      unit: stockUnit,
      imageUrl: json['image']?.toString() ?? json['gambar']?.toString() ?? json['image_url']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1' || json['is_active'] == 'true',
      grosir1: g1,
      grosir2: g2,
      grosir3: g3,
      minBelanja1: m1,
      minBelanja2: m2,
      minBelanja3: m3,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'long_name': longName,
      'category': category,
      'id_kategori': idKategori,
      'id_type': idType,
      'merek': merek,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'harga_reseller': hargaReseller,
      'stock': stock,
      'batas_stok': batasStok,
      'unit': unit,
      'image_url': imageUrl,
      'is_active': isActive,
      'grosir_1': grosir1,
      'grosir_2': grosir2,
      'grosir_3': grosir3,
      'min_belanja_1': minBelanja1,
      'min_belanja_2': minBelanja2,
      'min_belanja_3': minBelanja3,
    };
  }

  ProductModel copyWith({
    String? id,
    String? code,
    String? name,
    String? longName,
    String? category,
    String? idKategori,
    String? idType,
    String? merek,
    double? buyPrice,
    double? sellPrice,
    double? hargaReseller,
    int? stock,
    int? batasStok,
    String? unit,
    String? imageUrl,
    bool? isActive,
    double? grosir1,
    double? grosir2,
    double? grosir3,
    int? minBelanja1,
    int? minBelanja2,
    int? minBelanja3,
    Map<String, dynamic>? rawJson,
  }) {
    return ProductModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      longName: longName ?? this.longName,
      category: category ?? this.category,
      idKategori: idKategori ?? this.idKategori,
      idType: idType ?? this.idType,
      merek: merek ?? this.merek,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      hargaReseller: hargaReseller ?? this.hargaReseller,
      stock: stock ?? this.stock,
      batasStok: batasStok ?? this.batasStok,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      grosir1: grosir1 ?? this.grosir1,
      grosir2: grosir2 ?? this.grosir2,
      grosir3: grosir3 ?? this.grosir3,
      minBelanja1: minBelanja1 ?? this.minBelanja1,
      minBelanja2: minBelanja2 ?? this.minBelanja2,
      minBelanja3: minBelanja3 ?? this.minBelanja3,
      rawJson: rawJson ?? this.rawJson,
    );
  }
}
