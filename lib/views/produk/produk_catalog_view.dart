import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/category_model.dart';
import '../../providers/product_provider.dart';

class ProdukCatalogView extends StatefulWidget {
  const ProdukCatalogView({super.key});

  @override
  State<ProdukCatalogView> createState() => _ProdukCatalogViewState();
}

class _ProdukCatalogViewState extends State<ProdukCatalogView> {
  final ScrollController _categoryParentsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _categoryParentsScrollController.addListener(_onCategoryParentsScroll);
  }

  @override
  void dispose() {
    _categoryParentsScrollController.removeListener(_onCategoryParentsScroll);
    _categoryParentsScrollController.dispose();
    super.dispose();
  }

  // Infinite Scroll Auto-Load Next Page for Category Parent
  void _onCategoryParentsScroll() {
    if (_categoryParentsScrollController.position.pixels >=
        _categoryParentsScrollController.position.maxScrollExtent - 50) {
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      if (productProv.hasMoreParents && !productProv.isLoadingMoreParents) {
        productProv.fetchParentCategories(refresh: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => productProv.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari produk plastik...',
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
                  tooltip: 'Muat Ulang',
                  onPressed: () => productProv.initCatalogData(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. Level 1: Kategori (Parent) - Infinite Scroll Auto-Load
            const Text(
              '1. Kategori Produk',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
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

                  // Loading indicator chip at bottom of scroll
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
            const SizedBox(height: 10),

            // 2. Level 2: Jenis (Sub Category)
            if (productProv.categoryJenis.isNotEmpty) ...[
              const Text(
                '2. Jenis Sub-Kategori',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
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
              const SizedBox(height: 10),
            ],

            // 3. Level 3: Tipe (Type)
            if (productProv.types.isNotEmpty) ...[
              const Text(
                '3. Tipe Produk',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
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
              const SizedBox(height: 12),
            ],

            // 4. Level 4: Product Grid List
            Expanded(
              child: productProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productProv.products.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada produk ditemukan untuk filter terpilih.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: productProv.products.length,
                          itemBuilder: (context, index) {
                            final p = productProv.products[index];
                            final isLowStock = p.stock <= 15;

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
                                  child: (p.imageUrl != null && p.imageUrl!.startsWith('http'))
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            p.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.inventory_2_outlined,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.inventory_2_outlined,
                                          color: AppColors.primary,
                                        ),
                                ),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  p.longName != null && p.longName!.isNotEmpty
                                      ? '${p.longName}'
                                      : 'SKU: ${p.code}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Formatters.rupiah(p.sellPrice),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isLowStock
                                            ? AppColors.danger.withOpacity(0.15)
                                            : AppColors.success.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Stok: ${p.stock} ${p.unit}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isLowStock ? AppColors.danger : AppColors.success,
                                        ),
                                      ),
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
