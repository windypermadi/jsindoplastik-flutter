import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/stock_mutation_model.dart';
import '../../providers/stock_mutation_provider.dart';

class StokMutasiView extends StatefulWidget {
  const StokMutasiView({super.key});

  @override
  State<StokMutasiView> createState() => _StokMutasiViewState();
}

class _StokMutasiViewState extends State<StokMutasiView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAdjustmentModal(StockItemModel item) {
    String type = 'in'; // 'in' or 'out'
    final qtyController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final stockProv = Provider.of<StockMutationProvider>(context);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Penyesuaian Stok (Adjustment)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SKU: ${item.sku} • Stok Saat Ini: ${item.total} (Min: ${item.minimum})',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Jenis Penyesuaian:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => type = 'in'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: type == 'in' ? AppColors.success.withValues(alpha: 0.15) : AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: type == 'in' ? AppColors.success : AppColors.border,
                                  width: type == 'in' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_downward_rounded, color: type == 'in' ? AppColors.success : AppColors.textSecondary, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Stok Masuk (In)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: type == 'in' ? AppColors.success : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => type = 'out'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: type == 'out' ? AppColors.danger.withValues(alpha: 0.15) : AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: type == 'out' ? AppColors.danger : AppColors.border,
                                  width: type == 'out' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_upward_rounded, color: type == 'out' ? AppColors.danger : AppColors.textSecondary, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Stok Keluar (Out)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: type == 'out' ? AppColors.danger : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Kuantitas (Qty)',
                        hintText: 'Masukkan jumlah stok',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Kuantitas wajib diisi';
                        final parsed = int.tryParse(v.trim());
                        if (parsed == null || parsed < 1) return 'Minimal 1';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan / Alasan Adjustment',
                        hintText: 'Misal: Restok Barang, Barang Rusak, Penyesuaian Opname',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Catatan wajib diisi' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == 'in' ? AppColors.success : AppColors.danger,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: stockProv.isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final qty = int.parse(qtyController.text.trim());
                        final notes = notesController.text.trim();

                        final success = await stockProv.adjustStock(
                          stockId: item.id,
                          type: type,
                          qty: qty,
                          notes: notes,
                        );

