import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final Box _pengaturanBox = Hive.box('pengaturan_box');
  
  String? _savedUsername;
  bool _tampilkanFormManual = true; // Mode tampilan: Form atau Kartu Profil FB

  @override
  void initState() {
    super.initState();
    _cekStatusLogin();
  }

  void _cekStatusLogin() {
    String? user = _pengaturanBox.get('username');
    if (user != null && user.isNotEmpty) {
      setState(() {
        _savedUsername = user;
        _tampilkanFormManual = false; // Tampilkan gaya FB karena sudah ada akun
      });
    }
  }

  void _masukKeBeranda() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  // Fungsi Login untuk Form Manual (Akun Baru / Akun Lain)
  void _prosesLoginManual() {
    String inputUser = _userController.text.trim();
    String inputPass = _passController.text.trim();

    if (inputUser.isEmpty || inputPass.isEmpty) {
      _tampilkanPesan('Username dan Password tidak boleh kosong!', isError: true);
      return;
    }

    // Simpan/Timpa akun lokal
    _pengaturanBox.put('username', inputUser);
    _pengaturanBox.put('password', inputPass);
    _masukKeBeranda();
  }

  // Fungsi Login untuk Kartu Profil (Gaya FB)
  void _prosesLoginDariProfil(String inputPass) {
    String savedPass = _pengaturanBox.get('password');

    if (inputPass == savedPass) {
      Navigator.pop(context); // Tutup BottomSheet
      _masukKeBeranda();
    } else {
      _tampilkanPesan('Password salah! Coba lagi.', isError: true);
    }
  }

  void _tampilkanPesan(String pesan, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan), 
        backgroundColor: isError ? Colors.red : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Aplikasi di Atas (Gaya FB)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.grass, color: AppColors.primaryGreen, size: 50),
                ),
                const SizedBox(height: 16),
                const Text('SiramCuy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                const SizedBox(height: 48),

                // MENENTUKAN APAKAH MENAMPILKAN KARTU PROFIL ATAU FORM MANUAL
                if (!_tampilkanFormManual && _savedUsername != null) 
                  _buildTampilanAkunTersimpan()
                else 
                  _buildTampilanFormManual(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. TAMPILAN GAYA FACEBOOK (AKUN TERSIMPAN)
  // ==========================================
  Widget _buildTampilanAkunTersimpan() {
    return Column(
      children: [
        // Kartu Profil (Bisa diklik)
        InkWell(
          onTap: _tampilkanBottomSheetPassword,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(Icons.person, size: 30, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_savedUsername!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                      const Text('Ketuk untuk masuk', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: AppColors.greyText),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Tombol Masuk ke Akun Lain
        TextButton.icon(
          onPressed: () {
            setState(() {
              _tampilkanFormManual = true; // Beralih ke mode Form
              _userController.clear();
              _passController.clear();
            });
          },
          icon: const Icon(Icons.add, color: AppColors.primaryGreen),
          label: const Text('Masuk ke Akun Lain', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
        ),
        
        // Tombol Hapus Akun Tersimpan (Opsional UX FB)
        TextButton(
          onPressed: () {
            _pengaturanBox.delete('username');
            _pengaturanBox.delete('password');
            setState(() {
              _savedUsername = null;
              _tampilkanFormManual = true;
            });
            _tampilkanPesan('Akun dari perangkat ini telah dihapus.');
          },
          child: const Text('Hapus Akun dari Perangkat', style: TextStyle(color: AppColors.greyText, fontSize: 12)),
        )
      ],
    );
  }

  // Bottom Sheet untuk Input Password saat Kartu Profil diklik
  void _tampilkanBottomSheetPassword() {
    TextEditingController tempPassController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar form naik saat keyboard muncul
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Menghindari tertutup keyboard
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.lightGreen,
                child: Icon(Icons.person, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 12),
              Text('Masuk sebagai $_savedUsername', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
              const SizedBox(height: 24),
              TextField(
                controller: tempPassController,
                obscureText: true,
                autofocus: true, // Otomatis memunculkan keyboard
                decoration: InputDecoration(
                  hintText: 'Masukkan password Anda',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _prosesLoginDariProfil(tempPassController.text.trim()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  // ==========================================
  // 2. TAMPILAN FORM MANUAL (AKUN BARU / LAIN)
  // ==========================================
  Widget _buildTampilanFormManual() {
    return Column(
      children: [
        _buildTextField('Username', 'Masukkan username', Icons.person_outline, _userController),
        const SizedBox(height: 16),
        _buildTextField('Password', 'Masukkan password', Icons.lock_outline, _passController, isPassword: true),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _prosesLoginManual,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 24),
        
        // Tombol Kembali ke Profil Tersimpan (Jika ada)
        if (_savedUsername != null)
          TextButton(
            onPressed: () {
              setState(() {
                _tampilkanFormManual = false;
              });
            },
            child: const Text('Kembali ke Akun Tersimpan', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          )
      ],
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade400),
            filled: true,
            fillColor: AppColors.surfaceWhite,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGrey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen)),
          ),
        ),
      ],
    );
  }
}