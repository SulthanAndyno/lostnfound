import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'lost_and_found_chat_screen.dart';
import 'dart:io';
import '../models/lost_and_found_item.dart';
import '../widgets/lost_and_found_bottom_bar.dart';
import '../services/lost_and_found_service.dart';

class LostAndFoundDetailScreen extends StatelessWidget {
  final LostAndFoundItem item;
  final Function(String newStatus)? onStatusChanged;

  const LostAndFoundDetailScreen({
    Key? key,
    required this.item,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE3E1),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Header with overlay buttons
                    Stack(
                      children: [
                        Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: item.imageUrl.startsWith('http')
                                  ? NetworkImage(item.imageUrl) as ImageProvider
                                  : FileImage(File(item.imageUrl)) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Back Button
                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        // Share Button
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.share_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        // Status Badge Overlay
                        Positioned(
                          bottom: 28,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: item.reportStatusColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: item.reportStatusColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _statusIcon,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.reportStatus,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Report Type Badge
                        Positioned(
                          bottom: 28,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: item.isLostReport
                                  ? AppColors.primaryRed.withOpacity(0.9)
                                  : const Color(0xFF00897B).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.isLostReport ? 'BARANG HILANG' : 'BARANG TEMUAN',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Detail Content Card
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEBE3E1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Item Title
                            Text(
                              item.itemName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2D2323),
                              ),
                            ),
                            const SizedBox(height: 6),
                            
                            // Category Tag
                            Row(
                              children: [
                                const Icon(
                                  Icons.category_outlined,
                                  color: AppColors.primaryRed,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Location, Date, Status cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.location_on_outlined,
                                    label: 'LOKASI',
                                    value: item.location.replaceAll('\n', ' '),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.calendar_today_outlined,
                                    label: 'TANGGAL',
                                    value: item.date,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Deskripsi Detail
                            const Text(
                              'Deskripsi Detail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF2D2323),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Reporter Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage: NetworkImage(item.reporterAvatar),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.isLostReport ? 'PEMILIK' : 'PENEMU',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.reporterName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF2D2323),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.reporterRating.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Status-aware Action Buttons
                            if (item.isActive) ...[
                              if (item.reporterName == LostAndFoundService().activeUserName) ...[
                                // Jika laporan milik SAYA
                                if (item.reportStatus == 'DIPROSES') ...[
                                  // Primary: Tandai Selesai
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _showCompleteDialog(context);
                                      },
                                      icon: const Icon(Icons.check_circle_outline, size: 18),
                                      label: const Text(
                                        'Tandai Sudah Ditemukan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Secondary: Batalkan Laporan
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showCancelDialog(context);
                                      },
                                      icon: const Icon(Icons.cancel_outlined, size: 18),
                                      label: const Text(
                                        'Batalkan Laporan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey[700],
                                        side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else if (item.reportStatus == 'DALAM KLAIM') ...[
                                  // Primary: Lanjut Chat
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LostAndFoundChatScreen(
                                              itemName: item.itemName,
                                              imageUrl: item.imageUrl,
                                              reporterName: 'Pihak Lain',
                                              reporterAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
                                              itemId: item.id,
                                              onStatusChanged: onStatusChanged,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chat, size: 18),
                                      label: const Text(
                                        'Lanjutkan Chat Klaim',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3B82F6),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Secondary: Tandai Selesai
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showCompleteDialog(context);
                                      },
                                      icon: const Icon(Icons.check_circle_outline, size: 18),
                                      label: const Text(
                                        'Tandai Barang Sudah Dikembalikan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF10B981),
                                        side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ] else ...[
                                // Jika laporan milik ORANG LAIN
                                // Primary: Hubungi / Lanjut Chat
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (item.reportStatus == 'DIPROSES') {
                                        LostAndFoundService().updateItemStatus(item.id, 'DALAM KLAIM');
                                        onStatusChanged?.call('DALAM KLAIM');
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LostAndFoundChatScreen(
                                            itemName: item.itemName,
                                            imageUrl: item.imageUrl,
                                            reporterName: item.reporterName,
                                            reporterAvatar: item.reporterAvatar,
                                            itemId: item.id,
                                            onStatusChanged: onStatusChanged,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      item.reportStatus == 'DALAM KLAIM'
                                          ? Icons.chat
                                          : Icons.chat_bubble_outline,
                                      size: 18,
                                    ),
                                    label: Text(
                                      item.reportStatus == 'DALAM KLAIM'
                                          ? 'Lanjutkan Chat'
                                          : (item.isLostReport
                                              ? 'Hubungi Pemilik'
                                              : 'Hubungi Penemu'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: item.reportStatus == 'DALAM KLAIM'
                                          ? const Color(0xFF3B82F6)
                                          : AppColors.primaryRed,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Secondary: Tandai Selesai (only in DALAM KLAIM)
                                if (item.reportStatus == 'DALAM KLAIM')
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showCompleteDialog(context);
                                      },
                                      icon: const Icon(Icons.check_circle_outline, size: 18),
                                      label: const Text(
                                        'Tandai Barang Sudah Diterima',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF10B981),
                                        side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),

                                if (item.reportStatus == 'DIPROSES') ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.share_outlined, size: 18),
                                      label: const Text(
                                        'Bagikan Temuan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primaryRed,
                                        side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ],

                            // Completed status display
                            if (item.reportStatus == 'SELESAI')
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Laporan ini telah selesai.\nBarang berhasil dikembalikan kepada pemiliknya.',
                                        style: TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Security Tips Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primaryRed.withOpacity(0.1)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    color: AppColors.primaryRed,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Tips Keamanan',
                                          style: TextStyle(
                                            color: AppColors.primaryRed,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Selalu bertemu di tempat umum yang ramai saat proses pengembalian barang. Gunakan fitur \'Titip di Pos Keamanan\' untuk transaksi lebih aman.',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Reusable bottom navigation bar matching the mockup
            const LostAndFoundBottomBar(activeIndex: 0),
          ],
        ),
      ),
    );
  }

  IconData get _statusIcon {
    switch (item.reportStatus) {
      case 'DIPROSES':
        return Icons.hourglass_empty;
      case 'DALAM KLAIM':
        return Icons.handshake_outlined;
      case 'SELESAI':
        return Icons.check_circle;
      case 'BATAL':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Konfirmasi Penyelesaian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Apakah barang sudah berhasil dikembalikan kepada pemiliknya? Status laporan akan berubah menjadi Selesai.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Belum', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      LostAndFoundService().updateItemStatus(item.id, 'SELESAI');
                      onStatusChanged?.call('SELESAI');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎉 Laporan selesai! Terima kasih.'),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                      Navigator.pop(context); // Back to list
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Ya, Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Batalkan Laporan?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Apakah Anda yakin ingin membatalkan laporan ini? Tindakan ini tidak dapat diurungkan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Tidak', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      LostAndFoundService().updateItemStatus(item.id, 'BATAL');
                      onStatusChanged?.call('BATAL');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Laporan berhasil dibatalkan.'),
                          backgroundColor: Colors.grey[700],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                      Navigator.pop(context); // Back to list
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Ya, Batalkan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF2D2323),
            ),
          ),
        ],
      ),
    );
  }
}
