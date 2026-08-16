class CategoryParentModel {
  final String id;
  final String name;
  final String? code;

  CategoryParentModel({
    required this.id,
    required this.name,
    this.code,
  });

  factory CategoryParentModel.fromJson(Map<String, dynamic> json) {
    return CategoryParentModel(
      id: json['id']?.toString() ?? json['category_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? 'Kategori',
      code: json['code']?.toString(),
    );
  }
}

class CategoryJenisModel {
  final String id;
  final String parentId;
  final String name;

  CategoryJenisModel({
    required this.id,
    required this.parentId,
    required this.name,
  });

  factory CategoryJenisModel.fromJson(Map<String, dynamic> json) {
    return CategoryJenisModel(
      id: json['id']?.toString() ?? '',
      parentId: json['parent_id']?.toString() ?? json['parent']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? 'Jenis',
    );
  }
}

class TypeModel {
  final String id;
  final String name;

  TypeModel({
    required this.id,
    required this.name,
  });

  factory TypeModel.fromJson(Map<String, dynamic> json) {
    return TypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? 'Tipe',
    );
  }
}
