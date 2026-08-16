import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../models/customer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart';

class TransaksiPosView extends StatefulWidget {
  const TransaksiPosView({super.key});

  @override
  State<TransaksiPosView> createState() => _TransaksiPosViewState();
}

class _TransaksiPosViewState extends State<TransaksiPosView> {
  void _openCheckoutSheet(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final custProv = Provider.of<CustomerProvider>(context, listen: false);
    final paidController = TextEditingController(
      text: cart.totalAmount.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isKasbon = cart.paymentMethod == PaymentMethod.kasbon;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pembayaran Kasir POS',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),

                    // Customer Selector Dropdown
                    const Text('Pilih Pelanggan:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<CustomerModel?>(
                      value: cart.selectedCustomer,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem<CustomerModel?>(
                          value: null,
                          child: Text('Pelanggan Umum (Tanpa Nama)'),
                        ),
                        ...custProv.customers.map((c) {
                          return DropdownMenuItem<CustomerModel?>(
                            value: c,
                            child: Text('${c.name} (${c.phone})'),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          cart.setCustomer(val);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Payment Method Options
                    const Text('Metode Pembayaran:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: PaymentMethod.values.map((method) {
                        final isSelected = cart.paymentMethod == method;
                        return ChoiceChip(
                          label: Text(method.label),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              cart.setPaymentMethod(method);
                              if (method == PaymentMethod.kasbon) {
                                paidController.text = '0';
                              } else {
                                paidController.text = cart.totalAmount.toStringAsFixed(0);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Total & Paid Inputs
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL HARGA:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            Formatters.rupiah(cart.totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (!isKasbon) ...[
                      TextFormField(
                        controller: paidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Uang Diterima (Rp)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            cart.setPaidAmount(double.tryParse(val) ?? 0);
                          });
                        },
                        validator: (v) {
                          if (isKasbon) return null;
                          final paid = double.tryParse(v ?? '') ?? 0;
                          if (paid < cart.totalAmount) {
                            return 'Nominal kurang dari total tagihan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kembalian:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            Formatters.rupiah(cart.changeAmount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.warning),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Transaksi akan dicatat sebagai Kasbon / Piutang pada pelanggan terpilih.',
                                style: TextStyle(fontSize: 12, color: AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          if (isKasbon && cart.selectedCustomer == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih pelanggan terlebih dahulu untuk transaksi Kasbon!')),
                            );
                            return;
                          }

                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          final orderProv = Provider.of<OrderProvider>(context, listen: false);

                          final paidVal = isKasbon ? 0.0 : (double.tryParse(paidController.text) ?? cart.totalAmount);
                          final newOrder = OrderModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            orderNumber: 'INV-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().second.toString().padLeft(3, '0')}',
                            createdAt: DateTime.now(),
                            customerId: cart.selectedCustomer?.id,
                            customerName: cart.selectedCustomer?.name ?? 'Pelanggan Umum',
                            items: List.from(cart.items),
                            totalAmount: cart.totalAmount,
                            paidAmount: paidVal,
                            changeAmount: isKasbon ? 0 : paidVal - cart.totalAmount,
                            paymentMethod: cart.paymentMethod,
                            cashierName: auth.currentUser?.name ?? 'Sales',
                          );

                          await orderProv.createOrder(newOrder);

                          if (context.mounted) {
                            Navigator.pop(ctx);
                            _showReceiptDialog(context, newOrder);
                            cart.clearCart();
                          }
                        },
                        child: const Text(
                          'PROSES STRUK & SELESAI',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Text('Struk Pembayaran', style: TextStyle(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 50),
            const SizedBox(height: 8),
            const Text('JSINDOPLASTIK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Toko Plastik & Kemasan Terlengkap', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('No: ${order.orderNumber}', style: const TextStyle(fontSize: 12)),
                Text(Formatters.date(order.createdAt), style: const TextStyle(fontSize: 12)),
              ],
            ),
            Text('Pelanggan: ${order.customerName}', style: const TextStyle(fontSize: 12)),
            Text('Kasir: ${order.cashierName}', style: const TextStyle(fontSize: 12)),
            const Divider(),
            ...order.items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${i.quantity}x ${i.product.name}', style: const TextStyle(fontSize: 12)),
                      Text(Formatters.rupiah(i.subtotal), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(Formatters.rupiah(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bayar (${order.paymentMethod.label})', style: const TextStyle(fontSize: 12)),
                Text(Formatters.rupiah(order.paidAmount), style: const TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kembali', style: TextStyle(fontSize: 12)),
                Text(Formatters.rupiah(order.changeAmount), style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Cetak Struk'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mencetak struk ke printer thermal...')),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 750;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Catalog Column
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => productProv.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Cari plastik/kemasan...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 3 : 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: productProv.products.length,
                        itemBuilder: (context, index) {
                          final p = productProv.products[index];

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => cart.addToCart(p),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Formatters.rupiah(p.sellPrice),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'Stok: ${p.stock} ${p.unit}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cart Summary Panel Column
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Keranjang Kasir',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (cart.items.isNotEmpty)
                          TextButton(
                            onPressed: () => cart.clearCart(),
                            child: const Text('Kosongkan', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                          ),
                      ],
                    ),
                    const Divider(),

                    // Cart Items List
                    Expanded(
                      child: cart.items.isEmpty
                          ? const Center(
                              child: Text(
                                'Keranjang masih kosong.\nPilih produk di sebelah kiri.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) {
                                final item = cart.items[index];
                                return Card(
                                  elevation: 1,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                              Text(Formatters.rupiah(item.price), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.danger),
                                              onPressed: () => cart.updateQuantity(item.product.id, item.quantity - 1),
                                            ),
                                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                                              onPressed: () => cart.updateQuantity(item.product.id, item.quantity + 1),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran:'),
                        Text(
                          Formatters.rupiah(cart.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: cart.items.isEmpty ? null : () => _openCheckoutSheet(context),
                        child: const Text('BAYAR SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
