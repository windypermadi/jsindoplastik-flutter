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

    // Parse price object if present
    double modalPrice = (json['harga_modal'] ?? json['buy_price'] ?? json['harga_beli'] ?? 0).toDouble();
    double retailPrice = (json['harga_retail'] ?? json['sell_price'] ?? json['harga_jual'] ?? 0).toDouble();
    double? resellerPrice = json['harga_reseller'] != null ? (json['harga_reseller']).toDouble() : null;

    double? g1, g2, g3;
    int? m1, m2, m3;

    if (json['price'] is Map) {
      final priceMap = json['price'] as Map;
      if (priceMap['modal'] != null) modalPrice = (priceMap['modal']).toDouble();
      if (priceMap['retail'] != null) retailPrice = (priceMap['retail']).toDouble();
      if (priceMap['reseller'] != null) resellerPrice = (priceMap['reseller']).toDouble();

      if (priceMap['grosir'] is List) {
        final gList = priceMap['grosir'] as List;
        if (gList.isNotEmpty && gList[0] is Map) {
          g1 = (gList[0]['harga'] ?? 0).toDouble();
          m1 = (gList[0]['min_tr'] ?? 0).toInt();
        }
        if (gList.length > 1 && gList[1] is Map) {
          g2 = (gList[1]['harga'] ?? 0).toDouble();
          m2 = (gList[1]['min_tr'] ?? 0).toInt();
        }
        if (gList.length > 2 && gList[2] is Map) {
          g3 = (gList[2]['harga'] ?? 0).toDouble();
          m3 = (gList[2]['min_tr'] ?? 0).toInt();
        }
      }
    }

    if (g1 == null && json['grosir_1'] != null) g1 = (json['grosir_1']).toDouble();
    if (g2 == null && json['grosir_2'] != null) g2 = (json['grosir_2']).toDouble();
    if (g3 == null && json['grosir_3'] != null) g3 = (json['grosir_3']).toDouble();

    if (m1 == null && json['min_belanja_1'] != null) m1 = (json['min_belanja_1']).toInt();
    if (m2 == null && json['min_belanja_2'] != null) m2 = (json['min_belanja_2']).toInt();
    if (m3 == null && json['min_belanja_3'] != null) m3 = (json['min_belanja_3']).toInt();

    // Parse stock object if present
    int stockTotal = (json['total'] ?? json['stok_awal'] ?? json['stock'] ?? json['stok'] ?? 0).toInt();
    int? minStock = json['batas_stok'] != null ? (json['batas_stok']).toInt() : null;
    String stockUnit = json['satuan']?.toString() ?? json['unit']?.toString() ?? 'Pcs';

    if (json['stock'] is Map) {
      final stockMap = json['stock'] as Map;
      if (stockMap['total'] != null) stockTotal = (stockMap['total']).toInt();
      if (stockMap['minimum'] != null) minStock = (stockMap['minimum']).toInt();
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
      imageUrl: json['image'] ?? json['gambar'] ?? json['image_url'],
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
