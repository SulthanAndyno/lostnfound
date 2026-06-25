import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../models/lost_and_found_item.dart';
import '../services/lost_and_found_service.dart';
import 'lost_and_found_chat_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {

  @override
  void initState() {
    super.initState();
    LostAndFoundService().addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    LostAndFoundService().removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _allConversations =>
      LostAndFoundService().getChatConversations();

  List<Map<String, dynamic>> get _activeConversations => _allConversations
      .where((c) {
        final item = c['item'] as LostAndFoundItem;
        final bool isClaimChat = c['isClaimChat'] as bool? ?? false;
        
        // Chat akan disembunyikan/dihapus HANYA JIKA:
        // Laporan sudah Selesai/Batal DAN chat tersebut merupakan chat klaim.
        // Jika itu hanya chat bertanya (bukan chat klaim), jangan disembunyikan.
        if (!item.isActive && isClaimChat) {
          return false;
        }
        return true;
      })
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EE),
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _activeConversations.isEmpty
          ? _buildEmptyState()
          : _buildConversationList(_activeConversations, isArchive: false),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_outlined, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada percakapan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4444),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Percakapan akan muncul di sini saat kamu menghubungi pelapor atau penemu barang.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(
    List<Map<String, dynamic>> conversations, {
    required bool isArchive,
  }) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isArchive ? Icons.archive_outlined : Icons.chat_bubble_outline,
              size: 56,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              isArchive
                  ? 'Belum ada chat yang diarsipkan'
                  : 'Tidak ada percakapan aktif',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF4A4444),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                isArchive
                    ? 'Chat dari laporan yang sudah selesai atau dibatalkan akan tampil di sini.'
                    : 'Chat dari laporan yang sedang aktif akan tampil di sini.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conv = conversations[index];
        final item = conv['item'] as LostAndFoundItem;
        final lastMessage = conv['lastMessage'] as String;
        final lastTime = conv['lastTime'] as String;
        final isLastMe = conv['isLastMe'] as bool;
        final messageCount = conv['messageCount'] as int;
        final hasUnread = conv['hasUnread'] as bool;

        final otherPartyName = conv['otherPartyName'] as String;

        return _buildChatTile(
          item: item,
          otherPartyName: otherPartyName,
          lastMessage: lastMessage,
          lastTime: lastTime,
          isLastMe: isLastMe,
          messageCount: messageCount,
          hasUnread: hasUnread && !isArchive,
        );
      },
    );
  }

  Widget _buildChatTile({
    required LostAndFoundItem item,
    required String otherPartyName,
    required String lastMessage,
    required String lastTime,
    required bool isLastMe,
    required int messageCount,
    required bool hasUnread,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LostAndFoundChatScreen(
                  itemName: item.itemName,
                  imageUrl: item.imageUrl,
                  reporterName: otherPartyName,
                  reporterAvatar: item.reporterAvatar,
                  itemId: item.id,
                  onStatusChanged: (newStatus) {
                    LostAndFoundService().updateItemStatus(item.id, newStatus);
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar / Item Image
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          image: item.imageUrl.startsWith('http')
                              ? NetworkImage(item.imageUrl) as ImageProvider
                              : FileImage(File(item.imageUrl)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Status indicator dot
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: item.reportStatusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          item.isActive
                              ? Icons.sync
                              : Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Name + Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              otherPartyName,
                              style: TextStyle(
                                fontWeight: hasUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 14,
                                color: const Color(0xFF2D2323),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            lastTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: hasUnread
                                  ? AppColors.primaryRed
                                  : Colors.grey[500],
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Item Name badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.isLostReport
                              ? AppColors.primaryRed.withValues(alpha: 0.1)
                              : const Color(0xFF00897B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${item.isLostReport ? "🔴" : "🟢"} ${item.itemName}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: item.isLostReport
                                ? AppColors.primaryRed
                                : const Color(0xFF00897B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Last Message
                      Row(
                        children: [
                          if (isLastMe) ...[
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              lastMessage,
                              style: TextStyle(
                                fontSize: 12,
                                color: hasUnread
                                    ? const Color(0xFF2D2323)
                                    : Colors.grey[600],
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Unread badge
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
