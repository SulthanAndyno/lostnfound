import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'create_report_screen.dart';
import 'my_reports_screen.dart';
import 'chat_history_screen.dart';
import '../models/lost_and_found_item.dart';
import '../widgets/lost_and_found_item_card.dart';
import '../services/lost_and_found_service.dart';

class LostAndFoundMainScreen extends StatefulWidget {
  final String campusName;
  const LostAndFoundMainScreen({Key? key, required this.campusName})
    : super(key: key);

  @override
  State<LostAndFoundMainScreen> createState() => _LostAndFoundMainScreenState();
}

class _LostAndFoundMainScreenState extends State<LostAndFoundMainScreen> {
  bool isBarangHilang = true;
  String activeFilter = 'Semua';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    LostAndFoundService().addListener(_onServiceChanged);
    LostAndFoundService().fetchItems();
  }

  @override
  void dispose() {
    LostAndFoundService().removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<LostAndFoundItem> get _items =>
      LostAndFoundService().getItems(campus: widget.campusName);

  List<LostAndFoundItem> get _filteredItems {
    return _items.where((item) {
      // 1. Tipe laporan
      if (item.isLostReport != isBarangHilang) return false;

      // 2. Filter status
      if (activeFilter == 'Diproses' && item.reportStatus != 'DIPROSES')
        return false;
      if (activeFilter == 'Dalam Klaim' && item.reportStatus != 'DALAM KLAIM')
        return false;
      if (activeFilter == 'Selesai' && item.reportStatus != 'SELESAI')
        return false;

      // 3. Query pencarian
      if (searchQuery.isNotEmpty) {
        final name = item.itemName.toLowerCase();
        final cat = item.category.toLowerCase();
        final loc = item.location.toLowerCase();
        if (!name.contains(searchQuery) &&
            !cat.contains(searchQuery) &&
            !loc.contains(searchQuery)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Statistik
  int get _totalLaporan =>
      _items.where((i) => i.isLostReport == isBarangHilang).length;
  int get _activeCount => _items
      .where((i) => i.isLostReport == isBarangHilang && i.isActive)
      .length;
  int get _selesaiCount => _items
      .where(
        (i) => i.isLostReport == isBarangHilang && i.reportStatus == 'SELESAI',
      )
      .length;

  void _updateItemStatus(String itemId, String newStatus) {
    LostAndFoundService().updateItemStatus(itemId, newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tombol Riwayat Chat
          IconButton(
            icon: const Icon(Icons.chat_outlined, color: Colors.white),
            tooltip: 'Riwayat Chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Merah di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(color: AppColors.primaryRed),
            ),
          ),

          // Konten Utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 10.0,
                bottom: 20.0,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBE3E1), // Krem background
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Lost & Found
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lost & Found',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4A4444),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kampus ${widget.campusName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Badge Laporan Saya
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MyReportsScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryRed.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primaryRed.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.history,
                                          color: AppColors.primaryRed,
                                          size: 13,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Laporan',
                                          style: TextStyle(
                                            color: AppColors.primaryRed,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Statistik Ringkas
                        Row(
                          children: [
                            _buildStatCard(
                              'Total',
                              _totalLaporan.toString(),
                              const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 8),
                            _buildStatCard(
                              'Aktif',
                              _activeCount.toString(),
                              const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 8),
                            _buildStatCard(
                              'Selesai',
                              _selesaiCount.toString(),
                              const Color(0xFF10B981),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Kolom Pencarian
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(color: Colors.white),
                                  onChanged: (val) {
                                    setState(() {
                                      searchQuery = val.toLowerCase();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        'Cari barang, kategori, lokasi...',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle Buttons (Barang Hilang / Barang Temuan)
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    isBarangHilang = true;
                                    activeFilter = 'Semua';
                                  }),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isBarangHilang
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Barang Hilang',
                                      style: TextStyle(
                                        color: isBarangHilang
                                            ? AppColors.primaryRed
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    isBarangHilang = false;
                                    activeFilter = 'Semua';
                                  }),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: !isBarangHilang
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Barang Temuan',
                                      style: TextStyle(
                                        color: !isBarangHilang
                                            ? AppColors.primaryRed
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filter Chips (Semua, Diproses, Dalam Klaim, Selesai)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip('Semua'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Diproses'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Dalam Klaim'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Selesai'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // List of Items
                        Expanded(
                          child: filteredItems.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 60,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tidak ada data barang.',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Coba ubah filter atau buat laporan baru.',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: LostAndFoundItemCard(
                                        item: item,
                                        onStatusUpdated: (newStatus) {
                                          _updateItemStatus(item.id, newStatus);
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Action Button di pojok kanan bawah container
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.note_add_outlined,
                          color: AppColors.primaryRed,
                          size: 28,
                        ),
                        onPressed: () async {
                          final newReportMap =
                              await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateReportScreen(
                                        initialIsLostReport: isBarangHilang,
                                      ),
                                ),
                              );
                          if (newReportMap != null) {
                            final map = Map<String, dynamic>.from(newReportMap);
                            map['id'] = DateTime.now().millisecondsSinceEpoch
                                .toString();
                            map['campusName'] = widget.campusName;
                            final newItem = LostAndFoundItem.fromMap(map);
                            LostAndFoundService().createReport(newItem);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = activeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          activeFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryRed.withOpacity(0.85)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primaryRed
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
