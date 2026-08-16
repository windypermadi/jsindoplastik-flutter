class ProductModel {
  final String id;
  final String code;
  final String name;
  final String? longName;
  final String category;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final String unit; // Pack, Bal, Roll, Dus, pcs
  final String? imageUrl;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.code,
    required this.name,
    this.longName,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.unit,
    this.imageUrl,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? '';
    final codeFallback = rawId.length > 8 ? rawId.substring(0, 8).toUpperCase() : (rawId.isNotEmpty ? rawId.toUpperCase() : 'SKU');

    return ProductModel(
      id: rawId,
      code: json['sku']?.toString() ?? json['code']?.toString() ?? json['kode']?.toString() ?? codeFallback,
      name: json['name']?.toString() ?? json['short_name']?.toString() ?? json['nama']?.toString() ?? 'Produk',
      longName: json['long_name']?.toString(),
      category: json['category']?.toString() ?? json['kategori']?.toString() ?? 'Umum',
      buyPrice: (json['harga_modal'] ?? json['buy_price'] ?? json['harga_beli'] ?? 0).toDouble(),
      sellPrice: (json['harga_retail'] ?? json['sell_price'] ?? json['harga_jual'] ?? 0).toDouble(),
      stock: (json['total'] ?? json['stok_awal'] ?? json['stock'] ?? json['stok'] ?? 0).toInt(),
      unit: json['satuan']?.toString() ?? json['unit']?.toString() ?? 'Pcs',
      imageUrl: json['image'] ?? json['gambar'] ?? json['image_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1' || json['is_active'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'stock': stock,
      'unit': unit,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  ProductModel copyWith({
    String? id,
    String? code,
    String? name,
    String? category,
    double? buyPrice,
    double? sellPrice,
    int? stock,
    String? unit,
    String? imageUrl,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
