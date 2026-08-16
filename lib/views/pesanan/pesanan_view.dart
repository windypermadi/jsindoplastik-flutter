import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class PesananView extends StatelessWidget {
  const PesananView({super.key});

  void _showOrderDetail(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Chip(
                  label: Text(order.status),
                  backgroundColor: AppColors.success.withOpacity(0.15),
                  labelStyle: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tanggal: ${Formatters.dateTime(order.createdAt)}'),
            Text('Pelanggan: ${order.customerName}'),
            Text('Metode Pembayaran: ${order.paymentMethod.label}'),
            Text('Kasir: ${order.cashierName}'),
            const Divider(height: 24),

            const Text('Daftar Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (order.items.isEmpty)
              const Text('Produk pesanan standar (1x Paket Plastik)')
            else
              ...order.items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${i.quantity}x ${i.product.name}'),
                        Text(Formatters.rupiah(i.subtotal)),
                      ],
                    ),
                  )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  Formatters.rupiah(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
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
        children: [
          TextField(
            onChanged: (val) => orderProv.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Cari nomor pesanan atau pelanggan...',
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
            child: orderProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: orderProv.orders.length,
                    itemBuilder: (context, index) {
                      final o = orderProv.orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => _showOrderDetail(context, o),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(Icons.receipt, color: AppColors.primary),
                          ),
                          title: Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${o.customerName} • ${Formatters.date(o.createdAt)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.rupiah(o.totalAmount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                o.paymentMethod.label,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
