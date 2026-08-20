import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/saved_transaction_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';

class PesananView extends StatelessWidget {
  const PesananView({super.key});

  void _showSavedTransactionDetail(BuildContext context, SavedTransactionModel item) {
    final orderProv = Provider.of<OrderProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<SavedTransactionDetailModel?>(
          future: orderProv.fetchSavedTransactionDetail(item.cartId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final detail = snapshot.data;
            final customerName = detail?.customerName ?? item.customer.name;
            final customerType = detail?.customerType ?? item.customer.type;
            final salesName = detail?.salesName ?? item.user.name;
            final dateStr = detail?.date ?? item.date;
            final itemsList = detail?.items ?? [];
            final totalAmount = detail?.afterDisc ?? item.total;
            final subtotalAmount = detail?.beforeDisc ?? item.subtotal;
            final discountVal = detail?.discount ?? item.disc.discount;
            final hasDisc = detail?.discStatus ?? item.disc.status;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID Cart: ${item.cartId.length > 12 ? item.cartId.substring(0, 12) : item.cartId}...',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: customerType == 'VIP' ? AppColors.warning : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        customerType,
                        style: TextStyle(
                          color: customerType == 'VIP' ? Colors.white : AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Tanggal: $dateStr', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('Pelanggan: $customerName ($customerType)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('Sales / Operator: $salesName', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Divider(height: 20),

                const Text('Daftar Barang dalam Keranjang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),

                Expanded(
                  child: itemsList.isEmpty
                      ? const Center(child: Text('Tidak ada rincian item', style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.separated(
                          itemCount: itemsList.length,
                          separatorBuilder: (context, index) => const Divider(height: 12, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final i = itemsList[index];
                            return Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(i.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                      Text(
                                        '${i.qty}x ${Formatters.rupiah(i.price)} • ${i.parentCategory} | ${i.childCategory}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  Formatters.rupiah(i.subtotal),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(Formatters.rupiah(subtotalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                if (hasDisc) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Diskon', style: TextStyle(color: AppColors.danger, fontSize: 13)),
                      Text(
                        '- ${Formatters.rupiah(double.tryParse(discountVal) ?? 0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      Formatters.rupiah(totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () {
                          final cartProv = Provider.of<CartProvider>(context, listen: false);
                          cartProv.setActiveCartId(item.cartId);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Keranjang ${item.cartId.substring(0, 8)} berhasil dimuat ke POS'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        child: const Text('Muat Ke POS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Refresh Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => orderProv.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Cari ID keranjang / pelanggan...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                tooltip: 'Muat Ulang Transaksi Tersimpan',
                onPressed: () => orderProv.fetchSavedTransactions(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Daftar Transaksi Tersimpan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: orderProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderProv.savedTransactions.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada transaksi tersimpan ditemukan.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orderProv.savedTransactions.length,
                        itemBuilder: (context, index) {
                          final item = orderProv.savedTransactions[index];
                          final isVip = item.customer.type == 'VIP';

                          return Card(
                            elevation: 1.5,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              onTap: () => _showSavedTransactionDetail(context, item),
                              leading: CircleAvatar(
                                backgroundColor: isVip
                                    ? AppColors.warning.withValues(alpha: 0.2)
                                    : AppColors.primaryLight,
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: isVip ? AppColors.warning : AppColors.primary,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'ID: ${item.cartId.length > 8 ? item.cartId.substring(0, 8) : item.cartId}...',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isVip ? AppColors.warning : AppColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.customer.type,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isVip ? Colors.white : AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pelanggan: ${item.customer.name} • Kasir: ${item.user.name}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    item.date,
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.rupiah(item.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  if (item.disc.status)
                                    Text(
                                      'Diskon: ${Formatters.rupiah(double.tryParse(item.disc.discount) ?? 0)}',
                                      style: const TextStyle(fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.w500),
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
