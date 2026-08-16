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
  void _openAddUserDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.sales;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah User / Staf Baru'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Role / Hak Akses: '),
                    const SizedBox(width: 8),
                    DropdownButton<UserRole>(
                      value: selectedRole,
                      items: const [
                        DropdownMenuItem(
                          value: UserRole.sales,
                          child: Text('Sales'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.owner,
                          child: Text('Owner'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedRole = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final userProv = Provider.of<UserManagementProvider>(context, listen: false);

                final newUser = UserModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  role: selectedRole,
                );

                await userProv.addUser(newUser);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User staf berhasil ditambahkan')),
                  );
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserManagementProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Tambah User Staf', style: TextStyle(color: Colors.white)),
        onPressed: _openAddUserDialog,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userProv.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: userProv.users.length,
                itemBuilder: (context, index) {
                  final u = userProv.users[index];
                  final isOwner = u.role == UserRole.owner;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOwner ? AppColors.ownerBadge : AppColors.salesBadge,
                        child: Text(
                          u.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('HP: ${u.phone} • Status: ${u.isActive ? "Aktif" : "Non-Aktif"}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(u.role.displayName),
                            backgroundColor: (isOwner ? AppColors.ownerBadge : AppColors.salesBadge).withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: isOwner ? AppColors.ownerBadge : AppColors.salesBadge,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          Switch(
                            value: u.isActive,
                            activeColor: AppColors.success,
                            onChanged: (_) => userProv.toggleUserStatus(u.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
