import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:io';
import '../widgets/lost_and_found_bottom_bar.dart';
import '../services/lost_and_found_service.dart';

class LostAndFoundChatScreen extends StatefulWidget {
  final String itemName;
  final String imageUrl;
  final String reporterName;
  final String reporterAvatar;
  final String? itemId;
  final Function(String newStatus)? onStatusChanged;

  const LostAndFoundChatScreen({
    Key? key,
    required this.itemName,
    required this.imageUrl,
    required this.reporterName,
    required this.reporterAvatar,
    this.itemId,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<LostAndFoundChatScreen> createState() => _LostAndFoundChatScreenState();
}

class _LostAndFoundChatScreenState extends State<LostAndFoundChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    LostAndFoundService().addListener(_onServiceChanged);
    
    // Hubungkan WebSocket real-time chat
    final String itemId = widget.itemId ?? 'default';
    final item = LostAndFoundService().getItemById(itemId);
    final bool isMyReport = item?.reporterName == LostAndFoundService().activeUserName;
    LostAndFoundService().connectChat(
      itemId,
      senderName: LostAndFoundService().activeUserName,
    );
  }

  @override
  void dispose() {
    final String itemId = widget.itemId ?? 'default';
    LostAndFoundService().disconnectChat(itemId);
    
    LostAndFoundService().removeListener(_onServiceChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, dynamic>> get _chatMessages {
    return LostAndFoundService().getChatMessages(widget.itemId ?? 'default');
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    _messageController.clear();

    LostAndFoundService().sendChatMessage(
      widget.itemId ?? 'default',
      message: text,
      isMe: true,
    );

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCompleteDialog() {
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
              'Tandai Selesai?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Apakah barang sudah berhasil diterima dan proses klaim selesai?',
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
                    child: const Text('Belum'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (widget.itemId != null) {
                        LostAndFoundService().updateItemStatus(widget.itemId!, 'SELESAI');
                      }
                      widget.onStatusChanged?.call('SELESAI');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎉 Laporan selesai! Terima kasih atas kerjasamanya.'),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                      Navigator.pop(context); // Close chat
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE3E1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2323)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.reporterName,
                    style: const TextStyle(
                      color: Color(0xFF2D2323),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Tandai Selesai button
          if (widget.onStatusChanged != null)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
              tooltip: 'Tandai Selesai',
              onPressed: _showCompleteDialog,
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2D2323)),
            onPressed: () {
              _showChatOptions();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Item Verification Status Card
                  Container(
                    padding: const EdgeInsets.all(12),
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
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget.imageUrl.startsWith('http')
                              ? Image.network(
                                  widget.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(widget.imageUrl),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF2D2323),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'STATUS: DALAM KLAIM',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tips Keamanan Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryRed.withOpacity(0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.shield_outlined, color: AppColors.primaryRed, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tips: Hindari melakukan pembayaran apapun sebelum barang diterima. Bertemu di tempat umum yang ramai.',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chat Bubbles
                  ..._chatMessages.map((msg) => _buildChatBubble(msg)),
                ],
              ),
            ),

            // Text Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(fontSize: 13),
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Tulis pesan...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Reusable bottom navigation bar matching the mockup
            const LostAndFoundBottomBar(activeIndex: 0),
          ],
        ),
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.onStatusChanged != null)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                  title: const Text('Tandai Selesai', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Barang sudah diterima oleh pemilik', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(context);
                    _showCompleteDialog();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Colors.orange),
                title: const Text('Laporkan Pengguna', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Jika ada indikasi penipuan atau perilaku mencurigakan', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Laporan telah dikirim ke admin. Terima kasih.'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                title: const Text('Batalkan Klaim', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Kembalikan status ke Diproses', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  if (widget.itemId != null) {
                    LostAndFoundService().updateItemStatus(widget.itemId!, 'DIPROSES');
                  }
                  widget.onStatusChanged?.call('DIPROSES');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Status dikembalikan ke Diproses.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    final bool hasImage = msg['hasImage'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryRed : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage) ...[
                     ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: msg['imageUrl'].toString().startsWith('http')
                          ? Image.network(
                              msg['imageUrl'],
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(msg['imageUrl']),
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    msg['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg['time'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: Colors.blue, size: 12),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
