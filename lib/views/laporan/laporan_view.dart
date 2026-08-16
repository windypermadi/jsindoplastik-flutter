import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../providers/kasbon_provider.dart';
import '../../providers/product_provider.dart';

class LaporanView extends StatelessWidget {
  const LaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final kasbonProv = Provider.of<KasbonProvider>(context);
    final productProv = Provider.of<ProductProvider>(context);

    final totalSales = orderProv.orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final totalOrders = orderProv.orders.length;
    final totalDebt = kasbonProv.totalActiveKasbon;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Laporan Penjualan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Total Revenue Header Banner
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppColors.primaryDark,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Omset Penjualan (Tercatat)',
                    style: TextStyle(color: AppColors.primaryLight, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.rupiah(totalSales),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text('$totalOrders Pesanan', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Summary Metrics Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sisa Piutang / Kasbon', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text(
                          Formatters.rupiah(totalDebt),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.warning),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Produk Aktif', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text(
                          '${productProv.allProducts.length} Item',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top Selling Plastic Products List
          const Text(
            'Produk Plastik Paling Laris',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productProv.allProducts.take(5).length,
            itemBuilder: (context, index) {
              final p = productProv.allProducts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Kategori: ${p.category}'),
                  trailing: Text(
                    Formatters.rupiah(p.sellPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
