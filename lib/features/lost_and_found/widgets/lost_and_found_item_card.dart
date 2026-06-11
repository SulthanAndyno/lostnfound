import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../models/lost_and_found_item.dart';
import '../screens/lost_and_found_detail_screen.dart';
import '../screens/lost_and_found_chat_screen.dart';

class LostAndFoundItemCard extends StatelessWidget {
  final LostAndFoundItem item;
  final Function(String newStatus)? onStatusUpdated;

  const LostAndFoundItemCard({
    Key? key,
    required this.item,
    this.onStatusUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl.startsWith('http')
                  ? Image.network(
                      item.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, color: Colors.white54, size: 40),
                    )
                  : Image.file(
                      File(item.imageUrl),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, color: Colors.white54, size: 40),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Info Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: item.statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.reportStatusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: item.reportStatusColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        item.reportStatus,
                        style: TextStyle(
                          color: item.reportStatusColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Location info
                if (item.isActive && item.location.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location.replaceAll('\n', ' '),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                // Cancelled info
                if (item.reportStatus == 'BATAL')
                  const Text(
                    'Laporan dibatalkan oleh pengguna.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),

                // Selesai info
                if (item.reportStatus == 'SELESAI')
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.isFoundCompleted
                              ? 'Barang telah diserahkan ke pemilik'
                              : 'Barang telah ditemukan',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                // Dalam Klaim info
                if (item.reportStatus == 'DALAM KLAIM')
                  Row(
                    children: [
                      const Icon(Icons.handshake_outlined, color: Color(0xFF3B82F6), size: 14),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Sedang dalam proses verifikasi',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                // Action Buttons
                if (item.isActive)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Primary Action Button
                      GestureDetector(
                        onTap: () {
                          if (item.isLostReport && item.reportStatus == 'DIPROSES') {
                            // Tandai sudah ditemukan → Selesai
                            _showConfirmDialog(
                              context,
                              'Konfirmasi Selesai',
                              'Apakah barang ini sudah ditemukan? Status laporan akan berubah menjadi Selesai.',
                              () {
                                onStatusUpdated?.call('SELESAI');
                              },
                            );
                          } else if (item.reportStatus == 'DALAM KLAIM') {
                            // Buka chat untuk lanjut koordinasi
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LostAndFoundChatScreen(
                                  itemName: item.itemName,
                                  imageUrl: item.imageUrl,
                                  reporterName: item.reporterName,
                                  reporterAvatar: item.reporterAvatar,
                                  itemId: item.id,
                                  onStatusChanged: onStatusUpdated,
                                ),
                              ),
                            );
                          } else {
                            // Hubungi Penemu → set status DALAM KLAIM
                            onStatusUpdated?.call('DALAM KLAIM');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LostAndFoundChatScreen(
                                  itemName: item.itemName,
                                  imageUrl: item.imageUrl,
                                  reporterName: item.reporterName,
                                  reporterAvatar: item.reporterAvatar,
                                  itemId: item.id,
                                  onStatusChanged: onStatusUpdated,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _primaryButtonColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _primaryButtonLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Detail Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LostAndFoundDetailScreen(
                                item: item,
                                onStatusChanged: onStatusUpdated,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Detail',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _primaryButtonColor {
    if (item.isLostReport && item.reportStatus == 'DIPROSES') {
      return const Color(0xFF10B981); // Green for "Sudah Ditemukan"
    }
    if (item.reportStatus == 'DALAM KLAIM') {
      return const Color(0xFF3B82F6); // Blue for "Lanjut Chat"
    }
    return AppColors.primaryRed;
  }

  String get _primaryButtonLabel {
    if (item.isLostReport && item.reportStatus == 'DIPROSES') {
      return 'Sudah\nDitemukan';
    }
    if (item.reportStatus == 'DALAM KLAIM') {
      return 'Lanjut\nChat';
    }
    return item.isLostReport ? 'Sudah\nDitemukan' : 'Hubungi\nPenemu';
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Konfirmasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
