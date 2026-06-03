import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../data_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Variabel penyimpan filter yang dipilih
  String _selectedLahan = 'Semua Lahan';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DataProvider>();
    
    // Siapkan daftar opsi filter
    List<String> opsiLahan = ['Semua Lahan', ...provider.daftarLahan];
    
    // Cegah error jika lahan dihapus
    if (!opsiLahan.contains(_selectedLahan)) {
      _selectedLahan = 'Semua Lahan';
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.cardColor,
          elevation: 0,
          title: Text('Riwayat Data', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.hintColor,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.edit_document), text: 'Input Nyata'),
              Tab(icon: Icon(Icons.auto_graph), text: 'Prediksi AI'),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- BAGIAN FILTER UI ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: theme.cardColor,
              child: Row(
                children: [
                  Icon(Icons.filter_alt_outlined, color: theme.hintColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedLahan,
                        icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        items: opsiLahan.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLahan = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: theme.dividerColor),

            // --- TAB KONTEN ---
            Expanded(
              child: TabBarView(
                children: [
                  _buildListInput(provider.riwayatData),
                  _buildListPrediksi(provider.riwayatPrediksi),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget List untuk Tab 1: Input Nyata
  Widget _buildListInput(List<Map<String, dynamic>> riwayatAsli) {
    // Terapkan Filter
    final filteredData = riwayatAsli.where((item) {
      return _selectedLahan == 'Semua Lahan' || item['lahan'] == _selectedLahan;
    }).toList();

    if (filteredData.isEmpty) {
      return Center(child: Text('Belum ada data pada "$_selectedLahan".', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        DateTime waktu = DateTime.parse(item['waktuCatat']);
        String formatWaktu = DateFormat('dd MMM yyyy, HH:mm').format(waktu);
        
        return _buildCard(
          nilai: '${item['kelembapan'].toInt()}%',
          namaLahan: item['lahan'] ?? 'Lahan Tidak Diketahui', // Menampilkan nama lahan
          waktu: formatWaktu,
          status: item['kondisiVisual'],
          ikon: Icons.water_drop,
          warna: item['kondisiVisual'] == 'Kering' ? Colors.orange : AppColors.primaryGreen,
        );
      },
    );
  }

  // Widget List untuk Tab 2: Prediksi
  Widget _buildListPrediksi(List<Map<String, dynamic>> riwayatPrediksi) {
    // Catatan: Karena di kode awal data prediksi tidak menyimpan nama lahan,
    // Kita buat logic fallback agar aplikasi tidak error untuk data prediksi yang sudah lama.
    final filteredData = riwayatPrediksi.where((item) {
      if (!item.containsKey('lahan')) return true; // Munculkan saja jika data prediksi belum punya info lahan
      return _selectedLahan == 'Semua Lahan' || item['lahan'] == _selectedLahan;
    }).toList();

    if (filteredData.isEmpty) {
      return Center(child: Text('Belum ada data prediksi.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        DateTime waktuTarget = DateTime.parse(item['waktuTarget']);
        String formatWaktu = 'Untuk: ${DateFormat('dd MMM yyyy, HH:mm').format(waktuTarget)}';
        
        return _buildCard(
          nilai: '${item['nilaiPrediksi'].toInt()}%',
          namaLahan: item.containsKey('lahan') ? item['lahan'] : 'Sistem Prediksi Global', 
          waktu: formatWaktu,
          status: 'Otomatis',
          ikon: Icons.online_prediction,
          warna: Colors.purple,
        );
      },
    );
  }

  // Desain Kartu (Ditambah info namaLahan)
  Widget _buildCard({
    required String nilai, 
    required String namaLahan, 
    required String waktu, 
    required String status, 
    required IconData ikon, 
    required Color warna
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: theme.dividerColor)
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10), 
            decoration: BoxDecoration(color: warna.withOpacity(0.1), shape: BoxShape.circle), 
            child: Icon(ikon, color: warna, size: 20)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(nilai, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    // Menampilkan Nama Lahan secara ringkas di pojok kanan atas
                    Expanded(
                      child: Text(
                        namaLahan, 
                        textAlign: TextAlign.right, 
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(waktu, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: warna.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: warna, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}