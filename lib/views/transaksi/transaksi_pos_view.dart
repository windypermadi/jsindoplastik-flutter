import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../models/customer_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart';
import 'struk_preview_dialog.dart';

class TransaksiPosView extends StatefulWidget {
  const TransaksiPosView({super.key});

  @override
  State<TransaksiPosView> createState() => _TransaksiPosViewState();
}

class _TransaksiPosViewState extends State<TransaksiPosView> {
  void _openDiscountModal(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    String selectedMode = 'none';
    if (cart.activeCartDetail?.discountValue != null && cart.activeCartDetail!.discountValue > 0) {
      selectedMode = 'rupiah';
    } else if (cart.discountAmount > 0) {
      selectedMode = 'rupiah';
    }

    final controller = TextEditingController(
      text: cart.discountAmount > 0 ? cart.discountAmount.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.local_offer_outlined, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Atur Diskon Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Jenis Diskon:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),

                  RadioListTile<String>(
                    title: const Text('Tanpa Diskon (Default)', style: TextStyle(fontSize: 13)),
                    value: 'none',
                    groupValue: selectedMode,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) {
                      setModalState(() {
                        selectedMode = val!;
                        controller.clear();
                      });
                    },
                  ),

                  RadioListTile<String>(
                    title: const Text('Diskon Rupiah (Rp)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: 'rupiah',
                    groupValue: selectedMode,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) {
                      setModalState(() {
                        selectedMode = val!;
                      });
                    },
                  ),

