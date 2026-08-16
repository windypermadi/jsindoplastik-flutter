import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

class KelolaProdukView extends StatefulWidget {
  const KelolaProdukView({super.key});

  @override
  State<KelolaProdukView> createState() => _KelolaProdukViewState();
}

class _KelolaProdukViewState extends State<KelolaProdukView> {
  void _openProductFormDialog([ProductModel? product]) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final codeController = TextEditingController(text: product?.code ?? '');
    final categoryController = TextEditingController(text: product?.category ?? 'Kantong Plastik');
    final buyPriceController = TextEditingController(text: product != null ? product.buyPrice.toStringAsFixed(0) : '');
    final sellPriceController = TextEditingController(text: product != null ? product.sellPrice.toStringAsFixed(0) : '');
    final stockController = TextEditingController(text: product != null ? product.stock.toString() : '');
    final unitController = TextEditingController(text: product?.unit ?? 'Pack');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk Baru' : 'Edit Produk'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Kode Produk (SKU)'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk Plastik'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: buyPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Harga Beli (Rp)'),
                        validator: (v) => v!.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: sellPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Harga Jual (Rp)'),
                        validator: (v) => v!.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Jumlah Stok'),
                        validator: (v) => v!.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: 'Satuan (Pack/Bal/Roll)'),
                        validator: (v) => v!.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final productProv = Provider.of<ProductProvider>(context, listen: false);

              final newProduct = ProductModel(
                id: product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                code: codeController.text.trim(),
                name: nameController.text.trim(),
                category: categoryController.text.trim(),
                buyPrice: double.tryParse(buyPriceController.text) ?? 0,
                sellPrice: double.tryParse(sellPriceController.text) ?? 0,
                stock: int.tryParse(stockController.text) ?? 0,
                unit: unitController.text.trim(),
              );

              if (product == null) {
                await productProv.addProduct(newProduct);
              } else {
                await productProv.updateProduct(newProduct);
              }

              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Produk berhasil ${product == null ? 'ditambahkan' : 'diperbarui'}')),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
        onPressed: () => _openProductFormDialog(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              onChanged: (val) => productProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari produk untuk dikelola...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Products Table List
            Expanded(
              child: productProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: productProv.products.length,
                      itemBuilder: (context, index) {
                        final p = productProv.products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('SKU: ${p.code} | Beli: ${Formatters.rupiah(p.buyPrice)} | Jual: ${Formatters.rupiah(p.sellPrice)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text('${p.stock} ${p.unit}'),
                                  backgroundColor: AppColors.primaryLight,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.accent),
                                  onPressed: () => _openProductFormDialog(p),
                                ),
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
