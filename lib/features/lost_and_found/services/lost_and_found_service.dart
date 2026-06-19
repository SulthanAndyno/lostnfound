import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/lost_and_found_item.dart';

class LostAndFoundService extends ChangeNotifier {
  // Singleton pattern
  static final LostAndFoundService _instance = LostAndFoundService._internal();
  factory LostAndFoundService() => _instance;
  
  // Ganti host ini dengan alamat ngrok atau IP laptop kamu untuk testing real device ya beb!
  static String serverHost = 'murkiness-utensil-fondly.ngrok-free.dev';
  
  static String get apiBaseUrl => 'https://$serverHost';
  static String get wsBaseUrl => 'wss://$serverHost';

  // Menyimpan nama user aktif untuk simulasi chat 2 HP (SSO test)
  String activeUserName = 'Budi';

  LostAndFoundService._internal() {
    _initializeData();
  }

  final List<LostAndFoundItem> _items = [];
  final Map<String, List<Map<String, dynamic>>> _chatMessages = {};
  final Map<String, WebSocketChannel> _activeChannels = {};

  WebSocketChannel? _itemsChannel;

  void _initializeData() {
    fetchItems();
    connectItemsSync();
  }

  void connectItemsSync() {
    if (_itemsChannel != null) return;
    try {
      final wsUri = Uri.parse('$wsBaseUrl/ws/items');
      final channel = WebSocketChannel.connect(wsUri);
      _itemsChannel = channel;

      channel.stream.listen((message) {
        if (message == 'update') {
          debugPrint('WebSocket: Menerima sinyal update barang dari server');
          fetchItems();
        }
      }, onError: (err) {
        debugPrint('Items WebSocket error: $err');
        _itemsChannel = null;
        // Reconnect after 3 seconds
        Future.delayed(const Duration(seconds: 3), connectItemsSync);
      }, onDone: () {
        debugPrint('Items WebSocket closed');
        _itemsChannel = null;
        // Reconnect after 3 seconds
        Future.delayed(const Duration(seconds: 3), connectItemsSync);
      });
    } catch (e) {
      debugPrint('Error connecting items sync WebSocket: $e');
    }
  }

  void setActiveUser(String name) {
    activeUserName = name;
    debugPrint('User aktif diubah menjadi: $activeUserName');
    notifyListeners();
  }

  // Fetch all items from Go backend
  Future<void> fetchItems() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/items'));
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        _items.clear();
        for (var map in decoded) {
          _items.add(LostAndFoundItem.fromMap(map));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }
  }

  // Getters
  List<LostAndFoundItem> getItems({String? campus}) {
    if (campus == null) return List.from(_items);
    return List.from(_items.where((item) => item.campusName.toLowerCase() == campus.toLowerCase()));
  }

  List<LostAndFoundItem> getMyReports() {
    return List.from(_items.where((item) => item.reporterName == activeUserName));
  }

  LostAndFoundItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  // Actions
  Future<void> createReport(LostAndFoundItem newItem) async {
    // Add locally first for instant UI response
    _items.insert(0, newItem);
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newItem.toMap()),
      );
      if (response.statusCode != 201) {
        debugPrint('Failed to save item on server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating report: $e');
    }
  }

  Future<void> updateItemStatus(String itemId, String newStatus) async {
    // Update locally first for instant UI response
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

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/items/$itemId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );
      if (response.statusCode != 200) {
        debugPrint('Failed to update status on server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  // Get chat messages (if list is empty, fetches from backend)
  List<Map<String, dynamic>> getChatMessages(String itemId) {
    if (!_chatMessages.containsKey(itemId)) {
      _chatMessages[itemId] = [];
      fetchChatHistory(itemId);
    }
    return _chatMessages[itemId]!;
  }

  // Fetch chat history from Go backend
  Future<void> fetchChatHistory(String itemId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/chats/$itemId?activeUser=$activeUserName'));
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        _chatMessages[itemId] = decoded.map((msg) {
          return {
            'isMe': msg['isMe'] ?? (msg['senderName'] == activeUserName),
            'message': msg['message'] ?? '',
            'time': msg['time'] ?? '',
            'hasImage': msg['hasImage'] ?? false,
            'imageUrl': msg['imageUrl'],
          };
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching chat history: $e');
    }
  }

  // Connect to WebSocket for real-time updates
  void connectChat(String itemId, {String? senderName}) {
    if (_activeChannels.containsKey(itemId)) return;

    final name = senderName ?? activeUserName;

    try {
      final wsUri = Uri.parse('$wsBaseUrl/ws/chat?itemId=$itemId&senderName=$name');
      final channel = WebSocketChannel.connect(wsUri);
      _activeChannels[itemId] = channel;

      channel.stream.listen((message) {
        try {
          final Map<String, dynamic> msg = jsonDecode(message);
          if (!_chatMessages.containsKey(itemId)) {
            _chatMessages[itemId] = [];
          }
          
          // Check if message already exists locally (to avoid double display if sending)
          final bool messageExists = _chatMessages[itemId]!.any((m) =>
              m['message'] == msg['message'] &&
              m['time'] == msg['time'] &&
              m['isMe'] == (msg['senderName'] == name));
              
          if (!messageExists) {
            _chatMessages[itemId]!.add({
              'isMe': msg['senderName'] == name,
              'message': msg['message'] ?? '',
              'time': msg['time'] ?? '',
              'hasImage': msg['hasImage'] ?? false,
              'imageUrl': msg['imageUrl'],
            });
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error parsing WebSocket message: $e');
        }
      }, onError: (err) {
        debugPrint('WebSocket error: $err');
        _activeChannels.remove(itemId);
      }, onDone: () {
        debugPrint('WebSocket closed for item: $itemId');
        _activeChannels.remove(itemId);
      });
    } catch (e) {
      debugPrint('Error connecting WebSocket: $e');
    }
  }

  // Disconnect WebSocket
  void disconnectChat(String itemId) {
    if (_activeChannels.containsKey(itemId)) {
      _activeChannels[itemId]?.sink.close();
      _activeChannels.remove(itemId);
    }
  }

  // Send message via WebSocket
  void sendChatMessage(String itemId, {required String message, required bool isMe, String? imageUrl}) {
    final channel = _activeChannels[itemId];
    if (channel != null) {
      channel.sink.add(jsonEncode({
        'message': message,
        'hasImage': imageUrl != null,
        'imageUrl': imageUrl ?? '',
      }));
    } else {
      // Fallback in case WS is not connected
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
  }

  List<String> getChatItemIds() {
    return _chatMessages.keys.where((id) => _chatMessages[id]!.isNotEmpty).toList();
  }

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

  bool get hasChatHistory => _chatMessages.values.any((msgs) => msgs.isNotEmpty);
}
