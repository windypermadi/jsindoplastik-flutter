import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';

class PelangganView extends StatefulWidget {
  const PelangganView({super.key});

  @override
  State<PelangganView> createState() => _PelangganViewState();
}

class _PelangganViewState extends State<PelangganView> {
  void _openAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Pelanggan Baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan / Toko'),
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                validator: (v) => v!.isEmpty ? 'Nomor telepon wajib diisi' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Alamat / Lokasi'),
                validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final custProv = Provider.of<CustomerProvider>(context, listen: false);

              final newCust = CustomerModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                address: addressController.text.trim(),
              );

              await custProv.addCustomer(newCust);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pelanggan baru berhasil ditambahkan')),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final custProv = Provider.of<CustomerProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Tambah Pelanggan', style: TextStyle(color: Colors.white)),
        onPressed: _openAddCustomerDialog,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (val) => custProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari pelanggan atau nomor HP...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: custProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: custProv.customers.length,
                      itemBuilder: (context, index) {
                        final c = custProv.customers[index];
                        final hasDebt = c.debtBalance > 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.accent.withOpacity(0.15),
                              child: const Icon(Icons.person, color: AppColors.accent),
                            ),
                            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${c.phone}\n${c.address}'),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Kasbon:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text(
                                  Formatters.rupiah(c.debtBalance),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: hasDebt ? AppColors.danger : AppColors.success,
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
