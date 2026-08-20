import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_model.dart';
import '../../models/user_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/auth_provider.dart';

class PelangganView extends StatefulWidget {
  const PelangganView({super.key});

  @override
  State<PelangganView> createState() => _PelangganViewState();
}

class _PelangganViewState extends State<PelangganView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTipeCustomerLabel(int tipe) {
    switch (tipe) {
      case 1:
        return 'Grosir 1';
      case 2:
        return 'Grosir 2';
      case 3:
      default:
        return 'Retail';
    }
  }

  Color _getTipeCustomerColor(int tipe) {
    switch (tipe) {
      case 1:
        return AppColors.ownerBadge;
      case 2:
        return AppColors.accent;
      case 3:
      default:
        return AppColors.primary;
    }
  }

  void _showCustomerDetailDialog(CustomerModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getTipeCustomerColor(c.tipeCustomer),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Text(
                  c.name.isNotEmpty ? c.name[0].toUpperCase() : 'P',
                  style: TextStyle(
                    color: _getTipeCustomerColor(c.tipeCustomer),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Tipe: ${_getTipeCustomerLabel(c.tipeCustomer)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem(Icons.store_outlined, 'Nama Toko', c.namaToko != null && c.namaToko!.isNotEmpty ? c.namaToko! : '-'),
              _buildDetailItem(Icons.phone_outlined, 'Nomor Telepon', c.phone),
              _buildDetailItem(Icons.email_outlined, 'Email', c.email != null && c.email!.isNotEmpty ? c.email! : '-'),
              _buildDetailItem(Icons.location_on_outlined, 'Alamat', c.address != null && c.address!.isNotEmpty ? c.address! : '-'),
              _buildDetailItem(Icons.map_outlined, 'Alamat Maps', c.alamatMaps != null && c.alamatMaps!.isNotEmpty ? c.alamatMaps! : '-'),
              _buildDetailItem(
                Icons.account_balance_wallet_outlined,
                'Saldo Kasbon (Hutang)',
                Formatters.rupiah(c.debtBalance),
                valueColor: c.debtBalance > 0 ? AppColors.danger : AppColors.success,
              ),
              if (c.salesName != null && c.salesName!.isNotEmpty)
                _buildDetailItem(Icons.badge_outlined, 'Sales Penanggung Jawab', c.salesName!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Pelanggan'),
            onPressed: () {
              Navigator.pop(ctx);
              _openCustomerFormModal(customerToEdit: c);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCustomerFormModal({CustomerModel? customerToEdit}) {
    final isEdit = customerToEdit != null;
    final nameController = TextEditingController(text: customerToEdit?.name ?? '');
    final phoneController = TextEditingController(text: customerToEdit?.phone ?? '');
    final emailController = TextEditingController(text: customerToEdit?.email ?? '');
    final addressController = TextEditingController(text: customerToEdit?.address ?? '');
    final mapsController = TextEditingController(text: customerToEdit?.alamatMaps ?? '');
    final tokoController = TextEditingController(text: customerToEdit?.namaToko ?? '');

    int selectedTipe = customerToEdit?.tipeCustomer ?? 3;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final custProv = Provider.of<CustomerProvider>(context, listen: false);

    String? selectedSalesId = customerToEdit?.salesId ?? auth.currentUser?.id;
    if (selectedSalesId == null || selectedSalesId.isEmpty) {
      if (custProv.salesUsers.isNotEmpty) {
        selectedSalesId = custProv.salesUsers.first.id;
      }
    }

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Data Pelanggan' : 'Tambah Pelanggan Baru',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sales ID selection
                        Builder(
                          builder: (context) {
                            final currentSalesId = selectedSalesId;
                            final initialSalesValue = (currentSalesId != null &&
                                    custProv.salesUsers.any((u) => u.id == currentSalesId))
                                ? currentSalesId
                                : (custProv.salesUsers.isNotEmpty ? custProv.salesUsers.first.id : null);

                            return DropdownButtonFormField<String>(
                              value: initialSalesValue,
                              decoration: const InputDecoration(
                                labelText: 'Sales Penanggung Jawab',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: custProv.salesUsers.map<DropdownMenuItem<String>>((u) {
                                final roleText = u.rawRole.isNotEmpty ? u.rawRole : u.role.displayName;
                                return DropdownMenuItem<String>(
                                  value: u.id,
                                  child: Text('${u.name} ($roleText)'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedSalesId = val;
                                  });
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Pelanggan *',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Telepon / WA * (awalan 62, cth: 6281923812938)',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Nomor telepon wajib diisi';
                            final cleaned = v.trim().replaceAll(RegExp(r'\D'), '');
                            if (!cleaned.startsWith('62')) {
                              return 'Nomor telepon harus diawali 62 (contoh: 6281923812938)';
                            }
                            if (cleaned.length < 11 || cleaned.length > 20) {
                              return 'Nomor telepon minimal 11 digit dan maksimal 20 digit';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: tokoController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Toko / Usaha (Opsional)',
                            prefixIcon: Icon(Icons.store_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email (Opsional)',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Alamat (Opsional)',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: mapsController,
                          decoration: const InputDecoration(
                            labelText: 'Link / Alamat Maps (Opsional)',
                            prefixIcon: Icon(Icons.map_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<int>(
                          value: selectedTipe,
                          decoration: const InputDecoration(
                            labelText: 'Tipe Customer *',
                            prefixIcon: Icon(Icons.category_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 3, child: Text('Retail (Tipe 3)')),
                            DropdownMenuItem(value: 1, child: Text('Grosir 1 (Tipe 1)')),
                            DropdownMenuItem(value: 2, child: Text('Grosir 2 (Tipe 2)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedTipe = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        Consumer<CustomerProvider>(
                          builder: (context, provider, _) => SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: provider.isSubmitting
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;

                                      final phoneDigits = phoneController.text.replaceAll(RegExp(r'\D'), '');
                                      final parsedPhone = int.tryParse(phoneDigits) ?? phoneDigits;

                                      final rawBody = <String, dynamic>{
                                        'sales_id': selectedSalesId,
                                        'nama': nameController.text.trim(),
                                        'nomor_telpon': parsedPhone,
                                        'email': emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                                        'alamat': addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
                                        'alamat_maps': mapsController.text.trim().isNotEmpty ? mapsController.text.trim() : null,
                                        'nama_toko': tokoController.text.trim().isNotEmpty ? tokoController.text.trim() : null,
                                        'tipe_customer': selectedTipe,
                                      };

                                      bool success;
                                      if (isEdit) {
                                        success = await provider.updateCustomer(customerToEdit.id, rawBody);
                                      } else {
                                        success = await provider.addCustomer(rawBody);
                                      }

                                      if (!context.mounted) return;
                                      if (success) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEdit ? 'Data pelanggan berhasil diperbarui' : 'Pelanggan baru berhasil ditambahkan',
                                            ),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              provider.errorMessage ?? 'Gagal menyimpan data pelanggan',
                                            ),
                                            backgroundColor: AppColors.danger,
                                          ),
                                        );
                                      }
                                    },
                              child: provider.isSubmitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      isEdit ? 'Simpan Perubahan' : 'Tambah Pelanggan',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(CustomerModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text('Apakah Anda yakin ingin menghapus pelanggan ${c.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final custProv = Provider.of<CustomerProvider>(context, listen: false);
              final success = await custProv.deleteCustomer(c.id);
              if (!mounted) return;
              Navigator.pop(ctx);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pelanggan berhasil dihapus')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(custProv.errorMessage ?? 'Gagal menghapus pelanggan'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final custProv = Provider.of<CustomerProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Tambah Pelanggan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _openCustomerFormModal(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input & Refresh
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => custProv.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari pelanggan, no hp, atau toko...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                custProv.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  tooltip: 'Muat Ulang Data',
                  onPressed: () => custProv.fetchCustomers(isRefresh: true),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tipe Customer Filter Chips
            Row(
              children: [
                const Text(
                  'Filter Tipe: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Retail', 'Grosir 1', 'Grosir 2'].map((tipeStr) {
                        final isSelected = (custProv.selectedFilter == null && tipeStr == 'Semua') ||
                            (custProv.selectedFilter == tipeStr);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(tipeStr),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (_) => custProv.setFilter(tipeStr),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Customer List Body
            Expanded(
              child: custProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : custProv.customers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                custProv.errorMessage ?? 'Tidak ada data pelanggan ditemukan',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                                label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                                onPressed: () => custProv.fetchCustomers(isRefresh: true),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => custProv.fetchCustomers(isRefresh: true),
                          child: ListView.builder(
                            itemCount: custProv.customers.length,
                            itemBuilder: (context, index) {
                              final c = custProv.customers[index];
                              final hasDebt = c.debtBalance > 0;
                              final badgeColor = _getTipeCustomerColor(c.tipeCustomer);

                              return Card(
                                elevation: 1.5,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  leading: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: badgeColor.withValues(alpha: 0.15),
                                    child: Icon(Icons.person, color: badgeColor),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Chip(
                                        padding: EdgeInsets.zero,
                                        labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -4),
                                        label: Text(_getTipeCustomerLabel(c.tipeCustomer)),
                                        backgroundColor: badgeColor.withValues(alpha: 0.12),
                                        labelStyle: TextStyle(
                                          color: badgeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (c.namaToko != null && c.namaToko!.isNotEmpty)
                                        Text(
                                          'Toko: ${c.namaToko}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        ),
                                      Text(
                                        'HP: ${c.phone} ${c.address != null && c.address!.isNotEmpty ? "• ${c.address}" : ""}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text('Kasbon:', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                          Text(
                                            Formatters.rupiah(c.debtBalance),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: hasDebt ? AppColors.danger : AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                                        tooltip: 'Detail Pelanggan',
                                        onPressed: () => _showCustomerDetailDialog(c),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                        tooltip: 'Edit Pelanggan',
                                        onPressed: () => _openCustomerFormModal(customerToEdit: c),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                        tooltip: 'Hapus Pelanggan',
                                        onPressed: () => _confirmDelete(c),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),

            // Pagination Controls Footer
            if (!custProv.isLoading && custProv.customers.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hal ${custProv.currentPage} dari ${custProv.lastPage} (Total ${custProv.totalCustomers})',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          tooltip: 'Halaman Sebelumnya',
                          onPressed: custProv.hasPrevPage ? () => custProv.prevPage() : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${custProv.currentPage}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 13),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          tooltip: 'Halaman Selanjutnya',
                          onPressed: custProv.hasNextPage ? () => custProv.nextPage() : null,
                        ),
                      ],
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
