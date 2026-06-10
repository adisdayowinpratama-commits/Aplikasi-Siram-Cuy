import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan), 
        backgroundColor: isError ? Colors.red : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(Icons.grass, color: theme.colorScheme.primary, size: 50),
                ),
                const SizedBox(height: 16),
                Text('SiramCuy', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 48),

                // MENENTUKAN APAKAH MENAMPILKAN KARTU PROFIL ATAU FORM MANUAL
                if (!_tampilkanFormManual && _savedUsername != null) 
                  _buildTampilanAkunTersimpan(theme)
                else 
                  _buildTampilanFormManual(theme),
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
  Widget _buildTampilanAkunTersimpan(ThemeData theme) {
    return Column(
      children: [
        // Kartu Profil (Bisa diklik)
        InkWell(
          onTap: _tampilkanBottomSheetPassword,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.08 : 0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(Icons.person, size: 30, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_savedUsername!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Ketuk untuk masuk', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: theme.hintColor),
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
          icon: Icon(Icons.add, color: theme.colorScheme.primary),
          label: Text('Masuk ke Akun Lain', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
          child: Text('Hapus Akun dari Perangkat', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
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
        final bottomSheetTheme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Menghindari tertutup keyboard
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: bottomSheetTheme.colorScheme.primary.withOpacity(0.15),
                child: Icon(Icons.person, color: bottomSheetTheme.colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text('Masuk sebagai $_savedUsername', style: bottomSheetTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: tempPassController,
                obscureText: true,
                autofocus: true, // Otomatis memunculkan keyboard
                decoration: InputDecoration(
                  hintText: 'Masukkan password Anda',
                  prefixIcon: Icon(Icons.lock_outline, color: bottomSheetTheme.hintColor),
                  filled: true,
                  fillColor: bottomSheetTheme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _prosesLoginDariProfil(tempPassController.text.trim()),
                  style: ElevatedButton.styleFrom(backgroundColor: bottomSheetTheme.colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
  Widget _buildTampilanFormManual(ThemeData theme) {
    return Column(
      children: [
        _buildTextField('Username', 'Masukkan username', Icons.person_outline, _userController, theme: theme),
        const SizedBox(height: 16),
        _buildTextField('Password', 'Masukkan password', Icons.lock_outline, _passController, isPassword: true, theme: theme),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _prosesLoginManual,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
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
            child: Text('Kembali ke Akun Tersimpan', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          )
      ],
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false, required ThemeData theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: theme.hintColor),
            filled: true,
            fillColor: theme.cardColor,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
          ),
        ),
      ],
    );
  }
}