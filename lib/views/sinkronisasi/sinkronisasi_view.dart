import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/sync_provider.dart';
import '../../providers/product_provider.dart';

class SinkronisasiView extends StatelessWidget {
  const SinkronisasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final syncProv = Provider.of<SyncProvider>(context);
    final productProv = Provider.of<ProductProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sync_rounded,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sinkronisasi Data Produk Offline',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unduh dan simpan seluruh katalog produk dari server API ke Database Lokal aplikasi agar dapat bertransaksi POS tanpa koneksi internet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Database & Sync Status Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storage_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Produk di Database Lokal:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${syncProv.localProductsCount} Produk',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 20),
                          SizedBox(width: 8),
                          Text('Terakhir Disinkron:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                      Text(
                        syncProv.lastSyncTime != null ? Formatters.dateTime(syncProv.lastSyncTime!) : 'Belum pernah',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (syncProv.isSyncing) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: syncProv.syncProgress > 0 ? syncProv.syncProgress : null,
                        backgroundColor: AppColors.primaryLight,
                        color: AppColors.primary,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          syncProv.isSyncing ? Icons.sync : Icons.info_outline,
                          size: 18,
                          color: syncProv.isSyncing ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            syncProv.syncMessage,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: syncProv.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.download_rounded, color: Colors.white),
              label: Text(
                syncProv.isSyncing ? 'MENGUNDUH & MENYIMPAN DATA...' : 'SINKRONKAN DATA PRODUK SEKARANG',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: syncProv.isSyncing
                  ? null
                  : () async {
                      await syncProv.syncNow(productProvider: productProv);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(syncProv.syncMessage),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
            ),
          ),
          const SizedBox(height: 24),

          // Offline POS Features Card
          Card(
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_off_rounded, color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Manfaat Database Lokal POS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('• Transaksi Kasir POS tetap dapat berjalan lancar tanpa jaringan internet.'),
                  SizedBox(height: 4),
                  Text('• Pencarian nama produk & stok instan langsung dari memori perangkat.'),
                  SizedBox(height: 4),
                  Text('• Data tersinkron rapat dengan endpoint server {{url}}product/get-all.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