                        if (context.mounted) {
                          if (success) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Penyesuaian stok ${item.name} berhasil disimpan'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(stockProv.errorMessage ?? 'Gagal menyimpan adjustment stok'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        }
                      },
                child: stockProv.isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Adjustment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openDetailModal(StockItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: FutureBuilder<StockDetailModel?>(
            future: Provider.of<StockMutationProvider>(context, listen: false).fetchStockDetail(item.id),
            builder: (context, snapshot) {
              final detail = snapshot.data;
              final isLoading = snapshot.connectionState == ConnectionState.waiting;

              final nama = detail?.item.name ?? item.name;
              final kategori = detail?.item.parentCategoryName ?? item.parentCategoryName ?? 'Foodpack';
              final jenis = detail?.item.childCategoryName ?? item.childCategoryName ?? 'Cup';
              final typeName = detail?.item.typeName ?? item.typeName ?? 'Jelly';
              final totalStok = detail?.total ?? item.total;

              return Column(
                children: [
                  // 1. Header Bar: < Detail Stok Mutasi
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
                          'Detail Stok Mutasi',
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

                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 2. Informasi Produk Card Section
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Informasi Produk',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow('Nama', nama),
                                      const SizedBox(height: 6),
                                      _buildInfoRow('Kategori', kategori),
                                      const SizedBox(height: 6),
                                      _buildInfoRow('Jenis', jenis),
                                      const SizedBox(height: 6),
                                      _buildInfoRow('Type', typeName),
                                    ],
                                  ),
                                ),

                                Container(height: 8, color: const Color(0xFFF8FAFC)),

                                // 3. List Stok Section
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.warehouse_outlined, color: AppColors.primary, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'List Stok',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (detail == null || detail.historyDetails.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 24),
                                          child: Center(
                                            child: Text(
                                              'Belum ada riwayat mutasi stok',
                                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                            ),
                                          ),
                                        )
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: detail.historyDetails.length,
                                          separatorBuilder: (context, index) => const Divider(height: 16, thickness: 0.8, color: Color(0xFFF1F5F9)),
                                          itemBuilder: (context, idx) {
                                            final h = detail.historyDetails[idx];
                                            final isIn = h.qtyIn > 0;
                                            final qtyVal = isIn ? h.qtyIn : h.qtyOut;
                                            final qtyStr = isIn ? '+ $qtyVal Pack' : '- $qtyVal Pack';
                                            final qtyColor = isIn ? const Color(0xFF10B981) : const Color(0xFFF43F5E);

                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          h.lastUpdated ?? '-',
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.textPrimary,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          h.notes,
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            color: AppColors.textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    qtyStr,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: qtyColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  // 4. Sticky Bottom Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Stok :',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$totalStok Pack',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openAdjustmentModal(item);
                            },
                            child: const Text(
                              'Atur Stok',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        const Text(
          ':  ',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockProv = Provider.of<StockMutationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Filter & Search Bar Area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari Nama Barang / SKU...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    stockProv.setSearchQuery('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onSubmitted: (val) => stockProv.setSearchQuery(val.trim()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => stockProv.setSearchQuery(_searchController.text.trim()),
                      child: const Text('Cari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Semua'),
                      selected: stockProv.selectedFilter == null,
                      onSelected: (_) => stockProv.setFilter('Semua'),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Total Stok'),
                      selected: stockProv.selectedFilter == 'total',
                      onSelected: (_) => stockProv.setFilter('total'),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Terakhir Update'),
                      selected: stockProv.selectedFilter == 'last_update',
                      onSelected: (_) => stockProv.setFilter('last_update'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        stockProv.sortOrder == 'desc' ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Urutan (${stockProv.sortOrder.toUpperCase()})',
                      onPressed: () => stockProv.toggleSortOrder(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Stock List View
          Expanded(
            child: stockProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : stockProv.stockItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              stockProv.errorMessage ?? 'Tidak ada data stok ditemukan',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => stockProv.fetchStockItems(isRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: stockProv.stockItems.length,
                          itemBuilder: (context, index) {
                            final item = stockProv.stockItems[index];
                            final isLowStock = item.total <= item.minimum;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      item.sku,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primaryDark,
                                                      ),
                                                    ),
                                                  ),
                                                  if (item.typeName != null && item.typeName!.isNotEmpty) ...[
                                                    const SizedBox(width: 6),
                                                    Text('• ${item.typeName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.name,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                              ),
                                              if (item.longName != null && item.longName!.isNotEmpty)
                                                Text(
                                                  item.longName!,
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isLowStock ? AppColors.danger.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '${item.total}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isLowStock ? AppColors.danger : AppColors.success,
                                                ),
                                              ),
                                              Text(
                                                'Min: ${item.minimum}',
                                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Update: ${item.lastUpdated ?? '-'}',
                                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                visualDensity: VisualDensity.compact,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              icon: const Icon(Icons.history, size: 15),
                                              label: const Text('Riwayat', style: TextStyle(fontSize: 11)),
                                              onPressed: () => _openDetailModal(item),
                                            ),
                                            const SizedBox(width: 6),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                visualDensity: VisualDensity.compact,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              icon: const Icon(Icons.edit_note, size: 15, color: Colors.white),
                                              label: const Text('Adjustment', style: TextStyle(fontSize: 11, color: Colors.white)),
                                              onPressed: () => _openAdjustmentModal(item),
                                            ),
                                          ],
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
          ),

          // Pagination Footer
          if (stockProv.lastPage > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Halaman ${stockProv.currentPage} dari ${stockProv.lastPage} (Total: ${stockProv.totalItems})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: stockProv.hasPrevPage ? () => stockProv.prevPage() : null,
                      ),
                      Text('${stockProv.currentPage}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: stockProv.hasNextPage ? () => stockProv.nextPage() : null,
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
