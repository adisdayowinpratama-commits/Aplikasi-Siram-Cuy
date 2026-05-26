import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _namaPengguna = 'Petani';
  final Box _pengaturanBox = Hive.box('pengaturan_box');

  @override
  void initState() {
    super.initState();
    _muatDataProfil();
  }

  // Mengambil username yang disimpan saat mendaftar/login di awal
  void _muatDataProfil() {
    String? savedUser = _pengaturanBox.get('username');
    if (savedUser != null && savedUser.isNotEmpty) {
      setState(() {
        _namaPengguna = savedUser;
      });
    }
  }

  // Logika untuk tombol keluar
  void _prosesLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar Akun?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: const Text('Sesi Anda akan ditutup dan Anda harus memasukkan password kembali untuk masuk.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Batal', style: TextStyle(color: AppColors.greyText))
            ),
            ElevatedButton(
              onPressed: () {
                // Tutup dialog
                Navigator.pop(context); 
                
                // Hapus semua rute sebelumnya dan kembalikan ke LoginScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // Ini memastikan pengguna tidak bisa menekan tombol "Back" di HP untuk masuk lagi
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // --- HEADER PROFIL ---
            Center(
              child: Stack(
                children: [
                  // Avatar placeholder (bisa diganti foto asli jika nanti ditambahkan fitur kamera)
                  const CircleAvatar(
                    radius: 50, 
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(Icons.person, size: 50, color: AppColors.primaryGreen),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen, 
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Nama pengguna dinamis dari Hive
            Text(_namaPengguna, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
            const Text('Petani Modern • Kebun Raya', style: TextStyle(color: AppColors.greyText)),
            const SizedBox(height: 24),
            
            _buildEditButton(),
            const SizedBox(height: 32),

            // --- MENU LIST ---
            _buildMenuItem(Icons.person_outline, 'Pengaturan Akun'),
            _buildMenuItem(Icons.notifications_none, 'Notifikasi'),
            _buildMenuItem(Icons.help_outline, 'Bantuan & Panduan'),
            
            const Spacer(),
            
            // --- TOMBOL LOGOUT ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton.icon(
                onPressed: _prosesLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Keluar', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Colors.red), // Border merah
                  backgroundColor: Colors.red.shade50, // Latar belakang kemerahan
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---

  Widget _buildEditButton() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur edit profil akan segera hadir!')));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(20)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 14, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('Edit Profil', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.blue.shade800),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.greyText),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membuka $title...')));
        },
      ),
    );
  }
}