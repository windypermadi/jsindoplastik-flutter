enum UserRole {
  owner,
  sales,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.sales:
        return 'Sales';
      case UserRole.admin:
        return 'Admin';
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
  final String rawRole;
  final bool isActive;
  final String? updatedAt;
  final List<dynamic> access;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.avatar,
    required this.role,
    this.rawRole = 'Sales',
    this.isActive = true,
    this.updatedAt,
    this.access = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('content') && json['content'] is Map<String, dynamic> 
        ? json['content'] as Map<String, dynamic> 
        : json;

    final rawRoleStr = (data['role'] ?? 'Sales').toString();
    final roleStrLower = rawRoleStr.toLowerCase();
    
    UserRole parsedRole = UserRole.sales;
    if (roleStrLower.contains('owner')) {
      parsedRole = UserRole.owner;
    } else if (roleStrLower.contains('admin')) {
      parsedRole = UserRole.admin;
    } else {
      parsedRole = UserRole.sales;
    }

    return UserModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Pengguna',
      phone: data['phone']?.toString() ?? data['nomor_telepon']?.toString() ?? '',
      email: data['email']?.toString(),
      address: data['address']?.toString(),
      avatar: data['avatar']?.toString(),
      role: parsedRole,
      rawRole: rawRoleStr.isNotEmpty ? rawRoleStr : parsedRole.displayName,
      isActive: data['is_active'] ?? true,
      updatedAt: data['updated_at']?.toString(),
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
      'role': rawRole.isNotEmpty ? rawRole : role.displayName,
      'is_active': isActive,
      'updated_at': updatedAt,
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
    String? rawRole,
    bool? isActive,
    String? updatedAt,
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
      rawRole: rawRole ?? this.rawRole,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      access: access ?? this.access,
    );
  }
}
