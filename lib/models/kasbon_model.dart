class KasbonModel {
  final String id;
  final String customerId;
  final String customerName;
  final String orderNumber;
  final double totalDebt;
  final double paidAmount;
  final double remainingDebt;
  final String status; // Belum Lunas, Sebagian, Lunas
  final DateTime date;
  final DateTime? dueDate;
  final String notes;

  KasbonModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.orderNumber,
    required this.totalDebt,
    required this.paidAmount,
    required this.remainingDebt,
    required this.status,
    required this.date,
    this.dueDate,
    this.notes = '',
  });

  factory KasbonModel.fromJson(Map<String, dynamic> json) {
    return KasbonModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? json['pelanggan'] ?? '',
      orderNumber: json['order_number'] ?? json['no_transaksi'] ?? '',
      totalDebt: (json['total_debt'] ?? json['total_kasbon'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? json['sudah_dibayar'] ?? 0).toDouble(),
      remainingDebt: (json['remaining_debt'] ?? json['sisa_kasbon'] ?? 0).toDouble(),
      status: json['status'] ?? 'Belum Lunas',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      notes: json['notes'] ?? json['catatan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'order_number': orderNumber,
      'total_debt': totalDebt,
      'paid_amount': paidAmount,
      'remaining_debt': remainingDebt,
      'status': status,
      'date': date.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'notes': notes,
    };
  }
}
