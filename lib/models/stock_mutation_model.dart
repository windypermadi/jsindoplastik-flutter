enum MutationType {
  inbound,  // Masuk
  outbound, // Keluar
}

extension MutationTypeExtension on MutationType {
  String get label {
    switch (this) {
      case MutationType.inbound:
        return 'Stok Masuk';
      case MutationType.outbound:
        return 'Stok Keluar';
    }
  }
}

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
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      userName: json['user_name'] ?? json['petugas'] ?? 'Admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'type': type == MutationType.inbound ? 'IN' : 'OUT',
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'date': date.toIso8601String(),
      'user_name': userName,
    };
  }
}
