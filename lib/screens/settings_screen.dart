import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Box _pengaturanBox = Hive.box('pengaturan_box');

  // --- LOGIKA UBAH PASSWORD ---
  void _tampilkanDialogUbahPassword() {
    TextEditingController passLama = TextEditingController();
    TextEditingController passBaru = TextEditingController();
    TextEditingController passKonfirmasi = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ubah Password', style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPasswordField('Password Lama', passLama),
                const SizedBox(height: 12),
                _buildPasswordField('Password Baru', passBaru),
                const SizedBox(height: 12),
                _buildPasswordField('Konfirmasi Password Baru', passKonfirmasi),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.greyText))),
            ElevatedButton(
              onPressed: () {
                String savedPass = _pengaturanBox.get('password');

                if (passLama.text != savedPass) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password lama salah!'), backgroundColor: Colors.red));
                  return;
                }
                if (passBaru.text != passKonfirmasi.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi password tidak cocok!'), backgroundColor: Colors.red));
                  return;
                }
                if (passBaru.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru tidak boleh kosong!'), backgroundColor: Colors.red));
                  return;
                }

                // Simpan password baru
                _pengaturanBox.put('password', passBaru.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah!'), backgroundColor: AppColors.primaryGreen));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- LOGIKA RESET DATA APLIKASI ---
  void _tampilkanDialogResetData() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Mulai Musim Tanam Baru?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: const Text(
            'Tindakan ini akan menghapus SEMUA riwayat kelembapan, prediksi, dan notifikasi Anda secara permanen. '
            'Profil dan daftar lahan Anda akan tetap aman.\n\nLanjutkan?',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.greyText))),
            ElevatedButton(
              onPressed: () {
                // Panggil fungsi reset dari Provider
                context.read<DataProvider>().resetSemuaData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua riwayat data berhasil dikosongkan!'), backgroundColor: AppColors.primaryGreen));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ya, Hapus Data', style: TextStyle(color: Colors.white)),
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
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
        elevation: 0,
        title: const Text('Pengaturan Akun', style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- TAMBAHAN UNTUK DARK MODE ---
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8, top: 16),
            child: Text('TAMPILAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyText, letterSpacing: 1)),
          ),
          Consumer<DataProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: provider.isDarkMode ? Colors.grey.shade900 : AppColors.surfaceWhite, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: provider.isDarkMode ? Colors.grey.shade800 : AppColors.borderGrey)
                ),
                child: SwitchListTile(
                  title: Text('Mode Gelap', style: TextStyle(fontWeight: FontWeight.w600, color: provider.isDarkMode ? Colors.white : AppColors.darkBlue)),
                  subtitle: Text('Gunakan tema gelap', style: TextStyle(fontSize: 12, color: provider.isDarkMode ? Colors.grey.shade400 : AppColors.greyText)),
                  value: provider.isDarkMode,
                  activeColor: AppColors.primaryGreen,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: provider.isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50, 
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Icon(Icons.dark_mode_outlined, color: provider.isDarkMode ? Colors.yellow : Colors.blue.shade800),
                  ),
                  onChanged: (bool value) {
                    provider.toggleTema(value);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
            //-- AKHIR TAMBAHAN DARK MODE ---
            
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text('KEAMANAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyText, letterSpacing: 1)),
          ),
          _buildSettingsItem(Icons.lock_outline, 'Ubah Password', 'Ganti kata sandi untuk masuk aplikasi', onTap: _tampilkanDialogUbahPassword),
          
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text('MANAJEMEN DATA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyText, letterSpacing: 1)),
          ),
          _buildSettingsItem(Icons.delete_forever_outlined, 'Reset Data Musim Tanam', 'Hapus semua grafik dan riwayat tanah', isDanger: true, onTap: _tampilkanDialogResetData),
          
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text('TENTANG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyText, letterSpacing: 1)),
          ),
          _buildSettingsItem(Icons.info_outline, 'Versi Aplikasi', 'SiramCuy v1.0.0 (Offline Mode)', hasArrow: false),
        ],
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, {bool isDanger = false, bool hasArrow = true, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderGrey)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: isDanger ? Colors.red.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: isDanger ? Colors.red : Colors.blue.shade800),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDanger ? Colors.red : AppColors.darkBlue)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.greyText)),
        trailing: hasArrow ? const Icon(Icons.chevron_right, color: AppColors.greyText) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.greyText, fontSize: 14),
        filled: true,
        fillColor: AppColors.bgLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}