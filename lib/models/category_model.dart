class CategoryParentModel {
  final String id;
  final String name;
  final String? code;
  final String? tipe;
  final bool isActive;

  CategoryParentModel({
    required this.id,
    required this.name,
    this.code,
    this.tipe,
    this.isActive = true,
  });

  factory CategoryParentModel.fromJson(Map<String, dynamic> json) {
    return CategoryParentModel(
      id: json['id']?.toString() ?? json['category_id']?.toString() ?? json['id_kategori']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? json['nama_kategori']?.toString() ?? json['kategori']?.toString() ?? 'Kategori',
      code: json['code']?.toString() ?? json['kode']?.toString(),
      tipe: json['tipe']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == 'true',
    );
  }
}

class CategoryJenisModel {
  final String id;
  final String parentId;
  final String name;
  final String? tipe;
  final bool isActive;

  CategoryJenisModel({
    required this.id,
    required this.parentId,
    required this.name,
    this.tipe,
    this.isActive = true,
  });

  factory CategoryJenisModel.fromJson(Map<String, dynamic> json) {
    return CategoryJenisModel(
      id: json['id']?.toString() ?? json['id_jenis']?.toString() ?? '',
      parentId: json['parent_id']?.toString() ?? json['parent']?.toString() ?? json['id_parent']?.toString() ?? json['kategori_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? json['nama_jenis']?.toString() ?? json['jenis']?.toString() ?? 'Jenis',
      tipe: json['tipe']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == 'true',
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
      id: json['id']?.toString() ?? json['id_tipe']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nama']?.toString() ?? json['nama_tipe']?.toString() ?? json['tipe']?.toString() ?? 'Tipe',
    );
  }
}
