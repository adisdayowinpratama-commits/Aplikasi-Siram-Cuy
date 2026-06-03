import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../data_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Otomatis tandai semua sudah dibaca saat membuka layar ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().bacaSemuaNotifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DataProvider>();
    final listNotif = provider.riwayatNotifikasi;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        iconTheme: theme.appBarTheme.iconTheme,
        elevation: 0,
        title: Text('Pusat Notifikasi', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          if (listNotif.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () {
                provider.padamSemuaNotifikasi();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua notifikasi dipadam')));
              },
            )
        ],
      ),
      body: listNotif.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text('Tiada notifikasi baru.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listNotif.length,
              itemBuilder: (context, index) {
                final item = listNotif[index];
                DateTime waktu = DateTime.parse(item['waktu']);
                String formatWaktu = DateFormat('dd MMM, HH:mm').format(waktu);
                bool isBahaya = item['tipe'] == 'bahaya';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: item['isRead'] ? theme.cardColor : Colors.blue.shade50.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: item['isRead'] ? theme.dividerColor : Colors.blue.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: isBahaya ? Colors.orange.shade50 : AppColors.lightGreen,
                        child: Icon(
                          isBahaya ? Icons.warning_amber_rounded : Icons.info_outline,
                          color: isBahaya ? Colors.orange.shade900 : AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['judul'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isBahaya ? Colors.orange.shade900 : theme.colorScheme.onSurface)),
                                Text(formatWaktu, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(item['pesan'], style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}