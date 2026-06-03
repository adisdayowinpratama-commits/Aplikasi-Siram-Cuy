import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../data_provider.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  // 1. Variabel untuk menyimpan filter yang sedang dipilih
  String _selectedLahan = 'Semua Lahan';
  String _selectedRentang = '7 Hari Terakhir';

  // 2. Pilihan rentang waktu yang tersedia
  final List<String> _opsiRentang = ['7 Hari Terakhir', '30 Hari Terakhir', 'Semua Waktu'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ambil data mentah dari provider
    final provider = context.watch<DataProvider>();
    
    // Siapkan daftar lahan (Tambahkan opsi "Semua Lahan" di urutan paling atas)
    List<String> opsiLahan = ['Semua Lahan', ...provider.daftarLahan];
    
    // Mencegah error jika lahan yang dipilih sebelumnya ternyata sudah dihapus
    if (!opsiLahan.contains(_selectedLahan)) {
      _selectedLahan = 'Semua Lahan';
    }

    // --- LOGIKA FILTER DATA ---
    List<Map<String, dynamic>> filteredData = provider.riwayatData.where((item) {
      // Filter 1: Cerdas mengecek Lahan
      bool matchLahan = (_selectedLahan == 'Semua Lahan') || (item['lahan'] == _selectedLahan);
      
      // Filter 2: Mengecek Rentang Waktu
      DateTime waktuCatat = DateTime.parse(item['waktuCatat']);
      DateTime sekarang = DateTime.now();
      bool matchWaktu = true;
      
      if (_selectedRentang == '7 Hari Terakhir') {
        matchWaktu = waktuCatat.isAfter(sekarang.subtract(const Duration(days: 7)));
      } else if (_selectedRentang == '30 Hari Terakhir') {
        matchWaktu = waktuCatat.isAfter(sekarang.subtract(const Duration(days: 30)));
      } // Jika "Semua Waktu", matchWaktu tetap true

      return matchLahan && matchWaktu;
    }).toList();

    // --- LOGIKA PERHITUNGAN STATISTIK DARI DATA YANG DIFILTER ---
    int rataRata = 0;
    int jumlahSiram = 0;

    // Balik data agar urutannya dari lama ke baru (dari kiri ke kanan di grafik)
    // Batasi 30 titik data saja agar grafik tidak terlalu menumpuk/error jika datanya ratusan
    List<Map<String, dynamic>> dataGrafik = filteredData.take(30).toList().reversed.toList();

    if (dataGrafik.isNotEmpty) {
      double total = 0;
      for (var item in dataGrafik) {
        total += item['kelembapan'];
        if (item['kondisiVisual'] == 'Basah') jumlahSiram++;
      }
      rataRata = (total / dataGrafik.length).toInt();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Ringkasan Data', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- FILTER DROPDOWN DINAMIS ---
            Row(
              children: [
                Expanded(child: _buildFilterLahan(context, opsiLahan)),
                const SizedBox(width: 12),
                Expanded(child: _buildFilterRentang(context)),
              ],
            ),
            const SizedBox(height: 24),
            
            // --- TREN CHART CARD ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tren Kelembapan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildLegend(context),
                  const SizedBox(height: 24),
                  
                  // GRAFIK FL_CHART
                  SizedBox(
                    height: 200,
                    child: dataGrafik.isEmpty
                        ? Center(child: Text('Belum ada data pada filter ini.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)))
                        : _buildLineChart(dataGrafik, provider.riwayatPrediksi),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- STATS CARDS ---
            Row(
              children: [
                Expanded(child: _buildStatItem(context, 'Rata-rata', '$rataRata%', 'Dari data terpilih', AppColors.primaryGreen)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatItem(context, 'Penyiraman', '$jumlahSiram kali', 'Berdasarkan data', Colors.blue)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET FILTER DROPDOWN (KINI BERFUNGSI) ---

  Widget _buildFilterLahan(BuildContext context, List<String> opsiLahan) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Zona Terpilih', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedLahan,
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.hintColor),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
              items: opsiLahan.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLahan = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRentang(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Rentang Waktu', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedRentang,
              icon: Icon(Icons.calendar_today_outlined, size: 14, color: theme.hintColor),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
              items: _opsiRentang.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedRentang = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI MENGGAMBAR GRAFIK ---
  Widget _buildLineChart(List<Map<String, dynamic>> dataNyata, List<Map<String, dynamic>> dataPrediksi) {
    List<FlSpot> titikNyata = [];
    
    for (int i = 0; i < dataNyata.length; i++) {
      titikNyata.add(FlSpot(i.toDouble(), dataNyata[i]['kelembapan'].toDouble()));
    }

    List<FlSpot> titikPrediksi = [];
    if (dataNyata.isNotEmpty && dataPrediksi.isNotEmpty) {
      double xTerakhir = (dataNyata.length - 1).toDouble();
      double yTerakhir = dataNyata.last['kelembapan'].toDouble();
      
      titikPrediksi.add(FlSpot(xTerakhir, yTerakhir)); 
      titikPrediksi.add(FlSpot(xTerakhir + 1, dataPrediksi.first['nilaiPrediksi'].toDouble())); 
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == dataNyata.length.toDouble()) {
                  return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Sore', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)));
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: titikNyata,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          if (titikPrediksi.isNotEmpty)
            LineChartBarData(
              spots: titikPrediksi,
              isCurved: false,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dashArray: [5, 5],
              dotData: const FlDotData(show: true),
            ),
        ],
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---
  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      children: [
        _LegendItem(color: theme.colorScheme.primary, text: 'Data Nyata'),
        const _LegendItem(color: Colors.orange, text: 'Prediksi Sistem'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String val, String sub, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          Text(val, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(sub, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
      ],
    );
  }
}