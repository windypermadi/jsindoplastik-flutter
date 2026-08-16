import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../main/app_drawer.dart';

class DashboardView extends StatelessWidget {
  final ValueChanged<NavMenu> onNavigate;

  const DashboardView({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    final user = auth.currentUser;
    final isOwner = auth.isOwner;
    final userName = user?.name.split(' ').first ?? 'Christian';

    // Account Data Scoping Logic:
    // Owner = Data semua sales
    // Sales = Data khusus sales tersebut
    final filteredOrders = isOwner
        ? orderProv.orders
        : orderProv.orders.where((o) => o.cashierName.toLowerCase().contains(userName.toLowerCase())).toList();

    // Stats calculations based on account scope
    final pesananMasukCount = isOwner ? 102 : (filteredOrders.isNotEmpty ? filteredOrders.length : 48);
    final pesananTersimpanCount = isOwner ? 211 : 89;

    final lapPesananMasuk = isOwner ? 136 : (filteredOrders.isNotEmpty ? filteredOrders.length : 65);

    final lapPesananTersimpan = isOwner ? 425 : 180;
    final totalPemasukan = isOwner
        ? 1256000.0
        : filteredOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

    // Low stock items data
    final lowStockItems = [
      {'name': 'TAS Super LR', 'sub': 'Beringin | Super', 'qty': '1 Pack', 'isZero': false},
      {'name': 'TAS LS Kecil HT', 'sub': 'Losspack | Hitam', 'qty': '0 kg', 'isZero': true},
      {'name': 'TAS K015H', 'sub': 'Beringin | Kecil', 'qty': '0 Pack', 'isZero': true},
      {'name': 'TAS 1030 P', 'sub': 'Beringin | Kecil', 'qty': '2 Pack', 'isZero': false},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Greeting: Hi Christian ! \n Selamat Datang
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi $userName !',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOwner ? AppColors.ownerBadge : AppColors.salesBadge,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOwner ? 'DATA: SEMUA SALES' : 'DATA: SALES SAYA',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Top Row Cards: Green (Pesanan Masuk) & Sky Blue (Pesanan Tersimpan)
          Row(
            children: [
              // Green Card - Pesanan Masuk
              Expanded(
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Green/Emerald
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$pesananMasukCount',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fact_check_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Pesanan Masuk',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Sky Blue Card - Pesanan Tersimpan
              Expanded(
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8), // Light Sky Blue
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$pesananTersimpanCount',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.all_inbox_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Pesanan Tersimpan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 1: Laporan Penjualan Hari Ini
          const Text(
            'Laporan Penjualan Hari Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Two White Cards Grid: Pesanan Masuk & Pesanan Tersimpan
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF10B981)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.check_box_outlined,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Pesanan Masuk',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$lapPesananMasuk',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF38BDF8)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.all_inbox_outlined,
                              size: 14,
                              color: Color(0xFF38BDF8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Pesanan Tersimpan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$lapPesananTersimpan',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Total Pemasukan Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('💰', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 6),
                    Text(
                      'Total Pemasukan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp.${Formatters.number(totalPemasukan)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Laporan Stok Produk Menipis
          const Text(
            'Laporan Stok Produk Menipis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Low Stock List Container Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lowStockItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = lowStockItems[index];
                final isZero = item['isZero'] as bool;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF94A3B8),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    item['sub'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: Text(
                    item['qty'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isZero ? const Color(0xFFF87171) : AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
