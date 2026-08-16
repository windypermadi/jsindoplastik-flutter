import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

class KelolaProdukView extends StatefulWidget {
  const KelolaProdukView({super.key});

  @override
  State<KelolaProdukView> createState() => _KelolaProdukViewState();
}

class _KelolaProdukViewState extends State<KelolaProdukView> {
  final ScrollController _categoryParentsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _categoryParentsScrollController.addListener(_onCategoryParentsScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      if (productProv.categoryParents.isEmpty) {
        productProv.initCatalogData();
      }
    });
  }

  @override
  void dispose() {
    _categoryParentsScrollController.removeListener(_onCategoryParentsScroll);
    _categoryParentsScrollController.dispose();
    super.dispose();
  }

  void _onCategoryParentsScroll() {
    if (_categoryParentsScrollController.position.pixels >=
        _categoryParentsScrollController.position.maxScrollExtent - 50) {
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      if (productProv.hasMoreParents && !productProv.isLoadingMoreParents) {
        productProv.fetchParentCategories(refresh: false);
      }
    }
  }

  void _openAddProductModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddProductFormModal(),
    );
  }

  void _confirmDelete(ProductModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final productProv = Provider.of<ProductProvider>(context, listen: false);
              await productProv.deleteProduct(item.id);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produk dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _openAddProductModal(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => productProv.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari produk untuk dikelola...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  tooltip: 'Muat Ulang Data',
                  onPressed: () => productProv.initCatalogData(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. Level 1: Kategori (Parent)
            const Text(
              '1. Kategori Produk',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 38,
              child: ListView.builder(
                controller: _categoryParentsScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: productProv.categoryParents.length + 1 + (productProv.isLoadingMoreParents ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = productProv.selectedParent == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: const Text('Semua Kategori'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) => productProv.selectParentCategory(null),
                      ),
                    );
                  }

                  final itemIndex = index - 1;
                  if (itemIndex < productProv.categoryParents.length) {
                    final cat = productProv.categoryParents[itemIndex];
                    final isSelected = productProv.selectedParent?.id == cat.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) => productProv.selectParentCategory(cat),
                      ),
                    );
                  }

                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 2. Level 2: Jenis Sub-Kategori
            if (productProv.categoryJenis.isNotEmpty) ...[
              const Text(
                '2. Jenis Sub-Kategori',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productProv.categoryJenis.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = productProv.selectedJenis == null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: const Text('Semua Jenis'),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontSize: 11,
                          ),
                          onSelected: (_) => productProv.selectJenisCategory(null),
                        ),
                      );
                    }

                    final j = productProv.categoryJenis[index - 1];
                    final isSelected = productProv.selectedJenis?.id == j.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text(j.name),
                        selected: isSelected,
                        selectedColor: AppColors.accent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 11,
                        ),
                        onSelected: (_) => productProv.selectJenisCategory(j),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 3. Level 3: Tipe Produk
            if (productProv.types.isNotEmpty) ...[
              const Text(
                '3. Tipe Produk',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productProv.types.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = productProv.selectedType == null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: const Text('Semua Tipe'),
                          selected: isSelected,
                          selectedColor: AppColors.primaryDark,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontSize: 11,
                          ),
                          onSelected: (_) => productProv.selectType(null),
                        ),
                      );
                    }

                    final t = productProv.types[index - 1];
                    final isSelected = productProv.selectedType?.id == t.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(t.name),
                        selected: isSelected,
                        selectedColor: AppColors.primaryDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 11,
                        ),
                        onSelected: (_) => productProv.selectType(t),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 4. Product List
            Expanded(
              child: productProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productProv.products.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada produk ditemukan.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: productProv.products.length,
                          itemBuilder: (context, index) {
                            final p = productProv.products[index];
                            return Card(
                              elevation: 1.5,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  'SKU: ${p.code} • Modal: ${Formatters.rupiah(p.buyPrice)} • Retail: ${Formatters.rupiah(p.sellPrice)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Stok: ${p.stock} ${p.unit}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                      onPressed: () => _confirmDelete(p),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProductFormModal extends StatefulWidget {
  const _AddProductFormModal();

  @override
  State<_AddProductFormModal> createState() => _AddProductFormModalState();
}

class _AddProductFormModalState extends State<_AddProductFormModal> {
  final _formKey = GlobalKey<FormState>();

  CategoryParentModel? _selectedParent;
  CategoryJenisModel? _selectedJenis;
  TypeModel? _selectedType;

  List<CategoryJenisModel> _availableJenis = [];
  bool _isLoadingJenis = false;

  final _skuController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _longNameController = TextEditingController();
  final _merekController = TextEditingController();
  final _satuanController = TextEditingController(text: 'kg');
  final _stokAwalController = TextEditingController(text: '0');
  final _batasStokController = TextEditingController(text: '10');

  final _hargaModalController = TextEditingController();
  final _hargaRetailController = TextEditingController();
  final _hargaResellerController = TextEditingController();

  final _grosir1Controller = TextEditingController();
  final _grosir2Controller = TextEditingController();
  final _grosir3Controller = TextEditingController();

  final _minBelanja1Controller = TextEditingController();
  final _minBelanja2Controller = TextEditingController();
  final _minBelanja3Controller = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      if (productProv.categoryParents.isEmpty || productProv.types.isEmpty) {
        productProv.initCatalogData();
      }
    });
  }

  @override
  void dispose() {
    _skuController.dispose();
    _shortNameController.dispose();
    _longNameController.dispose();
    _merekController.dispose();
    _satuanController.dispose();
    _stokAwalController.dispose();
    _batasStokController.dispose();

    _hargaModalController.dispose();
    _hargaRetailController.dispose();
    _hargaResellerController.dispose();

    _grosir1Controller.dispose();
    _grosir2Controller.dispose();
    _grosir3Controller.dispose();

    _minBelanja1Controller.dispose();
    _minBelanja2Controller.dispose();
    _minBelanja3Controller.dispose();
    super.dispose();
  }

  Future<void> _onParentCategoryChanged(CategoryParentModel? parent) async {
    setState(() {
      _selectedParent = parent;
      _selectedJenis = null;
      _availableJenis = [];
    });

    if (parent != null) {
      setState(() => _isLoadingJenis = true);
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      await productProv.fetchJenisCategories(parent.id);
      setState(() {
        _availableJenis = productProv.categoryJenis;
        _isLoadingJenis = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJenis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Jenis Kategori terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      'sku': _skuController.text.trim(),
      'short_name': _shortNameController.text.trim(),
      'long_name': _longNameController.text.trim(),
      'id_kategori': _selectedJenis!.id, // id_kategori disi dari ID Jenis Kategori
      'id_type': _selectedType?.id,
      'merek': _merekController.text.trim().isNotEmpty ? _merekController.text.trim() : null,
      'satuan': _satuanController.text.trim(),
      'stok_awal': int.tryParse(_stokAwalController.text) ?? 0,
      'batas_stok': int.tryParse(_batasStokController.text) ?? 10,
      'harga_modal': double.tryParse(_hargaModalController.text) ?? 0,
      'harga_retail': double.tryParse(_hargaRetailController.text) ?? 0,
      'harga_reseller': double.tryParse(_hargaResellerController.text) ?? 0,
      'grosir_1': double.tryParse(_grosir1Controller.text) ?? 0,
      'grosir_2': double.tryParse(_grosir2Controller.text) ?? 0,
      'grosir_3': double.tryParse(_grosir3Controller.text) ?? 0,
      'min_belanja_1': int.tryParse(_minBelanja1Controller.text) ?? 0,
      'min_belanja_2': int.tryParse(_minBelanja2Controller.text) ?? 0,
      'min_belanja_3': int.tryParse(_minBelanja3Controller.text) ?? 0,
    };

    final productProv = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProv.createNewProduct(payload);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan ke API!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan produk ke API server')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tambah Produk Baru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 1: Dropdown Kategori
                    const Text('1. Pilih Kategori Utama *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<CategoryParentModel>(
                      value: _selectedParent,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '-- Pilih Kategori --',
                      ),
                      items: productProv.categoryParents.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (val) => _onParentCategoryChanged(val),
                      validator: (v) => v == null ? 'Wajib pilih Kategori' : null,
                    ),
                    const SizedBox(height: 14),

                    // Step 2: Dropdown Jenis (sub kategori)
                    const Text('2. Pilih Jenis Kategori *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _isLoadingJenis
                        ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                        : DropdownButtonFormField<CategoryJenisModel>(
                            value: _selectedJenis,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '-- Pilih Jenis --',
                            ),
                            items: _availableJenis.map((j) {
                              return DropdownMenuItem(
                                value: j,
                                child: Text(j.name),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedJenis = val),
                            validator: (v) => v == null ? 'Wajib pilih Jenis Kategori' : null,
                          ),
                    const SizedBox(height: 14),

                    // Step 3: Dropdown Tipe (optional)
                    const Text('3. Pilih Tipe Produk (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<TypeModel>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '-- Pilih Tipe (Opsional) --',
                      ),
                      items: productProv.types.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedType = val),
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Step 4: Detail Informasi Produk
                    const Text('Informasi Dasar Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _skuController,
                      maxLength: 50,
                      decoration: const InputDecoration(labelText: 'SKU (Kode Produk) *', border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? 'SKU wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _shortNameController,
                      maxLength: 50,
                      decoration: const InputDecoration(labelText: 'Nama Pendek (Short Name) *', border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? 'Nama pendek wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _longNameController,
                      maxLength: 150,
                      decoration: const InputDecoration(labelText: 'Nama Panjang (Long Name) *', border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? 'Nama panjang wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _merekController,
                            maxLength: 100,
                            decoration: const InputDecoration(labelText: 'Merek (Opsional)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _satuanController,
                            maxLength: 100,
                            decoration: const InputDecoration(labelText: 'Satuan (kg/Pack/pcs) *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Satuan wajib' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stokAwalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Stok Awal (Default 0)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _batasStokController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Batas Stok Minimal *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Harga & Grosir
                    const Text('Harga & Grosir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hargaModalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Harga Modal (Rp) *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _hargaRetailController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Harga Retail (Rp) *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _hargaResellerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga Reseller (Rp) *', border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? 'Harga reseller wajib' : null,
                    ),
                    const SizedBox(height: 14),

                    // Grosir 1, 2, 3
                    const Text('Tingkat Harga Grosir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _grosir1Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Grosir 1 (Rp) *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _minBelanja1Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Min Qty 1 *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _grosir2Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Grosir 2 (Rp) *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _minBelanja2Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Min Qty 2 *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _grosir3Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Grosir 3 (Rp) *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _minBelanja3Controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Min Qty 3 *', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Wajib' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Simpan Produk Baru',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
