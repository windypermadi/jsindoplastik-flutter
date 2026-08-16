import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/kasbon_model.dart';
import '../../providers/kasbon_provider.dart';

class KasbonView extends StatelessWidget {
  const KasbonView({super.key});

  void _openPayKasbonDialog(BuildContext context, KasbonModel kasbon) {
    final payController = TextEditingController(text: kasbon.remainingDebt.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pembayaran Kasbon / Piutang'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pelanggan: ${kasbon.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('No. Transaksi: ${kasbon.orderNumber}'),
              Text('Sisa Kasbon: ${Formatters.rupiah(kasbon.remainingDebt)}', style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 12),
              TextFormField(
                controller: payController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Pembayaran (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) return 'Nominal tidak valid';
                  if (val > kasbon.remainingDebt) return 'Melebihi sisa kasbon';
                  return null;
                },
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
              final amount = double.parse(payController.text.trim());
              final kasbonProv = Provider.of<KasbonProvider>(context, listen: false);

              await kasbonProv.payKasbon(kasbon.id, amount);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembayaran kasbon berhasil dicatat')),
                );
              }
            },
            child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kasbonProv = Provider.of<KasbonProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Active Debt Header Banner
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.warning.withOpacity(0.12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Piutang / Kasbon Pelanggan',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        Formatters.rupiah(kasbonProv.totalActiveKasbon),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            onChanged: (val) => kasbonProv.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Cari pelanggan atau no transaksi kasbon...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Status Chips
          Row(
            children: ['Semua', 'Belum Lunas', 'Sebagian', 'Lunas'].map((status) {
              final isSelected = kasbonProv.filterStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: AppColors.primaryLight,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => kasbonProv.setFilterStatus(status),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Kasbon Items List
          Expanded(
            child: kasbonProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: kasbonProv.kasbonList.length,
                    itemBuilder: (context, index) {
                      final k = kasbonProv.kasbonList[index];
                      final isLunas = k.status == 'Lunas';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(k.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${k.orderNumber} • ${Formatters.date(k.date)}\nTotal: ${Formatters.rupiah(k.totalDebt)} | Paid: ${Formatters.rupiah(k.paidAmount)}',
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.rupiah(k.remainingDebt),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isLunas ? AppColors.success : AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (!isLunas)
                                SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    onPressed: () => _openPayKasbonDialog(context, k),
                                    child: const Text('Bayar', style: TextStyle(fontSize: 11, color: Colors.white)),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'LUNAS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
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
    );
  }
}
