class ApiEndpoints {
  // Production / Test API Base URL
  static String baseUrl = 'https://poswenapidev.nalentora.cloud/api';

  // Auth ({{url}}auth/login & {{url}}auth/logout)
  static String get login => '$baseUrl/auth/login';
  static String get logout => '$baseUrl/auth/logout';
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
  static String get getTypesUrl => '$baseUrl/type';
  static String getTypes({int page = 1}) => '$baseUrl/type?page=$page';

  // Add Category & Type endpoints
  static String get addCategory => '$baseUrl/category/add';
  static String get addType => '$baseUrl/type';

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

  // Sync Products API ({{url}}product/get-all?page=1&pageSize=50&search=)
  static String getProductsSyncUrl({
    int page = 1,
    int pageSize = 50,
    String? search,
  }) {
    final params = <String>[];
    params.add('page=$page');
    params.add('pageSize=$pageSize');
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search.trim())}');
    }
    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/product/get-all$queryString';
  }

  // Standard Products & Categories
  static String getProductDetail(String id) => '$baseUrl/product/get-product?kode=$id';
  static String get createProduct => '$baseUrl/product/new';
  static String get updateProduct => '$baseUrl/product/update';
  static String get products => '$baseUrl/products';
  static String get categories => '$baseUrl/categories';
  static String get manageProducts => '$baseUrl/products/manage';

  // Cart API ({{url}}cart, {{url}}cart/add, {{url}}cart/:id, {{url}}cart/:id/customer, {{url}}cart/:id/discount, {{url}}cart/:id/discount/remove)
  static String get cart => '$baseUrl/cart';
  static String get cartAdd => '$baseUrl/cart/add';
  static String getCartListUrl({int page = 1, int pageSize = 10}) => '$baseUrl/cart?page=$page&pageSize=$pageSize';
  static String getCartDetailUrl(String id) => '$baseUrl/cart/$id';
  static String getCartCustomerUrl(String cartId) => '$baseUrl/cart/$cartId/customer';
  static String getCartDiscountUrl(String cartId) => '$baseUrl/cart/$cartId/discount';
  static String getCartDiscountRemoveUrl(String cartId) => '$baseUrl/cart/$cartId/discount/remove';

  // Orders & POS Transactions
  static String get orders => '$baseUrl/orders';
  static String get checkout => '$baseUrl/checkout';
  static String get transactionSaved => '$baseUrl/transaction/saved';
  static String getTransactionSavedUrl({int page = 1}) => '$baseUrl/transaction/saved?page=$page';
  static String getTransactionSavedDetailUrl(String id) => '$baseUrl/transaction/saved/$id/detail';

  // Customers ({{url}}customer)
  static String get customers => '$baseUrl/customer';
  static String getCustomersFiltered({
    int page = 1,
    int pageSize = 10,
    String? filter,
    String? query,
  }) {
    final params = <String>[];
    params.add('page=$page');
    params.add('pageSize=$pageSize');
    if (filter != null && filter.trim().isNotEmpty) {
      params.add('filter=${Uri.encodeComponent(filter.trim())}');
    }
    if (query != null && query.trim().isNotEmpty) {
      params.add('query=${Uri.encodeComponent(query.trim())}');
    }
    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/customer$queryString';
  }
  static String get customerCreate => '$baseUrl/customer';
  static String customerDetail(String id) => '$baseUrl/customer/$id';
  static String customerUpdate(String id) => '$baseUrl/customer/$id';
  static String customerDelete(String id) => '$baseUrl/customer/$id';
  static String get customerDeleteMany => '$baseUrl/customer/delete/many';

  // Users (Staff Management for Owner - {{url}}user)
  static String get users => '$baseUrl/user';
  static String getUsersFiltered({
    int page = 1,
    int pageSize = 10,
    String? filter,
    String? query,
  }) {
    final params = <String>[];
    params.add('page=$page');
    params.add('pageSize=$pageSize');
    if (filter != null && filter.trim().isNotEmpty) {
      params.add('filter=${Uri.encodeComponent(filter.trim())}');
    }
    if (query != null && query.trim().isNotEmpty) {
      params.add('query=${Uri.encodeComponent(query.trim())}');
    }
    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/user$queryString';
  }
  static String get userCreate => '$baseUrl/user';
  static String userDetail(String id) => '$baseUrl/user/$id';
  static String userUpdate(String id) => '$baseUrl/user/$id';
  static String userDelete(String id) => '$baseUrl/user/$id';

  // Kasbon (Debt/Receivables)
  static String get kasbon => '$baseUrl/kasbon';
  static String get kasbonPay => '$baseUrl/kasbon/pay';

  // Stock Mutation ({{url}}stock)
  static String get stock => '$baseUrl/stock';
  static String getStockFiltered({
    int page = 1,
    int pageSize = 10,
    String? filter,
    String? sort,
    String? search,
  }) {
    final params = <String>[];
    params.add('page=$page');
    params.add('pageSize=$pageSize');
    if (filter != null && filter.trim().isNotEmpty) {
      params.add('filter=${Uri.encodeComponent(filter.trim())}');
    }
    if (sort != null && sort.trim().isNotEmpty) {
      params.add('sort=${Uri.encodeComponent(sort.trim())}');
    }
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search.trim())}');
    }
    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/stock$queryString';
  }
  static String getStockDetailUrl(String id) => '$baseUrl/stock/$id';
  static String getStockAdjustmentUrl(String id) => '$baseUrl/stock/$id/adjustment';

  // Reports
  static String get reportDashboard => '$baseUrl/report/dashboard';
  static String getReportFilteredUrl({
    required String type,
    required String filter,
    String? dateStart,
    String? dateEnd,
  }) {
    final params = <String>[];
    params.add('type=${Uri.encodeComponent(type)}');
    params.add('filter=${Uri.encodeComponent(filter)}');
    if (dateStart != null && dateStart.trim().isNotEmpty) {
      params.add('date_start=${Uri.encodeComponent(dateStart.trim())}');
    }
    if (dateEnd != null && dateEnd.trim().isNotEmpty) {
      params.add('date_end=${Uri.encodeComponent(dateEnd.trim())}');
    }
    return '$baseUrl/report?${params.join('&')}';
  }
  static String getReportDashboardInUrl({int page = 1, int pageSize = 10}) =>
      '$baseUrl/report/dashboard/in?page=$page&pageSize=$pageSize';
  static String getReportDashboardInDetailUrl(String invoice) =>
      '$baseUrl/report/dashboard/in/$invoice';
  static String getReportDashboardSavedUrl({int page = 1, int pageSize = 10}) =>
      '$baseUrl/report/dashboard/saved?page=$page&pageSize=$pageSize';
  static String getReportDashboardSavedDetailUrl(String id) =>
      '$baseUrl/report/dashboard/saved/$id';
  static String get reportsSummary => '$baseUrl/reports/summary';
  static String get reportsSales => '$baseUrl/reports/sales';
  static String get reportsStock => '$baseUrl/reports/stock';

  // Sync
  static String get syncStatus => '$baseUrl/sync/status';
  static String get syncPush => '$baseUrl/sync/push';
}
