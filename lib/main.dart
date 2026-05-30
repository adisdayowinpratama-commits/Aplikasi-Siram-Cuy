import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'data_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Buka semua kotak database lokal
  await Hive.openBox('riwayat_box');
  await Hive.openBox('prediksi_box');
  await Hive.openBox('pengaturan_box');
  await Hive.openBox('notifikasi_box');

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
    // Dengarkan perubahan status Dark Mode
    final isDark = context.watch<DataProvider>().isDarkMode;

    return MaterialApp(
      title: 'SiramCuy',
      theme: AppTheme.lightTheme, // Tema Terang
      darkTheme: AppTheme.darkTheme, // Tema Gelap
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light, // Penentu otomatis
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}