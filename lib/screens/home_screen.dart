import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data_provider.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan data
    final provider = context.watch<DataProvider>();
    
    // Ambil data terbaru (jika ada)
    final bool adaData = provider.riwayatData.isNotEmpty;
    final double kelembapanTerakhir = adaData ? provider.riwayatData.first['kelembapan'] : 0.0;
    final String kondisiTerakhir = adaData ? provider.riwayatData.first['kondisiVisual'] : 'Belum Ada Data';
    
    final bool adaPrediksi = provider.riwayatPrediksi.isNotEmpty;
    final double prediksiSore = adaPrediksi ? provider.riwayatPrediksi.first['nilaiPrediksi'] : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grass, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text('SiramCuy', style: TextStyle(color: AppColors.primaryGreen.withOpacity(0.9), fontWeight: FontWeight.bold)),
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
            const Text(
              'Halo, Pak Tani!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 4),
            Text(
              adaData ? 'Kebun Anda terlihat $kondisiTerakhir hari ini.' : 'Ayo mulai pantau kebun Anda!',
              style: const TextStyle(color: AppColors.greyText, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Card Kondisi Saat Ini (Dinamis)
            _buildStatusCard(kelembapanTerakhir, kondisiTerakhir),
            const SizedBox(height: 16),

            // Card Prediksi (Dinamis, hanya muncul jika sudah ada data)
            if (adaData) _buildPredictionCard(prediksiSore),
            if (adaData) const SizedBox(height: 16),

            // Card Grafik Visual Mockup (Dikembalikan seperti semula)
            _buildChartCard(), 
            const SizedBox(height: 80), // Padding bawah
          ],
        ),
      ),
    );
  }

  // --- Widget Bantuan UI ---

  Widget _buildStatusCard(double kelembapan, String kondisi) {
    Color warna = kondisi == 'Kering' ? Colors.orange : (kondisi == 'Basah' ? Colors.blue : AppColors.primaryGreen);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderGrey)),
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
                const Text('KONDISI TERAKHIR', style: TextStyle(fontSize: 10, color: AppColors.greyText, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text('${kelembapan.toInt()}% ($kondisi)', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(double prediksiSore) {
    bool bahaya = prediksiSore < 30.0;
    Color warnaAlert = bahaya ? Colors.orange.shade800 : AppColors.primaryGreen;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite, 
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
                      const Text('Prediksi Nanti Sore', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                      Text('${prediksiSore.toInt()}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: warnaAlert)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bahaya ? 'Awas! Lahan diprediksi kering sore ini. Siapkan penyiraman.' : 'Kelembapan aman hingga sore.', 
                    style: const TextStyle(color: AppColors.greyText, fontSize: 13)
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

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grafik Kelembapan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                  Text('Lihat detail di tab Monitor', style: TextStyle(fontSize: 12, color: AppColors.greyText)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.analytics_outlined, color: AppColors.greyText, size: 20),
              )
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Buka Tab "Monitor"\nuntuk melihat grafik interaktif',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}