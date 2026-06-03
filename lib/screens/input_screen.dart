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
    final theme = Theme.of(context);
    final provider = context.watch<DataProvider>();
    final daftarLahan = provider.daftarLahan;

    // Pastikan _lahanTerpilih selalu valid (tidak error jika lahan yang dipilih dihapus)
    if (_lahanTerpilih == null || !daftarLahan.contains(_lahanTerpilih)) {
      _lahanTerpilih = daftarLahan.isNotEmpty ? daftarLahan.first : null;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Input Data Manual', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan data kondisi lahan terkini untuk kalibrasi sistem.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 32),
            
            // --- BAGIAN PILIH LAHAN DINAMIS ---
            _buildLabel(context, 'PILIH LAHAN'),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _lahanTerpilih,
                    decoration: _inputDecoration(context),
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
                  decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
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
                _buildLabel(context, 'PERSENTASE KELEMBAPAN'),
                Text('${_kelembapan.toInt()}%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            Slider(
              value: _kelembapan,
              max: 100,
              divisions: 100,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) => setState(() => _kelembapan = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('0%', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)), Text('100%', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))],
            ),
            const SizedBox(height: 32),

            // Kondisi Tanah Visual
            _buildLabel(context, 'KONDISI TANAH VISUAL'),
            Row(
              children: [
                _buildChoiceChip(context, 'Kering', Colors.orange),
                const SizedBox(width: 10),
                _buildChoiceChip(context, 'Lembap', Colors.blue),
                const SizedBox(width: 10),
                _buildChoiceChip(context, 'Basah', AppColors.primaryGreen),
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Data berhasil disimpan!'), backgroundColor: theme.colorScheme.primary));
                  setState(() { _kelembapan = 65.0; _kondisiTerpilih = 'Lembap'; });
                },
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text('Simpan Data', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Tambah Lahan Baru', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Misal: Lahan C - Singkong', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: theme.colorScheme.primary))),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  provider.tambahLahan(controller.text);
                  setState(() => _lahanTerpilih = controller.text.trim()); // Otomatis pilih lahan yang baru dibuat
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
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
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Hapus Lahan?', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin menghapus "$namaLahan" dari daftar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: theme.colorScheme.primary))),
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

  Widget _buildLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, color: theme.hintColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecoration(
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
    );
  }

  Widget _buildChoiceChip(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);
    bool isSelected = _kondisiTerpilih == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _kondisiTerpilih = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: isSelected ? color.withOpacity(0.1) : theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? color : theme.dividerColor)),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? color : theme.hintColor, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}