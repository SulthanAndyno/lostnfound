import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../models/lost_and_found_item.dart';
import '../screens/lost_and_found_detail_screen.dart';
import '../screens/lost_and_found_chat_screen.dart';
import '../services/lost_and_found_service.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              ),
            ],
          ),
          // Action Buttons below the Image/Info Row
          if (item.isActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Chat / Hubungi Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final bool isMyReport = item.reporterName == LostAndFoundService().activeUserName;
                      final bool isParticipant = LostAndFoundService()
                          .getChatConversations()
                          .any((conv) => conv['itemId'] == item.id);

                      // Blokir user lain yang mencoba masuk ke barang yang sedang diklaim orang lain
                      if (!isMyReport && item.reportStatus == 'DALAM KLAIM' && !isParticipant) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Barang ini sedang dalam proses klaim oleh pengguna lain.'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      
                      void navigateToChat() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LostAndFoundChatScreen(
                              itemName: item.itemName,
                              imageUrl: item.imageUrl,
                              reporterName: isMyReport ? 'Pihak Lain' : item.reporterName,
                              reporterAvatar: isMyReport
                                  ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150'
                                  : item.reporterAvatar,
                              itemId: item.id,
                              onStatusChanged: onStatusUpdated,
                            ),
                          ),
                        );
                      }

                      if (item.reportStatus == 'DIPROSES' && !isMyReport) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Hubungi Pelapor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            content: const Text('Apakah kamu ingin mengajukan klaim/pengembalian atas barang ini, atau hanya ingin bertanya?', style: TextStyle(fontSize: 13)),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  navigateToChat();
                                },
                                child: const Text('Hanya Bertanya'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  onStatusUpdated?.call('DALAM KLAIM');
                                  LostAndFoundService().sendChatMessage(
                                    item.id,
                                    message: 'Halo, saya ingin mengajukan klaim atas barang ini.',
                                    isMe: true,
                                  );
                                  navigateToChat();
                                },
                                child: const Text('Ajukan Klaim'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        navigateToChat();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: item.reportStatus == 'DALAM KLAIM'
                            ? const Color(0xFF3B82F6)
                            : AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.reportStatus == 'DALAM KLAIM'
                                ? Icons.chat
                                : Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.reportStatus == 'DALAM KLAIM'
                                ? 'Lanjut Chat'
                                : (item.isLostReport ? 'Hubungi Pemilik' : 'Hubungi Penemu'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Detail Button
                Expanded(
                  child: GestureDetector(
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: Colors.black87, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Detail',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
