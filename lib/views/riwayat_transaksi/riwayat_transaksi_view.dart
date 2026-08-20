import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/riwayat_transaksi_model.dart';
import '../../providers/riwayat_transaksi_provider.dart';
import '../transaksi/struk_preview_dialog.dart';

class RiwayatTransaksiView extends StatefulWidget {
  const RiwayatTransaksiView({super.key});

  @override
  State<RiwayatTransaksiView> createState() => _RiwayatTransaksiViewState();
}

class _RiwayatTransaksiViewState extends State<RiwayatTransaksiView> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 14));
  DateTime _endDate = DateTime.now();

  void _openDateFilterDialog(BuildContext context, RiwayatTransaksiProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Filter Tanggal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Awal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMMM yyyy', 'id_ID').format(_startDate),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Akhir', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMMM yyyy', 'id_ID').format(_endDate),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              prov.setDateRange(_startDate, _endDate);
              Navigator.pop(ctx);
            },
            child: const Text('Terapkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openDetailModal(BuildContext context, RiwayatTransaksiItemModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 1. Header Bar: < Detail Transaksi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

              // Body Scroll View
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card 1: Pelanggan
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.people_alt_outlined, color: Color(0xFF29B6F6), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Pelanggan',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('Nama', tx.customerName),
                            const SizedBox(height: 6),
                            _buildDetailRow('Status Pelanggan', tx.customerType),
                            const SizedBox(height: 6),
                            _buildDetailRow('Sales', tx.salesName),
                            const SizedBox(height: 6),
                            _buildDetailRow('Tanggal Transaksi', tx.date),
                          ],
                        ),
                      ),
                      Container(height: 8, color: const Color(0xFFF8FAFC)),

                      // Card 2: List Order
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.assignment_outlined, color: Color(0xFF29B6F6), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'List Order',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Total : ${tx.totalProductCount} Produk',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            if (tx.items.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('Standard Item Package', style: TextStyle(color: AppColors.textSecondary)),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tx.items.length,
                                separatorBuilder: (context, index) => const Divider(height: 16, thickness: 0.5, color: Color(0xFFEEEEEE)),
                                itemBuilder: (context, index) {
                                  final item = tx.items[index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${item.code} ${item.name}',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                          Text(
                                            '${item.qty}X',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.parentCategory} | ${item.childCategory}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Harga : ${Formatters.rupiah(item.unitPrice)}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          Text(
                                            Formatters.rupiah(item.subtotal),
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      Container(height: 8, color: const Color(0xFFF8FAFC)),

                      // Card 3: Rincian Pembayaran
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.receipt_long_outlined, color: Color(0xFF29B6F6), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Rincian Pembayaran',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                Text(Formatters.rupiah(tx.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Diskon', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                Text(Formatters.rupiah(tx.totalDiscount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(height: 8, color: const Color(0xFFF8FAFC)),

                      // Section 4: Total Pembayaran
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('💰', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  'Total Pembayaran',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                Formatters.rupiah(tx.totalAmount),
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Center(
                              child: Text(
                                tx.paymentMethod,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                                label: const Text('Preview Struk Cetak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  showDialog(
                                    context: context,
                                    builder: (c) => StrukPreviewDialog(
                                      orderNumber: tx.id,
                                      createdAt: DateTime.now(),
                                      customerName: tx.customerName,
                                      customerPhone: '0854-5236-0025',
                                      salesName: tx.salesName,
                                      items: tx.items
                                          .map((i) => {
                                                'name': i.name,
                                                'qty': i.qty,
                                                'price': i.unitPrice,
                                                'unit': i.unit,
                                                'subtotal': i.subtotal,
                                              })
                                          .toList(),
                                      subtotal: tx.subtotal,
                                      discount: tx.totalDiscount,
                                      totalAmount: tx.totalAmount,
                                      paymentMethod: tx.paymentMethod,
                                      paidAmount: tx.totalAmount,
                                      changeAmount: 0,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
        const Text(': ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<RiwayatTransaksiProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // Top Bar: Search Input & Calendar Filter Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      onChanged: (val) => prov.setSearchQuery(val),
                      decoration: const InputDecoration(
                        hintText: 'Cari',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _openDateFilterDialog(context, prov),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.calendar_month_outlined, color: AppColors.textPrimary, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Grouped Transactions List
            Expanded(
              child: prov.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : prov.groups.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada riwayat transaksi.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: prov.groups.length,
                          itemBuilder: (context, groupIndex) {
                            final group = prov.groups[groupIndex];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Group Date Header Row
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            group.dateDay,
                                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                          const SizedBox(width: 6),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                group.dateMonthYear,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              ),
                                              Text(
                                                group.dayOfWeek,
                                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        Formatters.rupiah(group.dailyTotal),
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF29B6F6)),
                                      ),
                                    ],
                                  ),
                                ),

                                // Transaction Item List in Group
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: group.transactions.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, color: Color(0xFFF1F5F9)),
                                  itemBuilder: (context, txIndex) {
                                    final tx = group.transactions[txIndex];

                                    return InkWell(
                                      onTap: () => _openDetailModal(context, tx),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.person, color: Color(0xFF29B6F6), size: 20),
                                                const SizedBox(width: 10),
                                                Text(
                                                  tx.customerName,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              Formatters.rupiah(tx.totalAmount),
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
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
