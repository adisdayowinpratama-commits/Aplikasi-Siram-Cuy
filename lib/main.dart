import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'data_provider.dart';
import 'screens/login_screen.dart'; // <-- HATI-HATI, PASTIKAN BARIS IMPORT INI ADA

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Buka semua kotak database lokal
  await Hive.openBox('riwayat_box');
  await Hive.openBox('prediksi_box');
  await Hive.openBox('pengaturan_box');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const SiramCuyApp(),
    ),
  );
}

class SiramCuyApp extends StatelessWidget {
  const SiramCuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiramCuy',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), // Widget ini sekarang diambil dari screens/login_screen.dart
    );
  }
}