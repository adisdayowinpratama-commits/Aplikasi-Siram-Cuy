import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> riwayatData = [];
  List<Map<String, dynamic>> riwayatPrediksi = [];
  List<Map<String, dynamic>> riwayatNotifikasi = []; // <-- Simpan data notifikasi

  final Box _riwayatBox = Hive.box('riwayat_box');
  final Box _prediksiBox = Hive.box('prediksi_box');
  final Box _pengaturanBox = Hive.box('pengaturan_box');
  final Box _notifikasiBox = Hive.box('notifikasi_box'); // <-- Box notifikasi

  List<String> daftarLahan = [];

  DataProvider() {
    _loadData();
  }

  void _loadData() {
    riwayatData = _riwayatBox.values.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList();
    riwayatPrediksi = _prediksiBox.values.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList();
    riwayatNotifikasi = _notifikasiBox.values.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList(); // <-- Muat notifikasi
    
    List<dynamic> lahanTersimpan = _pengaturanBox.get('daftar_lahan', defaultValue: ['Lahan A - Tomat Cherry', 'Lahan B - Cabai Rawit']);
    daftarLahan = lahanTersimpan.map((e) => e.toString()).toList();

    notifyListeners();
  }

  // --- LOGIKA PENGURUSAN NOTIFIKASI ---
  int get jumlahBelumBaca => riwayatNotifikasi.where((e) => e['isRead'] == false).length;

  void bacaSemuaNotifikasi() {
    for (int i = 0; i < _notifikasiBox.length; i++) {
      var item = Map<String, dynamic>.from(_notifikasiBox.getAt(i));
      item['isRead'] = true;
      _notifikasiBox.putAt(i, item);
    }
    _loadData();
  }

  void padamSemuaNotifikasi() {
    _notifikasiBox.clear();
    _loadData();
  }

  // --- LOGIKA INPUT DATA & PREDIKSI ---
  void tambahDataBaru(String lahan, double kelembapan, String kondisi) {
    final newData = {
      'lahan': lahan,
      'kelembapan': kelembapan,
      'kondisiVisual': kondisi,
      'waktuCatat': DateTime.now().toIso8601String(),
    };

    _riwayatBox.add(newData);
    riwayatData.insert(0, newData);

    double hasilPrediksi = _hitungPrediksiPerLahan(lahan);

    DateTime waktuTarget = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0); 
    if (DateTime.now().hour >= 17) {
      waktuTarget = waktuTarget.add(const Duration(days: 1));
    }

    final newPrediksi = {
      'lahan': lahan,
      'nilaiPrediksi': hasilPrediksi,
      'waktuTarget': waktuTarget.toIso8601String(),
    };

    _prediksiBox.add(newPrediksi);
    riwayatPrediksi.insert(0, newPrediksi);

    // --- LOGIKA PENJANAAN NOTIFIKASI OTOMATIS ---
    Map<String, dynamic> newNotif;
    if (hasilPrediksi < 30.0) {
      newNotif = {
        'judul': 'Peringatan Kekeringan!',
        'pesan': '$lahan diramal kering (${hasilPrediksi.toInt()}%) nanti sore. Sila sediakan penyiraman!',
        'waktu': DateTime.now().toIso8601String(),
        'isRead': false,
        'tipe': 'bahaya'
      };
    } else {
      newNotif = {
        'judul': 'Data Berhasil Disimpan',
        'pesan': 'Data baru untuk $lahan direkodkan. Ramalan sore ini dalam keadaan selamat (${hasilPrediksi.toInt()}%).',
        'waktu': DateTime.now().toIso8601String(),
        'isRead': false,
        'tipe': 'info'
      };
    }
    _notifikasiBox.add(newNotif);
    riwayatNotifikasi.insert(0, newNotif);

    notifyListeners();
  }

  double _hitungPrediksiPerLahan(String namaLahan) {
    List<Map<String, dynamic>> dataLahanIni = riwayatData.where((item) => item['lahan'] == namaLahan).toList();
    if (dataLahanIni.length < 2) return dataLahanIni.isNotEmpty ? dataLahanIni.first['kelembapan'] : 0.0;

    double totalPenurunan = 0.0;
    int hariValid = 0;

    for (int i = 0; i < dataLahanIni.length - 1; i++) {
      double dataHariIni = dataLahanIni[i]['kelembapan'];
      double dataKemarin = dataLahanIni[i + 1]['kelembapan'];
      double selisih = dataKemarin - dataHariIni;
      if (selisih > 0) {
        totalPenurunan += selisih;
        hariValid++;
      }
    }

    double rataRataTurun = (hariValid > 0) ? (totalPenurunan / hariValid) : 5.0;
    double hasil = dataLahanIni.first['kelembapan'] - rataRataTurun;
    return hasil > 0 ? hasil : 0.0;
  }

  void tambahLahan(String namaLahan) {
    if (namaLahan.trim().isNotEmpty && !daftarLahan.contains(namaLahan.trim())) {
      daftarLahan.add(namaLahan.trim());
      _pengaturanBox.put('daftar_lahan', daftarLahan);
      notifyListeners();
    }
  }

  void hapusLahan(String namaLahan) {
    if (daftarLahan.length > 1) {
      daftarLahan.remove(namaLahan);
      _pengaturanBox.put('daftar_lahan', daftarLahan);
      notifyListeners();
    }
  }

  // --- FUNGSI RESET DATA MUSIM TANAM ---
  void resetSemuaData() {
    _riwayatBox.clear();
    _prediksiBox.clear();
    _notifikasiBox.clear();
    
    riwayatData.clear();
    riwayatPrediksi.clear();
    riwayatNotifikasi.clear();
    
    notifyListeners();
  }

  // --- LOGIKA DARK MODE ---
  // Baca status tema dari Hive (default: false / terang)
  bool get isDarkMode => _pengaturanBox.get('is_dark_mode', defaultValue: false);

  void toggleTema(bool modeGelap) {
    _pengaturanBox.put('is_dark_mode', modeGelap);
    notifyListeners(); // Refresh seluruh aplikasi agar tema berubah seketika
  }
}