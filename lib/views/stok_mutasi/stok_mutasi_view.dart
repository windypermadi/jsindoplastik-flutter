import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/stock_mutation_model.dart';
import '../../models/product_model.dart';
import '../../providers/stock_mutation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';

class StokMutasiView extends StatefulWidget {
  const StokMutasiView({super.key});

  @override
  State<StokMutasiView> createState() => _StokMutasiViewState();
}

class _StokMutasiViewState extends State<StokMutasiView> {
  void _openAddMutationDialog() {
    final productProv = Provider.of<ProductProvider>(context, listen: false);
    ProductModel? selectedProd = productProv.allProducts.isNotEmpty ? productProv.allProducts.first : null;
    MutationType type = MutationType.inbound;
    final qtyController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Catat Mutasi Stok Baru'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Produk:'),
                  DropdownButtonFormField<ProductModel>(
                    value: selectedProd,
                    items: productProv.allProducts.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.name));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() => selectedProd = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Jenis Mutasi:'),
                  Row(
                    children: [
                      Radio<MutationType>(
                        value: MutationType.inbound,
                        groupValue: type,
                        onChanged: (v) => setDialogState(() => type = v!),
                      ),
                      const Text('Stok Masuk (In)'),
                      Radio<MutationType>(
                        value: MutationType.outbound,
                        groupValue: type,
                        onChanged: (v) => setDialogState(() => type = v!),
                      ),
                      const Text('Stok Keluar (Out)'),
                    ],
                  ),
                  TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah Kuantitas'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Keterangan / Alasan (misal: Restok/Rusak)'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (!formKey.currentState!.validate() || selectedProd == null) return;
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final mutationProv = Provider.of<StockMutationProvider>(context, listen: false);

                final newItem = StockMutationModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  productId: selectedProd!.id,
                  productName: selectedProd!.name,
                  type: type,
                  quantity: int.parse(qtyController.text.trim()),
                  unit: selectedProd!.unit,
                  notes: notesController.text.trim(),
                  date: DateTime.now(),
                  userName: auth.currentUser?.name ?? 'Owner',
                );

                await mutationProv.addMutation(newItem);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mutasi stok berhasil dicatat')),
                  );
                }
              },
              child: const Text('Simpan Mutasi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mutationProv = Provider.of<StockMutationProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.swap_horiz, color: Colors.white),
        label: const Text('Catat Mutasi Stok', style: TextStyle(color: Colors.white)),
        onPressed: _openAddMutationDialog,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: mutationProv.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: mutationProv.mutations.length,
                itemBuilder: (context, index) {
                  final m = mutationProv.mutations[index];
                  final isInbound = m.type == MutationType.inbound;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isInbound ? AppColors.success : AppColors.danger).withOpacity(0.15),
                        child: Icon(
                          isInbound ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isInbound ? AppColors.success : AppColors.danger,
                        ),
                      ),
                      title: Text(m.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${m.notes}\nOleh: ${m.userName} • ${Formatters.dateTime(m.date)}'),
                      isThreeLine: true,
                      trailing: Text(
                        '${isInbound ? "+" : "-"}${m.quantity} ${m.unit}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isInbound ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
