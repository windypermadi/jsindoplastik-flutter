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
  // {{url}}category/get-all?page=1&pageSize=50
  static String getCategoryParents({int page = 1, int pageSize = 50}) =>
      '$baseUrl/category/get-all?page=$page&pageSize=$pageSize';
  static String getCategoriesAll({int page = 1, int pageSize = 50}) =>
      '$baseUrl/category/get-all?page=$page&pageSize=$pageSize';

  // {{url}}category/get-jenis?parent=1
  static String getCategoryJenis(String parentId) =>
      '$baseUrl/category/get-jenis?parent=$parentId';

  // {{url}}type?page=1
  static String getTypes({int page = 1}) => '$baseUrl/type?page=$page';

  // {{url}}product/get-all-product?page=1&pageSize=20&search=&kategori=1&jenis=2&tipe=3
  static String getAllProductsFiltered({
    int? page,
    int? pageSize,
    String? search,
    String? kategori,
    String? jenis,
    String? tipe,
  }) {
    final params = <String>[];
    if (page != null && page > 0) params.add('page=$page');
    if (pageSize != null && pageSize > 0) params.add('pageSize=$pageSize');
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search.trim())}');
    }
    if (kategori != null && kategori.trim().isNotEmpty) {
      params.add('kategori=$kategori');
    }
    if (jenis != null && jenis.trim().isNotEmpty) {
      params.add('jenis=$jenis');
    }
    if (tipe != null && tipe.trim().isNotEmpty) {
      params.add('tipe=$tipe');
    }

    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/product/get-all-product$queryString';
  }

  // Standard Products & Categories
  static String get createProduct => '$baseUrl/product/new';
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
