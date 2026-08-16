enum UserRole {
  owner,
  sales,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.sales:
        return 'Sales';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? avatar;
  final UserRole role;
  final bool isActive;
  final List<dynamic> access;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.avatar,
    required this.role,
    this.isActive = true,
    this.access = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle response wrapper like { content: { ... } } or raw map
    final data = json.containsKey('content') && json['content'] is Map<String, dynamic> 
        ? json['content'] as Map<String, dynamic> 
        : json;

    final roleStr = (data['role'] ?? 'sales').toString().toLowerCase();
    
    return UserModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Pengguna',
      phone: data['phone']?.toString() ?? data['nomor_telepon']?.toString() ?? '',
      email: data['email']?.toString(),
      address: data['address']?.toString(),
      avatar: data['avatar']?.toString(),
      role: roleStr.contains('owner') ? UserRole.owner : UserRole.sales,
      isActive: data['is_active'] ?? true,
      access: data['access'] is List ? data['access'] as List : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'avatar': avatar,
      'role': role.displayName,
      'is_active': isActive,
      'access': access,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? avatar,
    UserRole? role,
    bool? isActive,
    List<dynamic>? access,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      access: access ?? this.access,
    );
  }
}
