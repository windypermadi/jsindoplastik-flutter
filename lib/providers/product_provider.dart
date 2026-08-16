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

  // Pagination for category parents
  int _parentsPage = 1;
  final int _parentsPageSize = 20;
  bool _hasMoreParents = true;

  List<ProductModel> get products => _filteredProducts();
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

  ProductProvider() {
    initCatalogData();
  }

  Future<void> initCatalogData() async {
    await fetchParentCategories(refresh: true);
    await fetchTypes();
    await fetchProductsFiltered();
  }

  List<ProductModel> _filteredProducts() {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 1. Fetch Parent Categories with Infinite Scroll (page & pageSize=20)
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

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (refresh) {
        _categoryParents = _getMockCategoryParents();
      }
      _isLoading = false;
      _isLoadingMoreParents = false;
      notifyListeners();
      return;
    }

    final endpoint = ApiEndpoints.getCategoryParents(
      page: _parentsPage,
      pageSize: _parentsPageSize,
    );

    final response = await ApiService.get(endpoint);
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List
          ? response.data
          : (response.data['content'] ?? response.data['data'] ?? []);

      final parsed = list.map((e) => CategoryParentModel.fromJson(e)).toList();

      if (parsed.length < _parentsPageSize) {
        _hasMoreParents = false;
      }

      if (refresh) {
        _categoryParents = parsed;
      } else {
        _categoryParents.addAll(parsed);
      }

      _parentsPage++;
    } else if (refresh) {
      _categoryParents = _getMockCategoryParents();
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
    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      _categoryJenis = [
        CategoryJenisModel(id: '26', parentId: parentId, name: 'Kantong HD Bening'),
        CategoryJenisModel(id: '27', parentId: parentId, name: 'Kantong HD Hitam'),
        CategoryJenisModel(id: '28', parentId: parentId, name: 'Thinwall Square'),
        CategoryJenisModel(id: '29', parentId: parentId, name: 'Cup Minuman Oval'),
      ];
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.getCategoryJenis(parentId));
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List
          ? response.data
          : (response.data['content'] ?? response.data['data'] ?? []);
      _categoryJenis = list.map((e) => CategoryJenisModel.fromJson(e)).toList();
    } else {
      _categoryJenis = [];
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
    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _types = [
        TypeModel(id: '16', name: 'Tipe Super 24'),
        TypeModel(id: '17', name: 'Tipe Losspack 15'),
        TypeModel(id: '18', name: 'Tipe Premium 500ml'),
      ];
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.getTypes(page: 1));
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List
          ? response.data
          : (response.data['content'] ?? response.data['data'] ?? []);
      _types = list.map((e) => TypeModel.fromJson(e)).toList();
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

  // 4. Fetch Products Filtered ({{url}}product/get-all-product?kategori=24&jenis=26&tipe=16)
  Future<void> fetchProductsFiltered() async {
    _isLoading = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _products = _getMockProducts();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final endpoint = ApiEndpoints.getAllProductsFiltered(
      kategori: _selectedParent?.id,
      jenis: _selectedJenis?.id,
      tipe: _selectedType?.id,
    );

    final response = await ApiService.get(endpoint);
    if (response.isSuccess && response.data != null) {
      final List list = response.data is List
          ? response.data
          : (response.data['content'] ?? response.data['products'] ?? response.data['data'] ?? []);
      _products = list.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      _products = _getMockProducts();
    }

    _isLoading = false;
    notifyListeners();
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
