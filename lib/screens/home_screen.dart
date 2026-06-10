import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart'; // Wajib untuk grafik mini
import '../theme.dart';
import '../data_provider.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final bool adaData = provider.riwayatData.isNotEmpty;
    final double kelembapanTerakhir = adaData ? provider.riwayatData.first['kelembapan'] : 0.0;
    final String kondisiTerakhir = adaData ? provider.riwayatData.first['kondisiVisual'] : 'Belum Ada Data';
    final bool adaPrediksi = provider.riwayatPrediksi.isNotEmpty;
    final double prediksiSore = adaPrediksi ? provider.riwayatPrediksi.first['nilaiPrediksi'] : 0.0;
    
    // Ambil nama pengguna dari pengaturan
    final String namaPengguna = Hive.box('pengaturan_box').get('username', defaultValue: 'Petani');

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grass, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            const Text('SiramCuy', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Consumer<DataProvider>(
            builder: (context, provider, child) {
              int belumBaca = provider.jumlahBelumBaca;
              return IconButton(
                icon: belumBaca > 0
                    ? Badge(label: Text('$belumBaca'), backgroundColor: Colors.red, child: Icon(Icons.notifications_none, color: context.textMain))
                    : Icon(Icons.notifications_none, color: context.textMain),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
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
            Text('Halo, $namaPengguna!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.textMain)),
            const SizedBox(height: 4),
            Text(adaData ? 'Kebun Anda terlihat $kondisiTerakhir hari ini.' : 'Ayo mulai pantau kebun Anda!', style: TextStyle(color: context.textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            
            // Card Kondisi Saat Ini
            _buildStatusCard(context, kelembapanTerakhir, kondisiTerakhir),
            const SizedBox(height: 16),
            
            
            if (adaData) _buildPredictionCard(context, prediksiSore, provider.riwayatData.first['lahan']),
            if (adaData) const SizedBox(height: 16),
            
            // Card Grafik Mini
            _buildChartCard(context, provider.riwayatData), 
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KOMPONEN ---

  Widget _buildStatusCard(BuildContext context, double kelembapan, String kondisi) {
    Color warnaAksen = kondisi == 'Kering' ? Colors.orange : (kondisi == 'Basah' ? Colors.blue : AppColors.primaryGreen);
    Color bgAksen = kondisi == 'Kering' ? context.orangeBg : (kondisi == 'Basah' ? context.blueBg : context.greenBg);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(color: bgAksen, shape: BoxShape.circle), 
            child: Icon(Icons.water_drop, color: warnaAksen)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KONDISI TERAKHIR', style: TextStyle(fontSize: 10, color: context.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text('${kelembapan.toInt()}% ($kondisi)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.textMain)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, double prediksiSore, String namaLahan) {
    bool bahaya = prediksiSore < 30.0;
    Color warnaAlert = bahaya ? Colors.orange.shade800 : AppColors.primaryGreen;
    Color btnBg = bahaya ? context.orangeBg : context.greenBg;

    return Container(
      decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.border)),
      child: Row(
        children: [
          Container(width: 4, height: bahaya ? 120 : 80, decoration: BoxDecoration(color: warnaAlert, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prediksi Nanti Sore', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textMain)),
                      Text('${prediksiSore.toInt()}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: warnaAlert)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(bahaya ? 'Awas! Lahan diprediksi kering sore ini.' : 'Kelembapan aman hingga sore.', style: TextStyle(color: context.textMuted, fontSize: 13)),
                  if (bahaya) const SizedBox(height: 12),
                  if (bahaya)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.access_time, size: 16, color: Colors.orange.shade800),
                        label: Text('Jadwalkan Siram', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: btnBg, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () async {
                          // 1. Panggil TimePicker Bawaan HP
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            // Opsional: Memastikan tema jam mengikuti tema HP
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );

                          // 2. CEK MOUNTED (Ini yang mencegah error diam di Flutter modern)
                          if (!context.mounted) return;

                          // 3. Jika pengguna memilih jam dan menekan OK
                          if (pickedTime != null) {
                            context.read<DataProvider>().tambahJadwalPenyiraman(
                              namaLahan, 
                              pickedTime.hour, 
                              pickedTime.minute
                            );
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jadwal penyiraman berhasil dikunci!'), 
                                backgroundColor: AppColors.primaryGreen
                              )
                            );
                          }
                        },
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

  Widget _buildChartCard(BuildContext context, List<Map<String, dynamic>> riwayatData) {
    final dataGrafik = riwayatData.take(7).toList().reversed.toList();
    List<FlSpot> titikGrafik = [];
    for (int i = 0; i < dataGrafik.length; i++) {
      titikGrafik.add(FlSpot(i.toDouble(), dataGrafik[i]['kelembapan'].toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tren Singkat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textMain)),
                  Text('7 Data Terakhir', style: TextStyle(fontSize: 12, color: context.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6), 
                decoration: BoxDecoration(color: context.bg, borderRadius: BorderRadius.circular(8)), 
                child: const Icon(Icons.show_chart, color: AppColors.primaryGreen, size: 20)
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: titikGrafik.length < 2
                ? Center(child: Text('Belum cukup data untuk tren', style: TextStyle(color: context.textMuted)))
                : LineChart(
                    LineChartData(
                      minY: 0, maxY: 100,
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: titikGrafik, 
                          isCurved: true, 
                          color: AppColors.primaryGreen, 
                          barWidth: 3, 
                          isStrokeCapRound: true, 
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: context.greenBg),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buka tab Monitor (tengah) untuk detail interaktif.')));
              },
              style: TextButton.styleFrom(backgroundColor: context.bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Lihat Analisis Penuh', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }
}