class ProductModel {
  final String id;
  final String code;
  final String name;
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
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.unit,
    this.imageUrl,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? json['kode']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? '',
      category: json['category']?.toString() ?? json['kategori']?.toString() ?? 'Umum',
      buyPrice: (json['buy_price'] ?? json['harga_beli'] ?? 0).toDouble(),
      sellPrice: (json['sell_price'] ?? json['harga_jual'] ?? 0).toDouble(),
      stock: (json['stock'] ?? json['stok'] ?? 0).toInt(),
      unit: json['unit']?.toString() ?? json['satuan']?.toString() ?? 'pcs',
      imageUrl: json['image_url'] ?? json['gambar'],
      isActive: json['is_active'] ?? true,
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
