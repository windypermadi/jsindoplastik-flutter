import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../auth/login_view.dart';

enum NavMenu {
  dashboard,
  produk,
  kelolaProduk,
  pesanan,
  riwayatTransaksi,
  pelanggan,
  user,
  kasbon,
  transaksi,
  stokMutasi,
  laporan,
  sinkronisasi,
  profil,
}

extension NavMenuExtension on NavMenu {
  String get title {
    switch (this) {
      case NavMenu.dashboard:
        return 'Dashboard';
      case NavMenu.produk:
        return 'Produk';
      case NavMenu.kelolaProduk:
        return 'Kelola Produk';
      case NavMenu.pesanan:
        return 'Pesanan';
      case NavMenu.riwayatTransaksi:
        return 'Riwayat Transaksi';
      case NavMenu.pelanggan:
        return 'Pelanggan';
      case NavMenu.user:
        return 'User';
      case NavMenu.kasbon:
        return 'Kasbon';
      case NavMenu.transaksi:
        return 'Transaksi';
      case NavMenu.stokMutasi:
        return 'Stok Mutasi';
      case NavMenu.laporan:
        return 'Laporan';
      case NavMenu.sinkronisasi:
        return 'Sinkronasi Data';
      case NavMenu.profil:
        return 'Profil';
    }
  }

  IconData get icon {
    switch (this) {
      case NavMenu.dashboard:
        return Icons.grid_view_rounded;
      case NavMenu.produk:
        return Icons.inventory_2_outlined;
      case NavMenu.kelolaProduk:
        return Icons.published_with_changes;
      case NavMenu.pesanan:
        return Icons.add_shopping_cart_rounded;
      case NavMenu.riwayatTransaksi:
        return Icons.history_rounded;
      case NavMenu.pelanggan:
        return Icons.groups_rounded;
      case NavMenu.user:
        return Icons.manage_accounts_rounded;
      case NavMenu.kasbon:
        return Icons.receipt_long_outlined;
      case NavMenu.transaksi:
        return Icons.description_outlined;
      case NavMenu.stokMutasi:
        return Icons.insert_chart_outlined_rounded;
      case NavMenu.laporan:
        return Icons.analytics_outlined;
      case NavMenu.sinkronisasi:
        return Icons.sync_rounded;
      case NavMenu.profil:
        return Icons.person_outline_rounded;
    }
  }
}

class AppDrawer extends StatelessWidget {
  final NavMenu selectedMenu;
  final ValueChanged<NavMenu> onSelectMenu;

  const AppDrawer({
    super.key,
    required this.selectedMenu,
    required this.onSelectMenu,
  });

  List<NavMenu> _getMenusForUser(bool isOwner) {
    if (isOwner) {
      return [
        NavMenu.dashboard,
        NavMenu.produk,
        NavMenu.kelolaProduk,
        NavMenu.pesanan,
        NavMenu.riwayatTransaksi,
        NavMenu.pelanggan,
        NavMenu.user,
        NavMenu.kasbon,
        NavMenu.transaksi,
        NavMenu.stokMutasi,
        NavMenu.laporan,
        NavMenu.sinkronisasi,
        NavMenu.profil,
      ];
    } else {
      return [
        NavMenu.dashboard,
        NavMenu.produk,
        NavMenu.riwayatTransaksi,
        NavMenu.pelanggan,
        NavMenu.kasbon,
        NavMenu.transaksi,
        NavMenu.laporan,
        NavMenu.sinkronisasi,
        NavMenu.profil,
      ];
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isOwner = auth.isOwner;
    final menuItems = _getMenusForUser(isOwner);

    const oceanBlue = Color(0xFF1E88E5);

    return Drawer(
      backgroundColor: oceanBlue,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Top Section: Hamburger Icon & Logo/Nama
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      auth.currentUser?.name != null
                          ? 'JSINDOPLASTIK\n(${isOwner ? "Owner" : "Sales"})'
                          : 'Logo/Nama',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),

            // Navigation Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menu = menuItems[index];
                  final isSelected = menu == selectedMenu;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Material(

                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          onSelectMenu(menu);
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                            ),
                          ),
                          child: Consumer<CartProvider>(
                            builder: (context, cart, _) {
                              final count = cart.totalQuantity;
                              final isCartMenu = menu == NavMenu.transaksi || menu == NavMenu.pesanan;

                              return Row(
                                children: [
                                  Icon(
                                    menu.icon,
                                    size: 22,
                                    color: isSelected ? oceanBlue : Colors.white,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      menu.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? oceanBlue : Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (isCartMenu && count > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Logout Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                    title: const Text(
                      'Keluar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLogout(context);
                    },
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