                  RadioListTile<String>(
                    title: const Text('Diskon Persen (%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: 'percent',
                    groupValue: selectedMode,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) {
                      setModalState(() {
                        selectedMode = val!;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  if (selectedMode == 'rupiah' || selectedMode == 'percent') ...[
                    TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: selectedMode == 'percent' ? 'Inputkan Persentase (%)' : 'Inputkan Nominal (Rp)',
                        hintText: selectedMode == 'percent' ? 'Misal: 10' : 'Misal: 5000',
                        border: const OutlineInputBorder(),
                        prefixText: selectedMode == 'rupiah' ? 'Rp ' : null,
                        suffixText: selectedMode == 'percent' ? '%' : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () async {
                  bool? isPercent;
                  double val = 0.0;

                  if (selectedMode == 'none') {
                    isPercent = null;
                    val = 0.0;
                  } else if (selectedMode == 'rupiah') {
                    isPercent = false;
                    val = double.tryParse(controller.text.trim()) ?? 0.0;
                  } else if (selectedMode == 'percent') {
                    isPercent = true;
                    val = double.tryParse(controller.text.trim()) ?? 0.0;
                  }

                  Navigator.pop(ctx);
                  await cart.updateCartDiscountApi(isPercent: isPercent, value: val);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Diskon keranjang berhasil diperbarui')),
                    );
                  }
                },
                child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openCustomerPickerModal(BuildContext context) {
    final custProv = Provider.of<CustomerProvider>(context, listen: false);
    custProv.fetchCustomers(isRefresh: true);
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            final custProvider = Provider.of<CustomerProvider>(context);
            final cartProv = Provider.of<CartProvider>(context);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_search_rounded, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Pilih Pelanggan (API)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari Nama Pelanggan / No. Telp...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                custProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onSubmitted: (val) => custProvider.setSearchQuery(val.trim()),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: custProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : custProvider.customers.isEmpty
                            ? const Center(
                                child: Text('Pelanggan tidak ditemukan', style: TextStyle(color: AppColors.textSecondary)),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: custProvider.customers.length + 1,
                                itemBuilder: (context, idx) {
                                  if (idx == 0) {
                                    final isSelected = cartProv.selectedCustomer == null;
                                    return Card(
                                      elevation: isSelected ? 2 : 1,
                                      color: isSelected ? AppColors.primaryLight : Colors.white,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isSelected ? AppColors.primary : AppColors.background,
                                          child: Icon(Icons.person_outline, color: isSelected ? Colors.white : AppColors.primary),
                                        ),
                                        title: const Text('Pelanggan Umum (Tanpa Nama)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        subtitle: const Text('Tipe: Umum / Standar', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        trailing: isSelected
                                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                                            : OutlinedButton(
                                                onPressed: () {
                                                  cartProv.assignCustomerToCartApi(null);
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text('Pilih', style: TextStyle(fontSize: 12)),
                                              ),
                                      ),
                                    );
                                  }

                                  final c = custProvider.customers[idx - 1];
                                  final isSelected = cartProv.selectedCustomer?.id == c.id;
                                  final isVip = c.typeName?.toUpperCase() == 'VIP' || c.tipeCustomer == 1;

                                  return Card(
                                    elevation: isSelected ? 2 : 1,
                                    color: isSelected ? AppColors.primaryLight : Colors.white,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primary : AppColors.border,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isVip ? AppColors.warning.withValues(alpha: 0.2) : AppColors.primaryLight,
                                        child: Text(
                                          c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isVip ? AppColors.warning : AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.name,
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
                                              c.typeName ?? 'Retail',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isVip ? Colors.white : AppColors.primaryDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        'Telp: ${c.phone}${c.namaToko != null ? " • ${c.namaToko}" : ""}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              onPressed: () async {
                                                await cartProv.assignCustomerToCartApi(c);
                                                if (context.mounted) {
                                                  Navigator.pop(ctx);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Pelanggan ${c.name} (${c.typeName}) dipilih')),
                                                  );
                                                }
                                              },
                                              child: const Text('Pilih', style: TextStyle(color: Colors.white, fontSize: 12)),
                                            ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openSavedCartsModal(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.fetchCartList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            final cartProv = Provider.of<CartProvider>(context);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Daftar Keranjang Tersimpan (API)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 6),

                  Expanded(
                    child: cartProv.savedCarts.isEmpty
                        ? const Center(
                            child: Text('Belum ada keranjang tersimpan', style: TextStyle(color: AppColors.textSecondary)),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: cartProv.savedCarts.length,
                            itemBuilder: (context, idx) {
                              final c = cartProv.savedCarts[idx];
                              final isSelected = cartProv.activeCartId == c.id;

                              return Card(
                                elevation: isSelected ? 3 : 1,
                                color: isSelected ? AppColors.primaryLight : Colors.white,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected ? AppColors.primary : AppColors.background,
                                    child: Icon(Icons.shopping_cart, color: isSelected ? Colors.white : AppColors.primary),
                                  ),
                                  title: Text(
                                    c.custName != null ? '${c.custName} (${c.custType ?? "Pelanggan"})' : 'Keranjang ID: ${c.id.substring(0, 8)}...',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  subtitle: Text(
                                    'Kasir: ${c.userName ?? "Staff"} • Qty: ${c.qty} Item\n${c.createdAt ?? ""}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  isThreeLine: true,
                                  trailing: isSelected
                                      ? const Chip(
                                          label: Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          backgroundColor: AppColors.primary,
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          onPressed: () async {
                                            cartProv.setActiveCartId(c.id);
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Keranjang ${c.id.substring(0, 8)} dimuat dari server')),
                                            );
                                          },
                                          child: const Text('Pilih', style: TextStyle(color: Colors.white, fontSize: 12)),
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openMobileCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            final cart = Provider.of<CartProvider>(context);

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildCartPanel(context, cart, isMobileModal: true),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCheckoutSheet(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    String transactionType = 'cash';
    String paymentType = 'cash';

    final acquirerController = TextEditingController(text: 'debit');
    final notesController = TextEditingController();
    final dueDateController = TextEditingController(
      text: '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}',
    );
    final downPaymentController = TextEditingController(text: '0');
    final paymentAmountController = TextEditingController(
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
          final isInstallment = transactionType == 'installment';
          final isTransfer = paymentType == 'transfer';

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
                          'Checkout & Pembayaran (API)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pelanggan: ${cart.selectedCustomer?.name ?? "Pelanggan Umum"} (${cart.selectedCustomer?.typeName ?? "Retail"})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Jenis Transaksi (transaction_type):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Lunas (Cash)'),
                          selected: transactionType == 'cash',
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: transactionType == 'cash' ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) {
                            setModalState(() {
                              transactionType = 'cash';
                              paymentAmountController.text = cart.totalAmount.toStringAsFixed(0);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Kasbon / Tempo (Installment)'),
                          selected: transactionType == 'installment',
                          selectedColor: AppColors.warning,
                          labelStyle: TextStyle(color: transactionType == 'installment' ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) {
                            setModalState(() {
                              transactionType = 'installment';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text('Metode Pembayaran (payment_type):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Tunai (Cash)'),
                          selected: paymentType == 'cash',
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: paymentType == 'cash' ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) {
                            setModalState(() {
                              paymentType = 'cash';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Transfer Bank / E-Wallet'),
                          selected: paymentType == 'transfer',
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: paymentType == 'transfer' ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) {
                            setModalState(() {
                              paymentType = 'transfer';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (isTransfer) ...[
                      DropdownButtonFormField<String>(
                        initialValue: acquirerController.text.isNotEmpty ? acquirerController.text : 'debit',
                        decoration: const InputDecoration(
                          labelText: 'Metode E-Wallet / Transfer (acquirer)',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'debit', child: Text('debit')),
                          DropdownMenuItem(value: 'transfer', child: Text('transfer')),
                          DropdownMenuItem(value: 'qr', child: Text('qr')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              acquirerController.text = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (isInstallment) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: dueDateController,
                              decoration: const InputDecoration(
                                labelText: 'Jatuh Tempo (due_date d-m-Y)',
                                hintText: '18-08-2024',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (isInstallment && (v == null || v.trim().isEmpty)) {
                                  return 'Harap isi jatuh tempo!';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: downPaymentController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Uang Muka (down_payment)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (isInstallment) {
                                  final dp = double.tryParse(v ?? '') ?? 0;
                                  if (dp < 1) return 'DP min 1';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextFormField(
                      controller: paymentAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Uang Diterima / Nominal Bayar (payment_amount)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final amt = double.tryParse(v ?? '') ?? 0;
                        if (amt <= 0) return 'Harap masukan nominal bayar!';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: notesController,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Transaksi (notes - opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL TAGIHAN:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            Formatters.rupiah(cart.totalAmount),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          if (isInstallment && cart.selectedCustomer == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Harap pilih pelanggan terlebih dahulu untuk transaksi Kasbon/Installment!')),
                            );
                            return;
                          }

                          final orderProv = Provider.of<OrderProvider>(context, listen: false);
                          final auth = Provider.of<AuthProvider>(context, listen: false);

                          final pAmt = double.tryParse(paymentAmountController.text.trim()) ?? cart.totalAmount;
                          final dpVal = isInstallment ? double.tryParse(downPaymentController.text.trim()) : null;

                          final response = await orderProv.processCheckoutApi(
                            cartId: cart.activeCartId ?? '',
                            transactionType: transactionType,
                            paymentType: paymentType,
                            acquirer: isTransfer ? acquirerController.text.trim() : null,
                            notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                            dueDate: isInstallment ? dueDateController.text.trim() : null,
                            downPayment: dpVal,
                            paymentAmount: pAmt,
                          );

                          if (context.mounted) {
                            if (response.isSuccess) {
                              Navigator.pop(ctx);

                              final newOrder = OrderModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                orderNumber: 'INV-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().second.toString().padLeft(3, '0')}',
                                createdAt: DateTime.now(),
                                customerId: cart.selectedCustomer?.id,
                                customerName: cart.selectedCustomer?.name ?? 'Pelanggan Umum',
                                items: List.from(cart.items),
                                totalAmount: cart.totalAmount,
                                paidAmount: pAmt,
                                changeAmount: pAmt > cart.totalAmount ? pAmt - cart.totalAmount : 0,
                                paymentMethod: isTransfer ? PaymentMethod.qris : PaymentMethod.tunai,
                                cashierName: auth.currentUser?.name ?? 'Sales Kasir',
                              );

                              _showReceiptDialog(context, newOrder);
                              cart.clearCart();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Checkout Gagal: ${response.message}')),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'PROSES CHECKOUT & STRUK',
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
      builder: (ctx) => StrukPreviewDialog(
        orderNumber: order.orderNumber,
        createdAt: order.createdAt,
        customerName: order.customerName,
        customerPhone: '0854-5236-0025',
        salesName: order.cashierName,
        items: order.items
            .map((i) => {
                  'name': i.product.name,
                  'qty': i.quantity,
                  'price': i.product.sellPrice,
                  'unit': i.product.unit,
                  'subtotal': i.subtotal,
                })
            .toList(),
        subtotal: order.totalAmount,
        discount: 0,
        totalAmount: order.totalAmount,
        paymentMethod: order.paymentMethod.label,
        paidAmount: order.paidAmount,
        changeAmount: order.changeAmount,
      ),
    );
  }

  void _openProductAddQuantityModal(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int quantity = 1;
        bool isWholesaleExpanded = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header Bar: < Product Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                  // Body Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Stok
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Stok',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                Text(
                                  '${product.stock} ${product.unit}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 8, color: const Color(0xFFF8FAFC)),

                          // Section 2: Deskripsi Produk
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Deskripsi Produk',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  (product.longName != null && product.longName!.isNotEmpty)
                                      ? product.longName!
                                      : (product.unit.isNotEmpty ? '1 ${product.unit} isi item standar' : '-'),
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 8, color: const Color(0xFFF8FAFC)),

                          // Section 3: Jumlah Barang
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jumlah Barang',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (quantity > 1) {
                                          setModalState(() {
                                            quantity--;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.remove, size: 20, color: Colors.grey),
                                      ),
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(minWidth: 48),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          quantity++;
                                        });
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.add, size: 20, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(height: 8, color: const Color(0xFFF8FAFC)),

                          // Section 4: Informasi Harga Grosir
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      isWholesaleExpanded = !isWholesaleExpanded;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Informasi Harga Grosir',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      Icon(
                                        isWholesaleExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: AppColors.textPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isWholesaleExpanded) ...[
                                  const SizedBox(height: 12),
                                  _buildWholesaleTierRow('≥ 10', Formatters.rupiah(product.sellPrice * 0.95)),
                                  const Divider(height: 12, thickness: 0.5),
                                  _buildWholesaleTierRow('≥ 20', Formatters.rupiah(product.sellPrice * 0.90)),
                                  const Divider(height: 12, thickness: 0.5),
                                  _buildWholesaleTierRow('≥ 30', Formatters.rupiah(product.sellPrice * 0.85)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sticky Bottom Button: Tambah
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final cartProv = Provider.of<CartProvider>(context, listen: false);
                          await cartProv.addToCartApi(
                            itemId: product.id,
                            qty: quantity,
                            fallbackProduct: product,
                          );
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Berhasil menambahkan $quantity ${product.unit} ${product.name} ke keranjang'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Tambah',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWholesaleTierRow(String minQty, String priceStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          minQty,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          priceStr,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildCartPanel(BuildContext context, CartProvider cart, {bool isMobileModal = false}) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobileModal ? 4 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keranjang Kasir',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (cart.activeCartId != null)
                    Text(
                      'ID: ${cart.activeCartId!.substring(0, 8)}...',
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                    tooltip: 'Daftar Keranjang Tersimpan',
                    onPressed: () => _openSavedCartsModal(context),
                  ),
                  if (cart.items.isNotEmpty)
                    TextButton(
                      onPressed: () => cart.clearCart(),
                      child: const Text('Kosongkan', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
          const Divider(),

          // Customer Selector Box
          InkWell(
            onTap: () => _openCustomerPickerModal(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cart.selectedCustomer?.name ?? 'Pelanggan Umum',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
                        ),
                        Text(
                          'Status: ${cart.selectedCustomer?.typeName ?? "Retail / Umum"}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (cart.isAddingToCart || cart.isLoading)
            const LinearProgressIndicator(minHeight: 3),

          // Cart Items List
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Keranjang masih kosong.\nPilih produk terlebih dahulu.',
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
                                    onPressed: () {
                                      cart.addToCartApi(
                                        itemId: item.product.id,
                                        qty: 1,
                                        fallbackProduct: item.product,
                                      );
                                    },
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

          // Subtotal & Discount Row
          if (cart.discountAmount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(Formatters.rupiah(cart.subtotal), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Diskon:', style: TextStyle(fontSize: 12, color: AppColors.danger)),
                Text('-${Formatters.rupiah(cart.discountAmount)}', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
          ],

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
          const SizedBox(height: 8),

          // Diskon button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.local_offer_outlined, size: 16),
              label: Text(
                cart.discountAmount > 0 ? 'Diskon: ${Formatters.rupiah(cart.discountAmount)}' : 'Atur Diskon',
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () => _openDiscountModal(context),
            ),
          ),
          const SizedBox(height: 8),

          // Action Buttons: Simpan & Bayar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.save_outlined, size: 16, color: AppColors.primary),
                  label: const Text('Simpan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: cart.items.isEmpty
                      ? null
                      : () {
                          if (isMobileModal) Navigator.pop(context);
                          cart.clearCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Keranjang berhasil disimpan ke server. Silakan buat transaksi baru.')),
                          );
                        },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.payment, size: 16, color: Colors.white),
                  label: const Text('Bayar (Checkout)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: cart.items.isEmpty
                      ? null
                      : () {
                          if (isMobileModal) Navigator.pop(context);
                          _openCheckoutSheet(context);
                        },
                ),
              ),
            ],
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
        final isTablet = constraints.maxWidth >= 750;

        if (isTablet) {
          // Dual Column Tablet View (Catalog Left, Cart Right)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildCatalogPanel(context, productProv, cart, isTablet: true),
              ),
              Expanded(
                flex: 2,
                child: _buildCartPanel(context, cart),
              ),
            ],
          );
        }

        // Mobile Single Page View with Sticky Bottom Cart Action Bar
        final totalItemCount = cart.items.fold(0, (sum, i) => sum + i.quantity);

        return Scaffold(
          body: _buildCatalogPanel(context, productProv, cart, isTablet: false),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalItemCount Item di Keranjang',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        Formatters.rupiah(cart.totalAmount),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                  label: const Text(
                    'Lihat Keranjang',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _openMobileCartSheet(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCatalogPanel(
    BuildContext context,
    ProductProvider productProv,
    CartProvider cart, {
    required bool isTablet,
  }) {
    return Padding(
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
            child: productProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProv.products.isEmpty
                    ? const Center(
                        child: Text('Tidak ada produk ditemukan', style: TextStyle(color: AppColors.textSecondary)),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 3 : 2,
                          childAspectRatio: isTablet ? 1.0 : 0.95,
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
                              onTap: () => _openProductAddQuantityModal(context, p),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        if (p.longName != null && p.longName!.isNotEmpty)
                                          Text(
                                            p.longName!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (p.sellPrice > 0)
                                          Text(
                                            Formatters.rupiah(p.sellPrice),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryDark,
                                              fontSize: 13,
                                            ),
                                          ),
                                        Text(
                                          'Stok: ${p.stock} ${p.unit}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
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

          if (productProv.lastPage > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hal ${productProv.currentPage}/${productProv.lastPage}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: productProv.hasPrevPage ? () => productProv.prevPage() : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed: productProv.hasNextPage ? () => productProv.nextPage() : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
