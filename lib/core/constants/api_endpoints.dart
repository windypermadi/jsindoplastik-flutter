class ApiEndpoints {
  // Production / Test API Base URL
  static String baseUrl = 'https://poswenapidev.nalentora.cloud/api';

  // Auth ({{url}}auth/login)
  static String get login => '$baseUrl/auth/login';
  static String get profile => '$baseUrl/auth/profile';

  // User Info & Profile Image ({{url}}user/get-info & {{url}}user/{id}/image)
  static String get getUserInfo => '$baseUrl/user/get-info';
  static String updateUserImage(String id) => '$baseUrl/user/$id/image';

  // Categories, Jenis, Tipe & Filtered Products
  // {{url}}category/get-parent?page=1&pageSize=20
  static String getCategoryParents({int page = 1, int pageSize = 20}) =>
      '$baseUrl/category/get-parent?page=$page&pageSize=$pageSize';

  // {{url}}category/get-jenis?parent=1
  static String getCategoryJenis(String parentId) =>
      '$baseUrl/category/get-jenis?parent=$parentId';

  // {{url}}type?page=1
  static String getTypes({int page = 1}) => '$baseUrl/type?page=$page';

  // {{url}}product/get-all-product?kategori=24&jenis=26&tipe=16
  static String getAllProductsFiltered({
    String? kategori,
    String? jenis,
    String? tipe,
  }) {
    final params = <String>[];
    if (kategori != null && kategori.isNotEmpty) params.add('kategori=$kategori');
    if (jenis != null && jenis.isNotEmpty) params.add('jenis=$jenis');
    if (tipe != null && tipe.isNotEmpty) params.add('tipe=$tipe');

    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/product/get-all-product$queryString';
  }

  // Standard Products & Categories
  static String get products => '$baseUrl/products';
  static String get categories => '$baseUrl/categories';
  static String get manageProducts => '$baseUrl/products/manage';

  // Orders & POS Transactions
  static String get orders => '$baseUrl/orders';
  static String get checkout => '$baseUrl/orders/checkout';

  // Customers
  static String get customers => '$baseUrl/customers';

  // Users (Staff Management for Owner)
  static String get users => '$baseUrl/users';

  // Kasbon (Debt/Receivables)
  static String get kasbon => '$baseUrl/kasbon';
  static String get kasbonPay => '$baseUrl/kasbon/pay';

  // Stock Mutation
  static String get stockMutations => '$baseUrl/stock-mutations';

  // Reports
  static String get reportsSummary => '$baseUrl/reports/summary';
  static String get reportsSales => '$baseUrl/reports/sales';
  static String get reportsStock => '$baseUrl/reports/stock';

  // Sync
  static String get syncStatus => '$baseUrl/sync/status';
  static String get syncPush => '$baseUrl/sync/push';
}
