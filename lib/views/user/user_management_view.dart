import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/user_management_provider.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getRoleColor(UserRole role, String rawRole) {
    final lower = rawRole.toLowerCase();
    if (role == UserRole.owner || lower.contains('owner')) {
      return AppColors.ownerBadge;
    } else if (role == UserRole.admin || lower.contains('admin')) {
      return AppColors.info;
    } else {
      return AppColors.salesBadge;
    }
  }

  void _showUserDetailDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getRoleColor(user.role, user.rawRole),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: (user.avatar != null && user.avatar!.startsWith('http'))
                    ? NetworkImage(user.avatar!)
                    : null,
                child: (user.avatar == null || !user.avatar!.startsWith('http'))
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: _getRoleColor(user.role, user.rawRole),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
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
                        user.rawRole.isNotEmpty ? user.rawRole : user.role.displayName,
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
              _buildDetailItem(Icons.key_outlined, 'User ID', user.id),
              _buildDetailItem(Icons.phone_outlined, 'Nomor HP', user.phone),
              _buildDetailItem(
                Icons.email_outlined,
                'Email',
                user.email != null && user.email!.isNotEmpty ? user.email! : '-',
              ),
              _buildDetailItem(
                Icons.location_on_outlined,
                'Alamat',
                user.address != null && user.address!.isNotEmpty ? user.address! : '-',
              ),
              _buildDetailItem(
                Icons.circle,
                'Status Akun',
                user.isActive ? 'Aktif' : 'Non-Aktif',
                valueColor: user.isActive ? AppColors.success : AppColors.danger,
              ),
              if (user.updatedAt != null && user.updatedAt!.isNotEmpty)
                _buildDetailItem(
                  Icons.access_time_outlined,
                  'Terakhir Diperbarui',
                  user.updatedAt!,
                ),
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
            label: const Text('Edit User'),
            onPressed: () {
              Navigator.pop(ctx);
              _openUserFormModal(userToEdit: user);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  void _openUserFormModal({UserModel? userToEdit}) {
    final isEdit = userToEdit != null;
    final nameController = TextEditingController(text: userToEdit?.name ?? '');
    final phoneController = TextEditingController(text: userToEdit?.phone ?? '');
    final emailController = TextEditingController(text: userToEdit?.email ?? '');
    final addressController = TextEditingController(text: userToEdit?.address ?? '');
    final passwordController = TextEditingController();

    String selectedRole = userToEdit?.rawRole ?? 'Sales';
    if (!['Admin', 'Owner', 'Sales'].contains(selectedRole)) {
      selectedRole = 'Sales';
    }
    bool isActive = userToEdit?.isActive ?? true;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                      isEdit ? 'Edit Data User' : 'Tambah User / Staf Baru',
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

              // Form body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap *',
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
                            labelText: 'Nomor Telepon / WA *',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: isEdit ? 'Password (Kosongkan jika tidak diubah)' : 'Password *',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (!isEdit && (v == null || v.trim().isEmpty)) {
                              return 'Password wajib diisi untuk user baru';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Alamat',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role / Hak Akses *',
                            prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Sales', child: Text('Sales')),
                            DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                            DropdownMenuItem(value: 'Owner', child: Text('Owner')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedRole = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Status Akun Aktif', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            isActive ? 'User dapat login dan melakukan transaksi' : 'User dinonaktifkan',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          value: isActive,
                          activeColor: AppColors.success,
                          onChanged: (val) {
                            setModalState(() {
                              isActive = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        Consumer<UserManagementProvider>(
                          builder: (context, userProv, _) => SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: userProv.isSubmitting
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;

                                      final payload = <String, dynamic>{
                                        'name': nameController.text.trim(),
                                        'phone': phoneController.text.trim(),
                                        'email': emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                                        'address': addressController.text.trim().isNotEmpty ? addressController.text.trim() : null,
                                        'role': selectedRole,
                                        'is_active': isActive,
                                      };

                                      if (passwordController.text.trim().isNotEmpty) {
                                        payload['password'] = passwordController.text.trim();
                                      }

                                      bool success;
                                      if (isEdit) {
                                        success = await userProv.updateUser(userToEdit.id, payload);
                                      } else {
                                        success = await userProv.addUser(payload);
                                      }

                                      if (!context.mounted) return;
                                      if (success) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEdit ? 'Data user berhasil diperbarui' : 'User baru berhasil ditambahkan',
                                            ),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              userProv.errorMessage ?? 'Gagal menyimpan data user',
                                            ),
                                            backgroundColor: AppColors.danger,
                                          ),
                                        );
                                      }
                                    },
                              child: userProv.isSubmitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      isEdit ? 'Simpan Perubahan' : 'Tambah User',
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

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Apakah Anda yakin ingin menghapus user ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final userProv = Provider.of<UserManagementProvider>(context, listen: false);
              final success = await userProv.deleteUser(user.id);
              if (!mounted) return;
              Navigator.pop(ctx);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User berhasil dihapus')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(userProv.errorMessage ?? 'Gagal menghapus user'),
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
    final userProv = Provider.of<UserManagementProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Tambah User Staf', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _openUserFormModal(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar & Actions
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => userProv.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, email, atau telepon user...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                userProv.setSearchQuery('');
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
                  onPressed: () => userProv.fetchUsers(isRefresh: true),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Role Filters
            Row(
              children: [
                const Text(
                  'Filter Role: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Admin', 'Owner', 'Sales'].map((role) {
                        final isSelected = (userProv.selectedFilter == null && role == 'Semua') ||
                            (userProv.selectedFilter == role);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(role),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (_) => userProv.setFilter(role),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // User List Body
            Expanded(
              child: userProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : userProv.users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                userProv.errorMessage ?? 'Tidak ada data user ditemukan',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                                label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                                onPressed: () => userProv.fetchUsers(isRefresh: true),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => userProv.fetchUsers(isRefresh: true),
                          child: ListView.builder(
                            itemCount: userProv.users.length,
                            itemBuilder: (context, index) {
                              final u = userProv.users[index];
                              final roleColor = _getRoleColor(u.role, u.rawRole);

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
                                    backgroundColor: roleColor,
                                    backgroundImage: (u.avatar != null && u.avatar!.startsWith('http'))
                                        ? NetworkImage(u.avatar!)
                                        : null,
                                    child: (u.avatar == null || !u.avatar!.startsWith('http'))
                                        ? Text(
                                            u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          u.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Chip(
                                        padding: EdgeInsets.zero,
                                        labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -4),
                                        label: Text(u.rawRole.isNotEmpty ? u.rawRole : u.role.displayName),
                                        backgroundColor: roleColor.withValues(alpha: 0.12),
                                        labelStyle: TextStyle(
                                          color: roleColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'HP: ${u.phone} ${u.email != null && u.email!.isNotEmpty ? "• ${u.email}" : ""}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Switch(
                                        value: u.isActive,
                                        activeColor: AppColors.success,
                                        onChanged: (_) => userProv.toggleUserStatus(u.id, u.isActive),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                                        tooltip: 'Detail User',
                                        onPressed: () => _showUserDetailDialog(u),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                        tooltip: 'Edit User',
                                        onPressed: () => _openUserFormModal(userToEdit: u),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                        tooltip: 'Hapus User',
                                        onPressed: () => _confirmDelete(u),
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
            if (!userProv.isLoading && userProv.users.isNotEmpty)
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
                      'Hal ${userProv.currentPage} dari ${userProv.lastPage} (Total ${userProv.totalUsers})',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          tooltip: 'Halaman Sebelumnya',
                          onPressed: userProv.hasPrevPage ? () => userProv.prevPage() : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${userProv.currentPage}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 13),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          tooltip: 'Halaman Selanjutnya',
                          onPressed: userProv.hasNextPage ? () => userProv.nextPage() : null,
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
