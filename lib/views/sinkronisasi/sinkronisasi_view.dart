import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/sync_provider.dart';

class SinkronisasiView extends StatelessWidget {
  const SinkronisasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final syncProv = Provider.of<SyncProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sync_outlined,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sinkronisasi Data POS & Server API',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gunakan fitur ini untuk menyinkronkan data offline transaksi, produk, dan pelanggan ke server backend API Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 32),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Data Tertunda (Pending Sync):', style: TextStyle(fontWeight: FontWeight.w600)),
                      Chip(
                        label: Text('${syncProv.pendingCount} Transaksi'),
                        backgroundColor: syncProv.pendingCount > 0 ? AppColors.warning.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: syncProv.pendingCount > 0 ? AppColors.warning : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Terakhir Disinkron:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        syncProv.lastSyncTime != null ? Formatters.dateTime(syncProv.lastSyncTime!) : 'Belum pernah',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Status: ${syncProv.syncMessage}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: syncProv.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded, color: Colors.white),
              label: Text(
                syncProv.isSyncing ? 'MENYINKRONKAN DATA...' : 'SINKRONKAN SEKARANG',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: syncProv.isSyncing ? null : () => syncProv.syncNow(),
            ),
          ),
        ],
      ),
    );
  }
}
