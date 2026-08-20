import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<CategoryParentModel> _categoryParents = [];
  List<CategoryJenisModel> _categoryJenis = [];
  List<TypeModel> _types = [];

  CategoryParentModel? _selectedParent;
  CategoryJenisModel? _selectedJenis;
  TypeModel? _selectedType;

  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMoreParents = false;

  // Pagination for products ({{url}}product/get-all)
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalProducts = 0;

  // Pagination for category parents
  int _parentsPage = 1;
  final int _parentsPageSize = 50;
  bool _hasMoreParents = true;

  List<ProductModel> get products => _products;
  List<ProductModel> get allProducts => _products;
  List<CategoryParentModel> get categoryParents => List.unmodifiable(_categoryParents);
  List<CategoryJenisModel> get categoryJenis => List.unmodifiable(_categoryJenis);
  List<TypeModel> get types => List.unmodifiable(_types);

  CategoryParentModel? get selectedParent => _selectedParent;
  CategoryJenisModel? get selectedJenis => _selectedJenis;
  TypeModel? get selectedType => _selectedType;

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingMoreParents => _isLoadingMoreParents;
  bool get hasMoreParents => _hasMoreParents;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalProducts => _totalProducts;
  bool get hasNextPage => _currentPage < _lastPage;
  bool get hasPrevPage => _currentPage > 1;

  ProductProvider() {
    initCatalogData();
  }

  Future<void> initCatalogData() async {
    await fetchParentCategories(refresh: true);
    if (_categoryParents.isNotEmpty) {
      await fetchJenisCategories(_categoryParents.first.id);
    }
    await fetchTypes();
    await fetchProductsFiltered(page: 1);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    fetchProductsFiltered(page: 1);
  }

  List _extractRawList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
    if (rawData is Map) {
      final content = rawData['content'];
      if (content is Map && content['data'] is List) {
        return content['data'];
      }
      if (content is List) {
        return content;
      }
      if (rawData['data'] is List) {
        return rawData['data'];
      }
      if (rawData['products'] is List) {
        return rawData['products'];
      }
      if (rawData['categories'] is List) {
        return rawData['categories'];
      }
      if (rawData['types'] is List) {
        return rawData['types'];
      }
      if (rawData['jenis'] is List) {
        return rawData['jenis'];
      }
      if (rawData['result'] is List) {
        return rawData['result'];
      }
    }
    return [];
  }

  // 1. Fetch Parent Categories with Infinite Scroll (page & pageSize=10)
  Future<void> fetchParentCategories({bool refresh = false}) async {
    if (refresh) {
      _parentsPage = 1;
      _hasMoreParents = true;
      _categoryParents.clear();
      _isLoading = true;
      notifyListeners();
    } else {
      if (!_hasMoreParents || _isLoadingMoreParents) return;
      _isLoadingMoreParents = true;
      notifyListeners();
    }

    final endpoint = ApiEndpoints.getCategoryParents(
      page: _parentsPage,
      pageSize: _parentsPageSize,
    );

    final response = await ApiService.get(endpoint);
    if (response.isSuccess && response.data != null) {
      final List list = _extractRawList(response.data);

      final allParsed = list
          .map((e) => CategoryParentModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .toList();

      final parentsOnly = allParsed
          .where((cat) => cat.isActive && (cat.tipe == null || cat.tipe!.toLowerCase() == 'kategori'))
          .toList();

      final jenisOnly = list
          .map((e) => CategoryJenisModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .where((j) => j.isActive && j.tipe != null && j.tipe!.toLowerCase() == 'jenis')
          .toList();

      if (list.length < _parentsPageSize) {
        _hasMoreParents = false;
      }

      if (refresh) {
        _categoryParents = parentsOnly;
        if (_categoryJenis.isEmpty && jenisOnly.isNotEmpty) {
          _categoryJenis = jenisOnly;
        }
      } else {
        _categoryParents.addAll(parentsOnly);
      }

      _parentsPage++;
    } else if (refresh) {
      _categoryParents = [];
    }

    _isLoading = false;
    _isLoadingMoreParents = false;
    notifyListeners();
  }

  // Select Parent Category & fetch Jenis
  Future<void> selectParentCategory(CategoryParentModel? parent) async {
    if (_selectedParent?.id == parent?.id && parent != null) return;
    _selectedParent = parent;
    _selectedJenis = null;
    _categoryJenis.clear();
    notifyListeners();

    if (parent != null) {
      await fetchJenisCategories(parent.id);
    }
    await fetchProductsFiltered();
  }

  // 2. Fetch Jenis Categories for selected Parent ({{url}}category/get-jenis?parent=1)
  Future<void> fetchJenisCategories(String parentId) async {
    final response = await ApiService.get(ApiEndpoints.getCategoryJenis(parentId));
    if (response.isSuccess && response.data != null) {
      final List list = _extractRawList(response.data);
      final parsed = list
          .map((e) => CategoryJenisModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .where((j) => j.id.isNotEmpty && j.name.isNotEmpty)
          .toList();

      if (parsed.isNotEmpty) {
        _categoryJenis = parsed;
      }
    }
    notifyListeners();
  }

  // Select Jenis Category
  Future<void> selectJenisCategory(CategoryJenisModel? jenis) async {
    if (_selectedJenis?.id == jenis?.id && jenis != null) return;
    _selectedJenis = jenis;
    notifyListeners();

    await fetchProductsFiltered();
  }

  // 3. Fetch Types ({{url}}type?page=1)
  Future<void> fetchTypes() async {
    final response = await ApiService.get(ApiEndpoints.getTypes(page: 1));
    if (response.isSuccess && response.data != null) {
      final List list = _extractRawList(response.data);
      _types = list
          .map((e) => TypeModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .where((t) => t.id.isNotEmpty && t.name.isNotEmpty)
          .toList();
    } else {
      _types = [];
    }
    notifyListeners();
  }

  // Select Type
  Future<void> selectType(TypeModel? type) async {
    if (_selectedType?.id == type?.id && type != null) return;
    _selectedType = type;
    notifyListeners();

    await fetchProductsFiltered();
  }

  Future<void> loadLocalProducts() async {
    _isLoading = true;
    notifyListeners();

    final localProducts = await StorageService.getLocalProducts();
    if (localProducts.isNotEmpty) {
      _products = localProducts;
    }
    _isLoading = false;
    notifyListeners();
  }

  // 4. Fetch Products ({{url}}product/get-all?page=1&pageSize=20&search=)
  Future<void> fetchProductsFiltered({int page = 1, int pageSize = 20}) async {
    _currentPage = page;
    _isLoading = true;
    notifyListeners();

    final endpoint = ApiEndpoints.getProductsSyncUrl(
      page: _currentPage,
      pageSize: pageSize,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    final response = await ApiService.get(endpoint);
    if (response.isSuccess && response.data != null) {
      final dynamic resData = response.data;
      final List list = _extractRawList(resData);

      if (resData is Map) {
        final contentMap = (resData['content'] is Map) ? resData['content'] : resData;
        _currentPage = int.tryParse(contentMap['current_page']?.toString() ?? '$_currentPage') ?? _currentPage;
        _lastPage = int.tryParse(contentMap['last_page']?.toString() ?? '1') ?? 1;
        _totalProducts = int.tryParse(contentMap['total']?.toString() ?? '${list.length}') ?? list.length;
      }

      if (list.isNotEmpty) {
        _products = list.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
      } else {
        await loadLocalProducts();
      }
    } else {
      await loadLocalProducts();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextPage() async {
    if (hasNextPage) {
      await fetchProductsFiltered(page: _currentPage + 1);
    }
  }

  Future<void> prevPage() async {
    if (hasPrevPage) {
      await fetchProductsFiltered(page: _currentPage - 1);
    }
  }

  Future<ApiResponse<dynamic>> addCategoryParent(String name) async {
    _isLoading = true;
    notifyListeners();

    final payload = <String, dynamic>{
      'id_parent': null,
      'nama_kategori': name.trim(),
      'is_active': true,
      'has_parent': false,
    };

    final response = await ApiService.post(ApiEndpoints.addCategory, payload);
    if (response.isSuccess) {
      await fetchParentCategories(refresh: true);
    } else {
      _isLoading = false;
      notifyListeners();
    }
    return response;
  }

  Future<ApiResponse<dynamic>> addCategoryJenis({
    required dynamic parentId,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    final parsedParentId = int.tryParse(parentId.toString()) ?? parentId;

    final payload = <String, dynamic>{
      'id_parent': parsedParentId,
      'nama_kategori': name.trim(),
      'is_active': true,
      'has_parent': true,
    };

    final response = await ApiService.post(ApiEndpoints.addCategory, payload);
    if (response.isSuccess) {
      await fetchJenisCategories(parentId.toString());
    } else {
      _isLoading = false;
      notifyListeners();
    }
    return response;
  }

  Future<ApiResponse<dynamic>> addType(String name) async {
    _isLoading = true;
    notifyListeners();

    final payload = <String, dynamic>{
      'nama': name.trim(),
    };

    final response = await ApiService.post(ApiEndpoints.addType, payload);
    if (response.isSuccess) {
      await fetchTypes();
    } else {
      _isLoading = false;
      notifyListeners();
    }
    return response;
  }

  Future<bool> createNewProduct(Map<String, dynamic> bodyData) async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.post(ApiEndpoints.createProduct, bodyData);
    if (response.isSuccess) {
      await fetchProductsFiltered();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProductApi(Map<String, dynamic> bodyData) async {
    _isLoading = true;
    notifyListeners();

    if (bodyData.containsKey('id_kategori') && bodyData['id_kategori'] != null) {
      bodyData['id_kategori'] = int.tryParse(bodyData['id_kategori'].toString()) ?? bodyData['id_kategori'];
    }

    var response = await ApiService.post(ApiEndpoints.updateProduct, bodyData);
    if (!response.isSuccess && response.statusCode == 405) {
      response = await ApiService.put(ApiEndpoints.updateProduct, bodyData);
    }

    if (response.isSuccess) {
      await fetchProductsFiltered();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<ProductModel?> fetchProductDetail(String productId) async {
    final response = await ApiService.get(ApiEndpoints.getProductDetail(productId));
    if (response.isSuccess && response.data != null) {
      final dynamic raw = response.data;
      if (raw is Map) {
        final Map<String, dynamic> contentMap = Map<String, dynamic>.from(raw['content'] is Map ? raw['content'] : raw);
        return ProductModel.fromJson(contentMap);
      }
    }
    return null;
  }

  Future<bool> addProduct(ProductModel product) async {
    _products.add(product);
    notifyListeners();
    return true;
  }

  Future<bool> updateProduct(ProductModel product) async {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _products[idx] = product;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    return true;
  }

  List<CategoryParentModel> _getMockCategoryParents() {
    return [
      CategoryParentModel(id: '24', name: 'Kantong Plastik'),
      CategoryParentModel(id: '25', name: 'Thinwall & Food Container'),
      CategoryParentModel(id: '26', name: 'Gelas & Straw'),
      CategoryParentModel(id: '27', name: 'Packaging & Wrap'),
      CategoryParentModel(id: '28', name: 'Sendok & Garpu'),
      CategoryParentModel(id: '29', name: 'Mika Plastik'),
    ];
  }

  List<ProductModel> _getMockProducts() {
    return [
      ProductModel(
        id: 'P001',
        code: 'KRS-01',
        name: 'Kantong Kresek HD Uk. 24 Bening',
        category: 'Kantong Plastik',
        buyPrice: 12000,
        sellPrice: 16500,
        stock: 120,
        unit: 'Pack',
      ),
      ProductModel(
        id: 'P002',
        code: 'KRS-02',
        name: 'Kantong Kresek HD Uk. 15 Hitam Premium',
        category: 'Kantong Plastik',
        buyPrice: 8500,
        sellPrice: 12000,
        stock: 85,
        unit: 'Pack',
      ),
      ProductModel(
        id: 'P003',
        code: 'TW-500',
        name: 'Thinwall Rectangle 500ml (Isi 25)',
        category: 'Thinwall & Food Container',
        buyPrice: 22000,
        sellPrice: 28500,
        stock: 45,
        unit: 'Pack',
      ),
      ProductModel(
        id: 'P004',
        code: 'TW-1000',
        name: 'Thinwall Square 1000ml (Isi 25)',
        category: 'Thinwall & Food Container',
        buyPrice: 31000,
        sellPrice: 39000,
        stock: 30,
        unit: 'Pack',
      ),
      ProductModel(
        id: 'P005',
        code: 'CUP-16',
        name: 'Cup Plastik Oval 16oz Heavy (Isi 50)',
        category: 'Gelas & Straw',
        buyPrice: 18000,
        sellPrice: 23500,
        stock: 14,
        unit: 'Slop',
      ),
    ];
  }
}
