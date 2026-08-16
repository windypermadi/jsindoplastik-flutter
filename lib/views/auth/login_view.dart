import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../main/main_scaffold_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController(text: '6281234567891');
  final _passwordController = TextEditingController(text: 'test_owner');
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffoldView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login gagal. Periksa nomor & password.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showApiSettingsDialog() async {
    final currentUrl = await StorageService.getBaseUrl();
    final urlController = TextEditingController(text: currentUrl);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengaturan API Backend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Endpoint API Backend Server:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'API Base URL',
                hintText: 'https://poswenapidev.nalentora.cloud/api',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
            onPressed: () async {
              await StorageService.saveBaseUrl(urlController.text.trim());
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL API Server diperbarui')),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    const oceanBlue = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title: Silahkan Masuk (JSIndoplastik)
                    const Text(
                      'Silahkan Masuk',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                    const Text(
                      '(JSIndoplastik)',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Field 1: No Telepon
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
                        hintText: '6281234567891',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: oceanBlue, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Field 2: Password
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'xxxxxxxx',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: oceanBlue, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black87,
                          ),
                          onPressed: () {

                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Switch Row: Selalu Ingat
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _rememberMe,
                            activeColor: oceanBlue,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val;
                              });
                            },
                          ),
                        ),
                        const Text(
                          'Selalu Ingat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Action Button: Masuk
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: oceanBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Helper Section: Demo Accounts & API Settings
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pilih Akun Demo API:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.settings, size: 18, color: oceanBlue),
                                tooltip: 'Pengaturan API',
                                onPressed: _showApiSettingsDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.ownerBadge,
                                    side: const BorderSide(color: AppColors.ownerBadge),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _phoneController.text = '6281234567891';
                                      _passwordController.text = 'test_owner';
                                    });
                                  },
                                  child: const Text('Owner', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: oceanBlue,
                                    side: const BorderSide(color: oceanBlue),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _phoneController.text = '6281234567892';
                                      _passwordController.text = 'test_sales';
                                    });
                                  },
                                  child: const Text('Sales', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Switch(
                                value: authProvider.isMockMode,
                                activeColor: oceanBlue,
                                onChanged: (val) {
                                  authProvider.toggleMockMode(val);
                                },
                              ),
                              Text(
                                authProvider.isMockMode ? 'Mode Mock (Demo)' : 'Mode Live API',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
