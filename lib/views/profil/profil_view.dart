import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'edit_profil_view.dart';

class ProfilView extends StatelessWidget {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final roleName = user?.role.displayName ?? 'Owner';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar & Name Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (user?.avatar != null && user!.avatar!.startsWith('http'))
                            ? NetworkImage(user.avatar!) as ImageProvider
                            : const NetworkImage(
                                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Ashlynn Donin',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section 1: Setting
              const Text(
                'Setting',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),

              // Card Option 1: Edit Profil
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF374151),
                    size: 22,
                  ),
                  title: const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfilView()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Card Option 2: Hubungi Admin
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF374151),
                    size: 22,
                  ),
                  title: const Text(
                    'Hubungi Admin',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menghubungi Customer Support / Admin...')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Section 2: Tentang Aplikasi
              const Text(
                'Tentang Aplikasi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'App Version',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        Text(
                          '1.1.2',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          'Syarat & Ketentuan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          'Kebijakan Privasi',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade200, height: 1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
