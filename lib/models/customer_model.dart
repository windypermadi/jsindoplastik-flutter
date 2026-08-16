class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double debtBalance;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.debtBalance = 0.0,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['nomor_telepon']?.toString() ?? '',
      address: json['address']?.toString() ?? json['alamat']?.toString() ?? '',
      debtBalance: (json['debt_balance'] ?? json['total_kasbon'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'debt_balance': debtBalance,
    };
  }
}
