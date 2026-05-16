import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> riwayatData = [];
  List<Map<String, dynamic>> riwayatPrediksi = [];

  final Box _riwayatBox = Hive.box('riwayat_box');
  final Box _prediksiBox = Hive.box('prediksi_box');
  final Box _pengaturanBox = Hive.box('pengaturan_box');

  List<String> daftarLahan = [];

  DataProvider() {
    _loadData(); // Muat data saat aplikasi pertama kali dibuka
  }

  void _loadData() {
    // Ambil data dari penyimpanan lokal HP
    riwayatData = _riwayatBox.values.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList();
    riwayatPrediksi = _prediksiBox.values.map((e) => Map<String, dynamic>.from(e)).toList().reversed.toList();

    List<dynamic> lahanTersimpan = _pengaturanBox.get('daftar_lahan', defaultValue: ['Lahan A - Tomat Cherry', 'Lahan B - Cabai Rawit']);
    daftarLahan = lahanTersimpan.map((e) => e.toString()).toList();

    notifyListeners();
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

  void tambahDataBaru(String lahan, double kelembapan, String kondisi) {
    // 1. Buat data nyata
    final newData = {
      'lahan': lahan,
      'kelembapan': kelembapan,
      'kondisiVisual': kondisi,
      'waktuCatat': DateTime.now().toIso8601String(),
    };

    // Simpan ke database lokal & list memori
    _riwayatBox.add(newData);
    riwayatData.insert(0, newData);

    // 2. Hitung Prediksi Sore Ini (KHUSUS UNTUK LAHAN YANG DIPILIH)
    double hasilPrediksi = _hitungPrediksiPerLahan(lahan);

    // 3. Simpan data prediksi
    DateTime waktuTarget = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0); 
    // Jika lewat jam 5 sore, prediksi untuk besok sore
    if (DateTime.now().hour >= 17) {
      waktuTarget = waktuTarget.add(const Duration(days: 1));
    }

    final newPrediksi = {
      'lahan': lahan, // <--- SEKARANG PREDIKSI MENYIMPAN NAMA LAHAN
      'nilaiPrediksi': hasilPrediksi,
      'waktuTarget': waktuTarget.toIso8601String(),
    };

    _prediksiBox.add(newPrediksi);
    riwayatPrediksi.insert(0, newPrediksi);

    notifyListeners(); // Refresh seluruh layar!
  }

  // ALGORITMA PREDIKSI YANG SUDAH DIPERBAIKI (PER LAHAN)
  double _hitungPrediksiPerLahan(String namaLahan) {
    // Saring dulu! Hanya ambil riwayat dari lahan yang sedang diinput
    List<Map<String, dynamic>> dataLahanIni = riwayatData.where((item) => item['lahan'] == namaLahan).toList();

    // Jika data lahan ini kurang dari 2, belum bisa lihat tren
    if (dataLahanIni.length < 2) {
      return dataLahanIni.isNotEmpty ? dataLahanIni.first['kelembapan'] : 0.0;
    }

    double totalPenurunan = 0.0;
    int hariValid = 0;

    // Hitung rata-rata penurunan khusus di lahan ini saja
    for (int i = 0; i < dataLahanIni.length - 1; i++) {
      double dataHariIni = dataLahanIni[i]['kelembapan'];
      double dataKemarin = dataLahanIni[i + 1]['kelembapan'];
      double selisih = dataKemarin - dataHariIni;
      if (selisih > 0) { // Hanya hitung saat kelembapan turun
        totalPenurunan += selisih;
        hariValid++;
      }
    }

    double rataRataTurun = (hariValid > 0) ? (totalPenurunan / hariValid) : 5.0;
    double hasil = dataLahanIni.first['kelembapan'] - rataRataTurun;
    return hasil > 0 ? hasil : 0.0;
  }
}