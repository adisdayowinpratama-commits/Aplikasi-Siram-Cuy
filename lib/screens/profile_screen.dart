import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _namaPengguna = 'Petani';
  String _lokasiKebun = 'Kebun Raya'; // Tambahkan variabel lokasi agar bisa diedit juga
  
  final Box _pengaturanBox = Hive.box('pengaturan_box');

  @override
  void initState() {
    super.initState();
    _muatDataProfil();
  }

  // Mengambil data profil yang tersimpan di Hive
  void _muatDataProfil() {
    String? savedUser = _pengaturanBox.get('username');
    String? savedLocation = _pengaturanBox.get('lokasi_kebun', defaultValue: 'Kebun Raya');
    
    if (savedUser != null && savedUser.isNotEmpty) {
      setState(() {
        _namaPengguna = savedUser;
        _lokasiKebun = savedLocation!;
      });
    }
  }

  // --- LOGIKA FORM EDIT PROFIL (POP-UP DIALOG) ---
  void _tampilkanDialogEditProfil() {
    // Controller untuk menangkap input baru, otomatis terisi data lama
    TextEditingController nameController = TextEditingController(text: _namaPengguna);
    TextEditingController locationController = TextEditingController(text: _lokasiKebun);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Profil Anda', 
            style: TextStyle(color: AppColors.darkBlue, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Pengguna', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyText)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: AppColors.bgLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Lokasi / Wilayah Kebun', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyText)),
                const SizedBox(height: 6),
                TextField(
                  controller: locationController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: AppColors.bgLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Batal', style: TextStyle(color: AppColors.greyText))
            ),
            ElevatedButton(
              onPressed: () {
                String namaBaru = nameController.text.trim();
                String lokasiBaru = locationController.text.trim();

                if (namaBaru.isEmpty || lokasiBaru.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama dan Lokasi tidak boleh kosong!'), backgroundColor: Colors.red)
                  );
                  return;
                }

                // 1. Simpan perubahan ke database lokal Hive
                _pengaturanBox.put('username', namaBaru);
                _pengaturanBox.put('lokasi_kebun', lokasiBaru);

                // 2. Perbarui tampilan layar secara langsung
                setState(() {
                  _namaPengguna = namaBaru;
                  _lokasiKebun = lokasiBaru;
                });

                Navigator.pop(context); // Tutup pop-up

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: AppColors.primaryGreen)
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Logika untuk tombol keluar (Logout)
  void _prosesLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar Akun?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: const Text('Sesi Anda akan ditutup dan Anda harus memasukkan password kembali untuk masuk perangkat.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.greyText))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
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
                  const CircleAvatar(
                    radius: 50, 
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(Icons.person, size: 50, color: AppColors.primaryGreen),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _tampilkanDialogEditProfil, // Ketuk ikon kamera juga bisa edit profil
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen, 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Nama & Lokasi dinamis dari Hive
            Text(_namaPengguna, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
            Text('Petani Modern • $_lokasiKebun', style: const TextStyle(color: AppColors.greyText)),
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
                  side: const BorderSide(color: Colors.red),
                  backgroundColor: Colors.red.shade50,
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
      onTap: _tampilkanDialogEditProfil, // SEKARANG MEMANGGIL DIALOG POP-UP EDIT
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
          // --- LOGIKA NAVIGASI BARU ---
          if (title == 'Pengaturan Akun') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          } else if (title == 'Notifikasi') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka Pusat Notifikasi...')));
            // Jika Anda sudah menghubungkan notification_screen.dart sebelumnya, biarkan kode navigasi notifikasi Anda di sini
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membuka $title...')));
          }
        },
      ),
    );
  }
}