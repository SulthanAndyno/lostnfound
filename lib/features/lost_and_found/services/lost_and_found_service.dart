import 'package:flutter/material.dart';
import '../models/lost_and_found_item.dart';
import '../../../core/theme/app_colors.dart';

class LostAndFoundService extends ChangeNotifier {
  // Singleton pattern
  static final LostAndFoundService _instance = LostAndFoundService._internal();
  factory LostAndFoundService() => _instance;
  
  LostAndFoundService._internal() {
    _initializeMockData();
  }

  final List<LostAndFoundItem> _items = [];
  final Map<String, List<Map<String, dynamic>>> _chatMessages = {};

  void _initializeMockData() {
    _items.addAll([
      LostAndFoundItem(
        id: '1',
        status: 'LOST REPORT',
        itemName: 'DOMPET KULIT HITAM',
        location: 'Gedung Perpustakaan Pusat, Lt. 2.',
        imageUrl: 'https://images.unsplash.com/photo-1627124118123-2854b3dbc19a?q=80&w=300',
        category: 'Aksesoris & Personal',
        date: '12 Okt 2023',
        description: 'Dompet kulit berwarna hitam merek \'Fossil\'. Berisi kartu identitas (KTM), beberapa kartu ATM, dan uang tunai. Terakhir terlihat di meja area pelajar lantai 2 Perpustakaan Pusat.',
        reporterName: 'Budi',
        reporterAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150',
        reporterRating: 4.9,
        isLostReport: true,
        statusColor: AppColors.primaryRed,
        reportStatus: 'DIPROSES',
        campusName: 'Bandung',
      ),
      LostAndFoundItem(
        id: '2',
        status: 'LOST REPORT',
        itemName: 'HEADPHONE SONY',
        location: 'Perpustakaan Kampus B',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300',
        category: 'Elektronik',
        date: '15 Okt 2023',
        description: 'Headphone Sony WH-1000XM4 warna hitam. Terakhir diletakkan di meja perpustakaan Kampus B.',
        reporterName: 'Siti',
        reporterAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
        reporterRating: 4.8,
        isLostReport: true,
        statusColor: AppColors.primaryRed,
        reportStatus: 'DALAM KLAIM',
        campusName: 'Bandung',
      ),
      LostAndFoundItem(
        id: '3',
        status: 'LOST REPORT',
        itemName: 'KUNCI KAMAR KOS',
        location: 'Area Parkiran Kampus A',
        imageUrl: 'https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=300',
        category: 'Lain-lain',
        date: '16 Okt 2023',
        description: 'Gantungan kunci kamar kos dengan mainan boneka beruang warna coklat.',
        reporterName: 'Rian',
        reporterAvatar: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=150',
        reporterRating: 4.7,
        isLostReport: true,
        isCancelled: true,
        backgroundColor: const Color(0xFFEBE3E1),
        statusColor: AppColors.primaryRed,
        reportStatus: 'BATAL',
        campusName: 'Bandung',
      ),
      LostAndFoundItem(
        id: '4',
        status: 'FOUND REPORT',
        itemName: 'DOMPET KULIT HITAM',
        location: 'Gedung Perpustakaan Pusat, Lt. 2.',
        imageUrl: 'https://images.unsplash.com/photo-1627124118123-2854b3dbc19a?q=80&w=300',
        category: 'Aksesoris & Personal',
        date: '12 Okt 2023',
        description: 'Dompet kulit berwarna hitam merek \'Fossil\'. Ditemukan di meja area pelajar lantai 2 Perpustakaan Pusat.',
        reporterName: 'Budi',
        reporterAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150',
        reporterRating: 4.9,
        isLostReport: false,
        statusColor: const Color(0xFF00897B),
        reportStatus: 'DIPROSES',
        campusName: 'Bandung',
      ),
      LostAndFoundItem(
        id: '5',
        status: 'FOUND REPORT',
        itemName: 'HEADPHONE SONY',
        location: 'Telah diserahkan kepada pemilik\n12 September 2025.',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300',
        category: 'Elektronik',
        date: '15 Okt 2023',
        description: 'Headphone Sony WH-1000XM4 warna hitam. Telah diserahkan kepada pemilik pada 12 September 2025.',
        reporterName: 'Siti',
        reporterAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
        reporterRating: 4.8,
        isLostReport: false,
        isFoundCompleted: true,
        statusColor: const Color(0xFF00897B),
        reportStatus: 'SELESAI',
        campusName: 'Bandung',
      ),
      LostAndFoundItem(
        id: '6',
        status: 'FOUND REPORT',
        itemName: 'KUNCI KAMAR KOS',
        location: 'Telah diserahkan kepada pemilik\n12 September 2025.',
        imageUrl: 'https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=300',
        category: 'Lain-lain',
        date: '16 Okt 2023',
        description: 'Kunci kamar kos dengan gantungan besi. Telah diserahkan kepada pemilik pada 12 September 2025.',
        reporterName: 'Rian',
        reporterAvatar: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=150',
        reporterRating: 4.7,
        isLostReport: false,
        isFoundCompleted: true,
        statusColor: const Color(0xFF00897B),
        reportStatus: 'SELESAI',
        campusName: 'Bandung',
      ),
    ]);

    // Populate initial chat messages for itemId = '2'
    _chatMessages['2'] = [
      {
        'isMe': false,
        'message': 'Halo, saya rasa saya menemukan headphone Anda di perpustakaan Kampus B tadi.',
        'time': '09:42 AM',
        'hasImage': false,
      },
      {
        'isMe': true,
        'message': 'Wah serius? Terima kasih banyak! Apakah kondisinya masih baik?',
        'time': '09:45 AM',
        'hasImage': false,
      },
      {
        'isMe': false,
        'message': 'Iya, kondisinya aman. Ini fotonya untuk memastikan.',
        'time': '09:48 AM',
        'hasImage': true,
        'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300',
      },
    ];

    // Additional mock chat for itemId = '1'
    _chatMessages['1'] = [
      {
        'isMe': true,
        'message': 'Permisi, saya kehilangan dompet hitam di perpustakaan. Apakah Anda menemukannya?',
        'time': '10:15 AM',
        'hasImage': false,
      },
      {
        'isMe': false,
        'message': 'Halo, saya rasa saya pernah lihat dompet hitam di meja baca lantai 2. Coba cek ke satpam ya.',
        'time': '10:20 AM',
        'hasImage': false,
      },
    ];

    // Mock chat for itemId = '4'
    _chatMessages['4'] = [
      {
        'isMe': false,
        'message': 'Halo, ini dompet saya! Saya sangat lega Anda menemukannya.',
        'time': '11:00 AM',
        'hasImage': false,
      },
      {
        'isMe': true,
        'message': 'Alhamdulillah, bisa kita bertemu di lobby gedung A?',
        'time': '11:05 AM',
        'hasImage': false,
      },
      {
        'isMe': false,
        'message': 'Baik, saya akan ke sana jam 2 siang ya.',
        'time': '11:08 AM',
        'hasImage': false,
      },
    ];
  }

