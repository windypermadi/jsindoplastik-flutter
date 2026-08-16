import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';


class EditProfilView extends StatefulWidget {
  const EditProfilView({super.key});

  @override
  State<EditProfilView> createState() => _EditProfilViewState();
}

class _EditProfilViewState extends State<EditProfilView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? 'Ashlynn Donin');
    _phoneController = TextEditingController(text: user?.phone ?? '0854-8562-0015');
    _addressController = TextEditingController(
      text: user?.address ?? 'Jalan Beo, Catur tunggal, Demangan Yogyakarta',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updateProfileDetails(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubah Foto Profil ({{url}}user/{id}/image)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengunggah foto profil baru ke server API...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Ambil Foto Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengunggah foto profil baru ke server API...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final roleName = user?.role.displayName ?? 'Owner';
    const oceanBlue = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Blue Pencil Badge Button
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (user?.avatar != null && user!.avatar!.startsWith('http'))
                              ? NetworkImage(user.avatar!) as ImageProvider
                              : const NetworkImage(
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                                ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: oceanBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Field 1: Nama
                const Text(
                  'Nama',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 18),

                // Field 2: Jabatan (Disabled/Read-only with Grey Background)
                const Text(
                  'Jabatan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB).withOpacity(0.6), // Grey shaded
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Field 3: No Telepon
                const Text(
                  'No Telepon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'No Telepon wajib diisi' : null,
                ),
                const SizedBox(height: 18),

                // Field 4: Alamat (Multiline Input Box)
                const Text(
                  'Alamat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: oceanBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: auth.isLoading ? null : _saveProfile,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Simpan Perubahan',
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
        ),
      ),
    );
  }
}
