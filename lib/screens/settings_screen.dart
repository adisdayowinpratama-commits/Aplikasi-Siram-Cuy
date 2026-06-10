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
                _buildPasswordField(context, 'Password Lama', passLama),
                const SizedBox(height: 12),
                _buildPasswordField(context, 'Password Baru', passBaru),
                const SizedBox(height: 12),
                _buildPasswordField(context, 'Konfirmasi Password Baru', passKonfirmasi),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        iconTheme: theme.appBarTheme.iconTheme,
        elevation: 0,
        title: Text('Pengaturan Akun', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- TAMBAHAN UNTUK DARK MODE ---
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
            child: Text('TAMPILAN', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          Consumer<DataProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: SwitchListTile(
                  title: Text('Mode Gelap', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Gunakan tema gelap', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  value: provider.isDarkMode,
                  activeThumbColor: theme.colorScheme.primary,
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
          _buildSettingsItem(context, Icons.lock_outline, 'Ubah Password', 'Ganti kata sandi untuk masuk aplikasi', onTap: _tampilkanDialogUbahPassword),
          
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text('MANAJEMEN DATA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyText, letterSpacing: 1)),
          ),
          _buildSettingsItem(context, Icons.delete_forever_outlined, 'Reset Data Musim Tanam', 'Hapus semua grafik dan riwayat tanah', isDanger: true, onTap: _tampilkanDialogResetData),
          
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text('TENTANG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyText, letterSpacing: 1)),
          ),
          _buildSettingsItem(context, Icons.info_outline, 'Versi Aplikasi', 'SiramCuy v1.0.0 (Offline Mode)', hasArrow: false),
        ],
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String subtitle, {bool isDanger = false, bool hasArrow = true, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: isDanger ? Colors.red.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: isDanger ? Colors.red : Colors.blue.shade800),
        ),
        title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: isDanger ? Colors.red : theme.colorScheme.onSurface)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: hasArrow ? Icon(Icons.chevron_right, color: theme.hintColor) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context, String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}