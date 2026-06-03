import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data_provider.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Dengarkan perubahan data
    final provider = context.watch<DataProvider>();
    
    // Ambil data terbaru (jika ada)
    final bool adaData = provider.riwayatData.isNotEmpty;
    final double kelembapanTerakhir = adaData ? provider.riwayatData.first['kelembapan'] : 0.0;
    final String kondisiTerakhir = adaData ? provider.riwayatData.first['kondisiVisual'] : 'Belum Ada Data';
    
    final bool adaPrediksi = provider.riwayatPrediksi.isNotEmpty;
    final double prediksiSore = adaPrediksi ? provider.riwayatPrediksi.first['nilaiPrediksi'] : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.grass, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('SiramCuy', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary.withOpacity(0.9), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
  Consumer<DataProvider>(
    builder: (context, provider, child) {
      int belumBaca = provider.jumlahBelumBaca;
      return IconButton(
        icon: belumBaca > 0
            ? Badge(
                label: Text('$belumBaca'),
                backgroundColor: Colors.red,
                child: const Icon(Icons.notifications_none, color: AppColors.darkBlue),
              )
            : const Icon(Icons.notifications_none, color: AppColors.darkBlue),
        onPressed: () {
          // Navigasi ke skrin notifikasi
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
          );
        },
      );
    },
  ),
  const SizedBox(width: 8),
],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Pak Tani!',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              adaData ? 'Kebun Anda terlihat $kondisiTerakhir hari ini.' : 'Ayo mulai pantau kebun Anda!',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Card Kondisi Saat Ini (Dinamis)
            _buildStatusCard(context, kelembapanTerakhir, kondisiTerakhir),
            const SizedBox(height: 16),

            // Card Prediksi (Dinamis, hanya muncul jika sudah ada data)
            if (adaData) _buildPredictionCard(context, prediksiSore),
            if (adaData) const SizedBox(height: 16),

            // Card Grafik Visual Mockup (Dikembalikan seperti semula)
            _buildChartCard(context), 
            const SizedBox(height: 80), // Padding bawah
          ],
        ),
      ),
    );
  }

  // --- Widget Bantuan UI ---

  Widget _buildStatusCard(BuildContext context, double kelembapan, String kondisi) {
    Color warna = kondisi == 'Kering' ? Colors.orange : (kondisi == 'Basah' ? Colors.blue : AppColors.primaryGreen);
    
    return Container(
      
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: warna.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.water_drop, color: warna),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KONDISI TERAKHIR', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text('${kelembapan.toInt()}% ($kondisi)', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, double prediksiSore) {
    bool bahaya = prediksiSore < 30.0;
    Color warnaAlert = bahaya ? Colors.orange.shade800 : AppColors.primaryGreen;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          Container(
            width: 4, 
            height: bahaya ? 120 : 80, // Lebih tinggi jika ada tombol
            decoration: BoxDecoration(color: warnaAlert, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)))
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prediksi Nanti Sore', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text('${prediksiSore.toInt()}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: warnaAlert)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bahaya ? 'Awas! Lahan diprediksi kering sore ini. Siapkan penyiraman.' : 'Kelembapan aman hingga sore.', 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor, fontSize: 13)
                  ),
                  if (bahaya) const SizedBox(height: 12),
                  if (bahaya)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade50, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Jadwalkan Siram', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grafik Kelembapan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Lihat detail di tab Monitor', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.analytics_outlined, color: theme.hintColor, size: 20),
                )
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Buka Tab "Monitor"\nuntuk melihat grafik interaktif',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
