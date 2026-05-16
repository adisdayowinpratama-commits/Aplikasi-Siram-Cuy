import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_provider.dart';
import '../theme.dart';


class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  double _kelembapan = 65.0;
  String _kondisiTerpilih = 'Lembap';
  String? _lahanTerpilih; // Ubah jadi nullable agar bisa merespons perubahan dinamis

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final daftarLahan = provider.daftarLahan;

    // Pastikan _lahanTerpilih selalu valid (tidak error jika lahan yang dipilih dihapus)
    if (_lahanTerpilih == null || !daftarLahan.contains(_lahanTerpilih)) {
      _lahanTerpilih = daftarLahan.isNotEmpty ? daftarLahan.first : null;
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: const Text('Input Data Manual', style: TextStyle(color: AppColors.darkBlue, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan data kondisi lahan terkini untuk kalibrasi sistem.', style: TextStyle(color: AppColors.greyText)),
            const SizedBox(height: 32),
            
            // --- BAGIAN PILIH LAHAN DINAMIS ---
            _buildLabel('PILIH LAHAN'),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _lahanTerpilih,
                    decoration: _inputDecoration(),
                    isExpanded: true, // Mencegah teks kepanjangan error
                    items: daftarLahan.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _lahanTerpilih = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Tambah Lahan
                Container(
                  decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _tampilkanDialogTambahLahan(context, provider),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Hapus Lahan
                Container(
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      if (daftarLahan.length <= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimal harus ada 1 lahan tersisa!')));
                        return;
                      }
                      _tampilkanDialogHapus(context, provider, _lahanTerpilih!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // --- AKHIR BAGIAN PILIH LAHAN ---

            // Slider Kelembapan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('PERSENTASE KELEMBAPAN'),
                Text('${_kelembapan.toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ],
            ),
            Slider(
              value: _kelembapan,
              max: 100,
              divisions: 100,
              activeColor: AppColors.primaryGreen,
              onChanged: (val) => setState(() => _kelembapan = val),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('0%', style: TextStyle(color: AppColors.greyText)), Text('100%', style: TextStyle(color: AppColors.greyText))],
            ),
            const SizedBox(height: 32),

            // Kondisi Tanah Visual
            _buildLabel('KONDISI TANAH VISUAL'),
            Row(
              children: [
                _buildChoiceChip('Kering', Colors.orange),
                const SizedBox(width: 10),
                _buildChoiceChip('Lembap', Colors.blue),
                const SizedBox(width: 10),
                _buildChoiceChip('Basah', AppColors.primaryGreen),
              ],
            ),
            const SizedBox(height: 48),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_lahanTerpilih == null) return;
                  context.read<DataProvider>().tambahDataBaru(_lahanTerpilih!, _kelembapan, _kondisiTerpilih);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan!'), backgroundColor: AppColors.primaryGreen));
                  setState(() { _kelembapan = 65.0; _kondisiTerpilih = 'Lembap'; });
                },
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text('Simpan Data', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- POPUP DIALOG TAMBAH LAHAN ---
  void _tampilkanDialogTambahLahan(BuildContext context, DataProvider provider) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Lahan Baru', style: TextStyle(color: AppColors.darkBlue, fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Misal: Lahan C - Singkong', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.greyText))),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  provider.tambahLahan(controller.text);
                  setState(() => _lahanTerpilih = controller.text.trim()); // Otomatis pilih lahan yang baru dibuat
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: const Text('Tambah', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- POPUP DIALOG KONFIRMASI HAPUS ---
  void _tampilkanDialogHapus(BuildContext context, DataProvider provider, String namaLahan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Lahan?', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus "$namaLahan" dari daftar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.greyText))),
            ElevatedButton(
              onPressed: () {
                provider.hapusLahan(namaLahan);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.greyText, fontWeight: FontWeight.bold, letterSpacing: 1)),
  );

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true,
    fillColor: Colors.blue.shade50.withOpacity(0.3),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGrey)),
  );

  Widget _buildChoiceChip(String label, Color color) {
    bool isSelected = _kondisiTerpilih == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _kondisiTerpilih = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? color : AppColors.borderGrey)),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? color : AppColors.greyText, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}