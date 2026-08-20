import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';

class StrukPreviewDialog extends StatelessWidget {
  final String orderNumber;
  final DateTime createdAt;
  final String customerName;
  final String customerPhone;
  final String salesName;
  final List<Map<String, dynamic>> items;
  final String notes;
  final double subtotal;
  final double discount;
  final double totalAmount;
  final String paymentMethod;
  final double paidAmount;
  final double changeAmount;

  const StrukPreviewDialog({
    super.key,
    required this.orderNumber,
    required this.createdAt,
    required this.customerName,
    this.customerPhone = '0854-5236-0025',
    required this.salesName,
    required this.items,
    this.notes = '-',
    required this.subtotal,
    this.discount = 0,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paidAmount,
    required this.changeAmount,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = Formatters.date(createdAt);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Preview Cetak Struk',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Receipt Body (Simulating Thermal Paper)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header: Logo Circle + Store Details
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.store_rounded, color: Colors.grey, size: 36),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jaya Santoso Plastik',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Distributor Tas Plastik\nBeringin dan Mega',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. Transaction Metadata
                      Text(
                        dateFormatted,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(
                            width: 50,
                            child: Text('Nama', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          ),
                          const Text(': ', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          Text(customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 50,
                                child: Text('Tlp', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ),
                              const Text(': ', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              Text(customerPhone, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                          Text(
                            salesName,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Dashed Divider Line
                      const Text(
                        '------------------------------------------------',
                        maxLines: 1,
                        style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: -1),
                      ),
                      const SizedBox(height: 8),

                      // 3. Items List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final name = item['name']?.toString() ?? 'Nama Item';
                          final price = (item['price'] ?? 0).toDouble();
                          final qty = int.tryParse(item['qty']?.toString() ?? '1') ?? 1;
                          final unit = item['unit']?.toString() ?? 'pcs';
                          final sub = (item['subtotal'] ?? (price * qty)).toDouble();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${Formatters.number(price)}    X $qty   $unit   =',
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                  Text(
                                    Formatters.number(sub),
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),
                      // Dashed Divider Line
                      const Text(
                        '------------------------------------------------',
                        maxLines: 1,
                        style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: -1),
                      ),
                      const SizedBox(height: 10),

                      // 4. Summary & Payments
                      if (notes.isNotEmpty && notes != '-') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Catatan', style: TextStyle(fontSize: 12, color: Colors.black87)),
                            Text(notes, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sub Total', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          Text(Formatters.number(subtotal), style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diskon', style: TextStyle(fontSize: 12, color: Colors.black87)),
                            Text(Formatters.number(discount), style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            paymentMethod.toUpperCase(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          Text(
                            Formatters.number(totalAmount),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kembalian', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          Text(Formatters.number(changeAmount < 0 ? 0 : changeAmount), style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),

                      const SizedBox(height: 24),
                      // 5. Centered Footer
                      const Center(
                        child: Text(
                          'Terima Kasih',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1),
            // Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.print, color: Colors.white, size: 18),
                      label: const Text(
                        'Cetak Struk',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perintah cetak struk dikirim ke sistem printer.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
