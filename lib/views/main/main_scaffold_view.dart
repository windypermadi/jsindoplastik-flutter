import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'app_drawer.dart';

import '../dashboard/dashboard_view.dart';
import '../produk/produk_catalog_view.dart';
import '../kelola_produk/kelola_produk_view.dart';
import '../pesanan/pesanan_view.dart';
import '../pelanggan/pelanggan_view.dart';
import '../user/user_management_view.dart';
import '../kasbon/kasbon_view.dart';
import '../transaksi/transaksi_pos_view.dart';
import '../stok_mutasi/stok_mutasi_view.dart';
import '../laporan/laporan_view.dart';
import '../sinkronisasi/sinkronisasi_view.dart';
import '../profil/profil_view.dart';

class MainScaffoldView extends StatefulWidget {
  const MainScaffoldView({super.key});

  @override
  State<MainScaffoldView> createState() => _MainScaffoldViewState();
}

class _MainScaffoldViewState extends State<MainScaffoldView> {
  NavMenu _selectedMenu = NavMenu.dashboard;

  Widget _buildBody(NavMenu menu) {
    switch (menu) {
      case NavMenu.dashboard:
        return DashboardView(onNavigate: (targetMenu) {
          setState(() {
            _selectedMenu = targetMenu;
          });
        });
      case NavMenu.produk:
        return const ProdukCatalogView();
      case NavMenu.kelolaProduk:
        return const KelolaProdukView();
      case NavMenu.pesanan:
        return const PesananView();
      case NavMenu.pelanggan:
        return const PelangganView();
      case NavMenu.user:
        return const UserManagementView();
      case NavMenu.kasbon:
        return const KasbonView();
      case NavMenu.transaksi:
        return const TransaksiPosView();
      case NavMenu.stokMutasi:
        return const StokMutasiView();
      case NavMenu.laporan:
        return const LaporanView();
      case NavMenu.sinkronisasi:
        return const SinkronisasiView();
      case NavMenu.profil:
        return const ProfilView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isOwner = auth.isOwner;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Text(
              _selectedMenu.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isOwner ? AppColors.ownerBadge : AppColors.salesBadge),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isOwner ? 'OWNER' : 'SALES',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_outlined),
            tooltip: 'Sinkronasi Data',
            onPressed: () {
              setState(() {
                _selectedMenu = NavMenu.sinkronisasi;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.point_of_sale_outlined),
            tooltip: 'Transaksi POS',
            onPressed: () {
              setState(() {
                _selectedMenu = NavMenu.transaksi;
              });
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedMenu: _selectedMenu,
        onSelectMenu: (menu) {
          setState(() {
            _selectedMenu = menu;
          });
        },
      ),
      body: _buildBody(_selectedMenu),
    );
  }
}