  // Getters
  List<LostAndFoundItem> getItems({String? campus}) {
    if (campus == null) return List.from(_items);
    return List.from(_items.where((item) => item.campusName.toLowerCase() == campus.toLowerCase()));
  }

  List<LostAndFoundItem> getMyReports() {
    return List.from(_items.where((item) => item.reporterName == 'Saya'));
  }

  LostAndFoundItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  // Actions
  void createReport(LostAndFoundItem newItem) {
    _items.insert(0, newItem);
    notifyListeners();
  }

  void updateItemStatus(String itemId, String newStatus) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final oldItem = _items[index];
      _items[index] = LostAndFoundItem(
        id: oldItem.id,
        status: oldItem.status,
        itemName: oldItem.itemName,
        location: oldItem.location,
        imageUrl: oldItem.imageUrl,
        category: oldItem.category,
        date: oldItem.date,
        description: oldItem.description,
        reporterName: oldItem.reporterName,
        reporterAvatar: oldItem.reporterAvatar,
        reporterRating: oldItem.reporterRating,
        isLostReport: oldItem.isLostReport,
        statusColor: oldItem.statusColor,
        reportStatus: newStatus,
        campusName: oldItem.campusName,
        isFoundCompleted: newStatus == 'SELESAI',
        isCancelled: newStatus == 'BATAL',
        backgroundColor: newStatus == 'BATAL' ? const Color(0xFFEBE3E1) : Colors.white,
      );
      notifyListeners();
    }
  }

  // Chat Messages
  List<Map<String, dynamic>> getChatMessages(String itemId) {
    if (!_chatMessages.containsKey(itemId)) {
      _chatMessages[itemId] = [
        {
          'isMe': false,
          'message': 'Halo, apakah barang ini masih tersedia atau sudah ada yang mengklaim?',
          'time': '09:40 AM',
          'hasImage': false,
        }
      ];
    }
    return _chatMessages[itemId]!;
  }

  void sendChatMessage(String itemId, {required String message, required bool isMe, String? imageUrl}) {
    if (!_chatMessages.containsKey(itemId)) {
      _chatMessages[itemId] = [];
    }
    final now = TimeOfDay.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _chatMessages[itemId]!.add({
      'isMe': isMe,
      'message': message,
      'time': timeStr,
      'hasImage': imageUrl != null,
      'imageUrl': imageUrl,
    });
    notifyListeners();
  }

  /// Returns all item IDs that have chat conversations
  List<String> getChatItemIds() {
    return _chatMessages.keys.where((id) => _chatMessages[id]!.isNotEmpty).toList();
  }

  /// Returns chat conversations paired with their item data for the history screen
  List<Map<String, dynamic>> getChatConversations() {
    final conversations = <Map<String, dynamic>>[];
    for (final itemId in _chatMessages.keys) {
      final messages = _chatMessages[itemId];
      if (messages == null || messages.isEmpty) continue;

      final item = getItemById(itemId);
      if (item == null) continue;

      final lastMessage = messages.last;
      conversations.add({
        'itemId': itemId,
        'item': item,
        'lastMessage': lastMessage['message'] as String,
        'lastTime': lastMessage['time'] as String,
        'isLastMe': lastMessage['isMe'] as bool,
        'messageCount': messages.length,
        'hasUnread': !(lastMessage['isMe'] as bool),
      });
    }
    return conversations;
  }

  /// Check if any chat history exists
  bool get hasChatHistory => _chatMessages.values.any((msgs) => msgs.isNotEmpty);
}

